import test from 'node:test';
import assert from 'node:assert/strict';
import worker from '../src/index.js';

const env = {
	GOOGLE_API_KEY: 'test-google-key',
	EMAIL: {
		async send() {
			return { messageId: 'test-message-id' };
		},
	},
};

function createEnv(emailMessages = [], overrides = {}) {
	return {
		...env,
		...overrides,
		EMAIL: {
			async send(message) {
				emailMessages.push(message);
				return { messageId: 'test-message-id' };
			},
		},
	};
}

function post(body) {
	return new Request('https://brief.test/', {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(body),
	});
}

async function readJSON(response) {
	return response.json();
}

function stubFetch(t, handler) {
	const originalFetch = globalThis.fetch;
	globalThis.fetch = handler;
	t.after(() => {
		globalThis.fetch = originalFetch;
	});
}

test('rejects requests without a usable URL and email', async () => {
	const response = await worker.fetch(post({ url: 'https://example.com/article' }), env, {});
	const body = await readJSON(response);

	assert.equal(response.status, 400);
	assert.equal(body.error, 'Missing required fields: url and email are required');
});

test('rejects non-web URLs before any outbound fetch', async (t) => {
	let fetchCalls = 0;
	stubFetch(t, async () => {
		fetchCalls += 1;
		throw new Error('fetch should not be called');
	});

	const response = await worker.fetch(post({
		url: 'javascript:alert(1)',
		email: 'reader@example.com',
	}), env, {});
	const body = await readJSON(response);

	assert.equal(response.status, 400);
	assert.equal(body.error, 'Only http and https URLs are supported');
	assert.equal(fetchCalls, 0);
});

test('rejects invalid email addresses before sending email', async (t) => {
	let fetchCalls = 0;
	stubFetch(t, async () => {
		fetchCalls += 1;
		throw new Error('fetch should not be called');
	});

	const response = await worker.fetch(post({
		url: 'https://example.com/article',
		email: 'not-an-email',
	}), env, {});
	const body = await readJSON(response);

	assert.equal(response.status, 400);
	assert.equal(body.error, 'Invalid email address format');
	assert.equal(fetchCalls, 0);
});

test('sends an email without leaking raw HTML from user or page content', async (t) => {
	const emailMessages = [];
	stubFetch(t, async (input, init) => {
		const target = typeof input === 'string' ? input : input.toString();

		if (target === 'https://example.com/article') {
			return new Response(`
				<html>
					<head>
						<meta name="author" content="<img src=x onerror=alert(1)>">
						<meta property="article:published_time" content="2026-05-13T00:00:00Z">
					</head>
				</html>
			`);
		}

		throw new Error(`Unexpected fetch: ${target}`);
	});

	const response = await worker.fetch(post({
		url: 'https://example.com/article',
		title: 'A title <script>alert(1)</script>',
		email: 'reader@example.com',
		context: 'My note <img src=x onerror=alert(1)>',
		aiSummary: false,
	}), createEnv(emailMessages), {});
	const body = await readJSON(response);

	assert.equal(response.status, 200);
	assert.equal(body.success, true);
	assert.equal(emailMessages.length, 1);
	assert.deepEqual(emailMessages[0].from, {
		email: 'brief@send-brief.com',
		name: 'Brief',
	});
	assert.equal(emailMessages[0].to, 'reader@example.com');
	assert.equal(emailMessages[0].subject, 'Example: A title <script>alert(1)</script>');

	const html = String(emailMessages[0].html);
	assert.match(html, /A title &lt;script&gt;alert\(1\)&lt;\/script&gt;/);
	assert.match(html, /My note &lt;img src=x onerror=alert\(1\)&gt;/);
	assert.match(html, /&lt;img src=x onerror=alert\(1\)&gt;/);
	assert.equal(html.includes('<script>'), false);
	assert.equal(html.includes('<img src=x'), false);
	assert.match(String(emailMessages[0].text), /My note <img src=x onerror=alert\(1\)>/);
});

test('escapes AI summary output while preserving simple formatting', async (t) => {
	const emailMessages = [];
	const longArticleText = 'This is article content. '.repeat(80);

	stubFetch(t, async (input, init) => {
		const target = typeof input === 'string' ? input : input.toString();

		if (target === 'https://example.com/article') {
			return new Response(`<html><body>${longArticleText}</body></html>`);
		}

		if (target.startsWith('https://generativelanguage.googleapis.com/')) {
			return new Response(JSON.stringify({
				candidates: [{
					content: {
						parts: [{
							text: '- **Important <unsafe> point**\n- `quoted & risky` detail',
						}],
					},
				}],
			}));
		}

		throw new Error(`Unexpected fetch: ${target}`);
	});

	const response = await worker.fetch(post({
		url: 'https://example.com/article',
		title: 'Safe title',
		email: 'reader@example.com',
		aiSummary: true,
		summaryLength: 'short',
	}), createEnv(emailMessages), {});
	const body = await readJSON(response);

	assert.equal(response.status, 200);
	assert.equal(body.success, true);

	assert.equal(emailMessages.length, 1);
	const html = String(emailMessages[0].html);
	assert.match(html, /<strong>Important &lt;unsafe&gt; point<\/strong>/);
	assert.match(html, /<code>quoted &amp; risky<\/code> detail/);
	assert.equal(html.includes('<unsafe>'), false);
	assert.match(String(emailMessages[0].text), /Important <unsafe> point/);
});

test('uses Anthropic backup when Gemini rejects AI summary generation', async (t) => {
	const emailMessages = [];
	const longArticleText = 'This is article content. '.repeat(80);
	let geminiCalls = 0;
	let anthropicCalls = 0;

	const originalError = console.error;
	console.error = () => {};
	t.after(() => {
		console.error = originalError;
	});

	stubFetch(t, async (input, init = {}) => {
		const target = typeof input === 'string' ? input : input.toString();

		if (target === 'https://example.com/article') {
			return new Response(`<html><body>${longArticleText}</body></html>`);
		}

		if (target.startsWith('https://generativelanguage.googleapis.com/')) {
			geminiCalls += 1;
			return new Response(JSON.stringify({
				error: {
					message: 'API key expired. Please renew the API key.',
				},
			}), { status: 400 });
		}

		if (target === 'https://api.anthropic.com/v1/messages') {
			anthropicCalls += 1;
			const headers = init.headers || {};
			const body = JSON.parse(init.body);

			assert.equal(headers['x-api-key'], 'test-anthropic-key');
			assert.equal(headers['anthropic-version'], '2023-06-01');
			assert.equal(body.model, 'claude-3-5-haiku-20241022');
			assert.equal(body.max_tokens, 500);

			return new Response(JSON.stringify({
				content: [{
					type: 'text',
					text: '- Backup summary point\n- Another useful detail',
				}],
			}));
		}

		throw new Error(`Unexpected fetch: ${target}`);
	});

	const response = await worker.fetch(post({
		url: 'https://example.com/article',
		title: 'Safe title',
		email: 'reader@example.com',
		aiSummary: true,
		summaryLength: 'short',
	}), createEnv(emailMessages, {
		ANTHROPIC_API_KEY: 'test-anthropic-key',
	}), {});
	const body = await readJSON(response);

	assert.equal(response.status, 200);
	assert.equal(body.success, true);
	assert.equal(geminiCalls, 1);
	assert.equal(anthropicCalls, 1);
	assert.equal(emailMessages.length, 1);

	const html = String(emailMessages[0].html);
	const text = String(emailMessages[0].text);
	assert.match(html, /Backup summary point/);
	assert.match(text, /Backup summary point/);
	assert.equal(html.includes('Summary could not be generated'), false);
	assert.equal(text.includes('Summary could not be generated'), false);
});

test('uses Anthropic backup for title-based summary when article content is inaccessible', async (t) => {
	const emailMessages = [];
	let geminiCalls = 0;
	let anthropicCalls = 0;

	const originalError = console.error;
	const originalLog = console.log;
	console.error = () => {};
	console.log = () => {};
	t.after(() => {
		console.error = originalError;
		console.log = originalLog;
	});

	stubFetch(t, async (input, init = {}) => {
		const target = typeof input === 'string' ? input : input.toString();

		if (target === 'https://example.com/paywalled') {
			return new Response('Forbidden', { status: 403 });
		}

		if (target.startsWith('https://generativelanguage.googleapis.com/')) {
			geminiCalls += 1;
			return new Response(JSON.stringify({
				error: {
					message: 'API key expired. Please renew the API key.',
				},
			}), { status: 400 });
		}

		if (target === 'https://api.anthropic.com/v1/messages') {
			anthropicCalls += 1;
			const body = JSON.parse(init.body);

			assert.equal(body.max_tokens, 300);
			assert.match(body.messages[0].content, /paywall/i);

			return new Response(JSON.stringify({
				content: [{
					type: 'text',
					text: '- Limited article detail is available\n- The saved link still has useful context',
				}],
			}));
		}

		throw new Error(`Unexpected fetch: ${target}`);
	});

	const response = await worker.fetch(post({
		url: 'https://example.com/paywalled',
		title: 'Paywalled article',
		email: 'reader@example.com',
		aiSummary: true,
		summaryLength: 'short',
	}), createEnv(emailMessages, {
		ANTHROPIC_API_KEY: 'test-anthropic-key',
	}), {});
	const body = await readJSON(response);

	assert.equal(response.status, 200);
	assert.equal(body.success, true);
	assert.equal(geminiCalls, 1);
	assert.equal(anthropicCalls, 1);
	assert.equal(emailMessages.length, 1);

	const html = String(emailMessages[0].html);
	const text = String(emailMessages[0].text);
	assert.match(html, /Summary \(AI-generated from title - full article not accessible\):/);
	assert.match(html, /Limited article detail is available/);
	assert.match(text, /Limited article detail is available/);
	assert.equal(html.includes('Summary could not be generated'), false);
	assert.equal(text.includes('Summary could not be generated'), false);
});

test('uses Anthropic when Gemini key is not configured', async (t) => {
	const emailMessages = [];
	const longArticleText = 'This is article content. '.repeat(80);
	let anthropicCalls = 0;

	stubFetch(t, async (input) => {
		const target = typeof input === 'string' ? input : input.toString();

		if (target === 'https://example.com/article') {
			return new Response(`<html><body>${longArticleText}</body></html>`);
		}

		if (target.startsWith('https://generativelanguage.googleapis.com/')) {
			throw new Error('Gemini should not be called without a key');
		}

		if (target === 'https://api.anthropic.com/v1/messages') {
			anthropicCalls += 1;
			return new Response(JSON.stringify({
				content: [{
					type: 'text',
					text: '- Anthropic-only summary point',
				}],
			}));
		}

		throw new Error(`Unexpected fetch: ${target}`);
	});

	const response = await worker.fetch(post({
		url: 'https://example.com/article',
		title: 'Safe title',
		email: 'reader@example.com',
		aiSummary: true,
		summaryLength: 'short',
	}), createEnv(emailMessages, {
		GOOGLE_API_KEY: '',
		ANTHROPIC_API_KEY: 'test-anthropic-key',
	}), {});
	const body = await readJSON(response);

	assert.equal(response.status, 200);
	assert.equal(body.success, true);
	assert.equal(anthropicCalls, 1);
	assert.equal(emailMessages.length, 1);
	assert.match(String(emailMessages[0].html), /Anthropic-only summary point/);
});

test('still sends the link with a clear fallback when AI summary generation fails', async (t) => {
	const emailMessages = [];
	const longArticleText = 'This is article content. '.repeat(80);

	const originalError = console.error;
	console.error = () => {};
	t.after(() => {
		console.error = originalError;
	});

	stubFetch(t, async (input) => {
		const target = typeof input === 'string' ? input : input.toString();

		if (target === 'https://example.com/article') {
			return new Response(`<html><body>${longArticleText}</body></html>`);
		}

		if (target.startsWith('https://generativelanguage.googleapis.com/')) {
			return new Response(JSON.stringify({
				error: {
					message: 'API key expired. Please renew the API key.',
				},
			}), { status: 400 });
		}

		throw new Error(`Unexpected fetch: ${target}`);
	});

	const response = await worker.fetch(post({
		url: 'https://example.com/article',
		title: 'Safe title',
		email: 'reader@example.com',
		aiSummary: true,
		summaryLength: 'short',
	}), createEnv(emailMessages), {});
	const body = await readJSON(response);

	assert.equal(response.status, 200);
	assert.equal(body.success, true);
	assert.equal(emailMessages.length, 1);

	const html = String(emailMessages[0].html);
	const text = String(emailMessages[0].text);
	assert.match(html, /Summary could not be generated for this article\./);
	assert.match(text, /Summary could not be generated for this article\./);
	assert.equal(html.includes('API key expired'), false);
	assert.equal(text.includes('API key expired'), false);
});

test('returns a clear error when Cloudflare email binding is missing', async (t) => {
	const originalError = console.error;
	console.error = () => {};
	t.after(() => {
		console.error = originalError;
	});

	stubFetch(t, async (input) => {
		const target = typeof input === 'string' ? input : input.toString();

		if (target === 'https://example.com/article') {
			return new Response('<html></html>');
		}

		throw new Error(`Unexpected fetch: ${target}`);
	});

	const response = await worker.fetch(post({
		url: 'https://example.com/article',
		title: 'Safe title',
		email: 'reader@example.com',
		aiSummary: false,
	}), {
		GOOGLE_API_KEY: 'test-google-key',
	}, {});
	const body = await readJSON(response);

	assert.equal(response.status, 500);
	assert.equal(body.error, 'Cloudflare Email binding EMAIL is not configured');
});

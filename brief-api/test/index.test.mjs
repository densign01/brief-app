import test from 'node:test';
import assert from 'node:assert/strict';
import worker from '../src/index.js';

const env = {
	RESEND_API_KEY: 'test-resend-key',
	GOOGLE_API_KEY: 'test-google-key',
};

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
	let resendBody;
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

		if (target === 'https://api.resend.com/emails') {
			resendBody = JSON.parse(String(init?.body));
			return new Response(JSON.stringify({ id: 'email_123' }), { status: 200 });
		}

		throw new Error(`Unexpected fetch: ${target}`);
	});

	const response = await worker.fetch(post({
		url: 'https://example.com/article',
		title: 'A title <script>alert(1)</script>',
		email: 'reader@example.com',
		context: 'My note <img src=x onerror=alert(1)>',
		aiSummary: false,
	}), env, {});
	const body = await readJSON(response);

	assert.equal(response.status, 200);
	assert.equal(body.success, true);
	assert.deepEqual(resendBody.to, ['reader@example.com']);

	const html = String(resendBody.html);
	assert.match(html, /A title &lt;script&gt;alert\(1\)&lt;\/script&gt;/);
	assert.match(html, /My note &lt;img src=x onerror=alert\(1\)&gt;/);
	assert.match(html, /&lt;img src=x onerror=alert\(1\)&gt;/);
	assert.equal(html.includes('<script>'), false);
	assert.equal(html.includes('<img src=x'), false);
});

test('escapes AI summary output while preserving simple formatting', async (t) => {
	let resendBody;
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

		if (target === 'https://api.resend.com/emails') {
			resendBody = JSON.parse(String(init?.body));
			return new Response(JSON.stringify({ id: 'email_456' }), { status: 200 });
		}

		throw new Error(`Unexpected fetch: ${target}`);
	});

	const response = await worker.fetch(post({
		url: 'https://example.com/article',
		title: 'Safe title',
		email: 'reader@example.com',
		aiSummary: true,
		summaryLength: 'short',
	}), env, {});
	const body = await readJSON(response);

	assert.equal(response.status, 200);
	assert.equal(body.success, true);

	const html = String(resendBody.html);
	assert.match(html, /<strong>Important &lt;unsafe&gt; point<\/strong>/);
	assert.match(html, /<code>quoted &amp; risky<\/code> detail/);
	assert.equal(html.includes('<unsafe>'), false);
});

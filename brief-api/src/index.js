import { generateText } from 'ai';
import { createOpenAI } from '@ai-sdk/openai';

export default {
	async fetch(request, env, ctx) {
		// Handle CORS
		if (request.method === 'OPTIONS') {
			return new Response(null, {
				headers: {
					'Access-Control-Allow-Origin': '*',
					'Access-Control-Allow-Methods': 'POST, OPTIONS',
					'Access-Control-Allow-Headers': 'Content-Type',
				}
			});
		}

		if (request.method !== 'POST') {
			return new Response('Method not allowed', { status: 405 });
		}

		try {
			const data = await request.json();
			let { url, title, site, context, aiSummary, summaryLength, email } = data;

			// Validate required fields - now only URL and email are required
			if (!url || !email) {
				return new Response(JSON.stringify({
					error: 'Missing required fields: url and email are required'
				}), {
					status: 400,
					headers: {
						'Content-Type': 'application/json',
						'Access-Control-Allow-Origin': '*'
					}
				});
			}

			// If title and site aren't provided, extract them from the URL
			if (!title || !site) {
				try {
					const urlObj = new URL(url);
					site = site || urlObj.hostname;

					// Fetch the page to extract title if not provided
					if (!title) {
						const response = await fetch(url);
						if (response.ok) {
							const html = await response.text();
							const titleMatch = html.match(/<title[^>]*>([^<]+)<\/title>/i);
							title = titleMatch ? titleMatch[1].trim() : urlObj.hostname;
						} else {
							title = urlObj.hostname;
						}
					}
				} catch (error) {
					return new Response(JSON.stringify({
						error: 'Invalid URL provided'
					}), {
						status: 400,
						headers: {
							'Content-Type': 'application/json',
							'Access-Control-Allow-Origin': '*'
						}
					});
				}
			}

			// Set defaults for optional parameters
			aiSummary = aiSummary !== undefined ? aiSummary : true;
			summaryLength = summaryLength || 'short';
			context = context || '';

			// Basic email validation
			const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
			if (!emailRegex.test(email)) {
				return new Response(JSON.stringify({
					error: 'Invalid email address format'
				}), {
					status: 400,
					headers: {
						'Content-Type': 'application/json',
						'Access-Control-Allow-Origin': '*'
					}
				});
			}

			let summaryHTML = '';
			let parsedContent = { author: '', date: '' };

			// Parse content from the website
			try {
				const articleResponse = await fetch(url);
				const html = await articleResponse.text();
				parsedContent = parseArticleMetadata(html);
			} catch (error) {
				console.error('Error parsing article content:', error);
			}

			// Generate AI Summary if requested
			if (aiSummary) {
				let summaryText = await generateSummary(
					env,
					url,
					title,
					summaryLength
				);

				let isTitleBased = false;

				// If no content summary, try title-based summary for paywalled content
				if (!summaryText) {
					summaryText = await generateTitleBasedSummary(env, title, url, summaryLength);
					isTitleBased = true;
				}

				if (summaryText) {
					const bullets = summaryText.split('\n').filter(line => line.trim());
					const headerText = isTitleBased
						? 'Summary (AI-generated from title - full article not accessible):'
						: 'Summary (AI-generated):';
					summaryHTML = `
			  <div style="margin: 20px 0;">
				<h2 style="font-size: 18px; font-weight: bold; color: #000; margin-bottom: 12px;">${headerText}</h2>
				<ul style="margin: 0; padding-left: 20px;">
				  ${bullets.map(bullet => `<li style="margin-bottom: 6px;">${(bullet || '').replace(/^[•\-*]\s*/, '')}</li>`).join('')}
				</ul>
			  </div>
			`;
				} else {
					summaryHTML = `
			  <div style="margin: 20px 0;">
				<h2 style="font-size: 18px; font-weight: bold; color: #000; margin-bottom: 12px;">Summary:</h2>
				<p style="color: #666; font-style: italic;">Summary could not be generated for this article.</p>
			  </div>
			`;
				}
			}

			// Generate email HTML
			const emailHTML = `
		  <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; line-height: 1.6;">
			<h1 style="font-size: 24px; font-weight: bold; margin: 20px 0; color: #000;">${title}</h1>
			
			<div style="margin: 20px 0;">
			  ${parsedContent.date ? `<div style="color: #666; font-style: italic; margin-bottom: 8px;">${parsedContent.date}</div>` : ''}
			  ${parsedContent.author ? `<div style="color: #666; font-style: italic; margin-bottom: 8px;">${parsedContent.author}</div>` : ''}
			  <a href="${url}" style="color: #0066cc; text-decoration: none;">${url}</a>
			</div>
			
			${context ? `
			  <div style="border-left: 4px solid #f59e0b; padding: 12px 16px; margin: 20px 0; background: #fffbf0;">
				<strong style="color: #000;">Note:</strong> ${context}
			  </div>
			` : ''}
			
			${summaryHTML}
			
			<div style="color: #999; font-size: 14px; margin-top: 40px; padding-top: 20px; border-top: 1px solid #e5e5e5;">
			  Sent via Brief
			</div>
		  </div>
		`;

			// Send email using Resend
			const emailResponse = await fetch('https://api.resend.com/emails', {
				method: 'POST',
				headers: {
					'Authorization': `Bearer ${env.RESEND_API_KEY}`,
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({
					from: 'Brief <onboarding@resend.dev>', // Use your domain later
					to: [email],
					subject: `${getWebsiteName(site)}: ${title}`,
					html: emailHTML
				})
			});

			if (!emailResponse.ok) {
				throw new Error('Failed to send email');
			}

			return new Response(JSON.stringify({ success: true }), {
				headers: {
					'Content-Type': 'application/json',
					'Access-Control-Allow-Origin': '*'
				}
			});

		} catch (error) {
			console.error('Error:', error);
			return new Response(JSON.stringify({ error: error.message }), {
				status: 500,
				headers: {
					'Content-Type': 'application/json',
					'Access-Control-Allow-Origin': '*'
				}
			});
		}
	}
};

async function generateSummary(env, url, title, summaryLength) {
	try {
		// First, try to fetch article content
		const articleResponse = await fetch(url);

		// Check if we got a valid response
		if (!articleResponse.ok) {
			console.log(`Failed to fetch article (${articleResponse.status}): ${url}`);
			// No summary for failed requests
			return null;
		}

		const html = await articleResponse.text();

		// Check if content looks like a paywall or error page
		const lowercaseHtml = html.toLowerCase();
		const paywallIndicators = [
			'paywall', 'subscribe', 'subscription required', 'premium content',
			'sign in', 'login required', 'access denied', 'error 520',
			'cloudflare', 'blocked', 'forbidden'
		];

		const hasPaywallIndicators = paywallIndicators.some(indicator =>
			lowercaseHtml.includes(indicator)
		);

		// Basic HTML stripping (you can enhance this)
		const textContent = html
			.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
			.replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, '')
			.replace(/<[^>]+>/g, ' ')
			.replace(/\s+/g, ' ')
			.substring(0, 10000); // Limit to first 10k chars

		// If content is too short or has paywall indicators, return null (no summary)
		if (textContent.length < 200 || hasPaywallIndicators) {
			console.log('Content appears to be paywalled or insufficient, no summary available');
			return null;
		}

		const prompt = summaryLength === 'short' ? `
You are a professional news summarizer. Create a summary following these exact instructions:

INSTRUCTIONS FOR SUMMARIZING NEWS ARTICLES:
1. Output format:
   • Always produce exactly 4 concise bullet points.
   • Each bullet should capture a theme or highlight (not just facts in order).
   • Avoid repetition; each bullet should cover a distinct angle.

2. Content guidance:
   • Focus on core disputes, claims, and dismissals (legal, political, financial, etc.).
   • Highlight counteractions and outcomes (lawsuits, rulings, responses).
   • Include any notable figures/organizations pulled in (e.g., celebrities, agencies, companies).
   • Show broader fallout or support (industry, reputational, or public backing).

3. Writing style:
   • Keep each bullet to 1–2 sentences.
   • Use active voice and plain language.
   • No filler, no intro/summary text before or after the bullets.

4. Critical lens:
   • Capture both sides of the conflict where relevant.
   • Note implications or stakes (e.g., career impact, industry precedent).
   • Avoid speculation unless reported; stick to article facts.

Article Title: ${title}
Article URL: ${url}
Content: ${textContent}
	  ` : `
You are a professional news summarizer. Create a detailed 6-bullet summary of this article for informed readers who want comprehensive understanding.

RULES:
- Read and understand the full article before summarizing
- Capture only material facts from the text — no speculation or outside sources
- Use neutral, factual language without editorializing adjectives
- Condense multiple related sentences into single concise bullets where possible
- Use present tense for ongoing events, past tense for completed events
- Each bullet should be self-contained and focus on one theme

STRUCTURE:
1. Main event and context – Introduce central figure/event with relevant background
2. Key background facts – Past legal actions or milestones leading to the event
3. Current actions – Lobbying, business deals, or alliances described in the article
4. Political/legal environment – Reactions from political figures, government bodies, or regulators
5. Stakes and potential outcomes – What could happen if the event proceeds
6. Industry/competitive impact – How it could affect rivals, markets, or broader trends

FORMAT:
- 6 bullets total
- 2-3 sentences each
- 30-50 words per bullet
- Use "–" to separate the topic from details (e.g., "Topic – Details here")
- Maintain logical flow from core event to implications

Article Title: ${title}
Article URL: ${url}
Content: ${textContent}
	  `;

		// Use OpenAI via AI SDK. Model configurable via OPENAI_MODEL
		if (!env.OPENAI_API_KEY) {
			throw new Error('Missing OPENAI_API_KEY');
		}

		const openai = createOpenAI({
			apiKey: env.OPENAI_API_KEY,
		});

		const modelName = env.OPENAI_MODEL || 'gpt-5-nano';

		const { text } = await generateText({
			model: openai(modelName),
			prompt,
			maxTokens: 500,
		});

		return text;

	} catch (error) {
		console.error('Summary generation error:', error);
		return null;
	}
}

function getWebsiteName(site) {
	const siteMap = {
		'nytimes.com': 'New York Times',
		'www.nytimes.com': 'New York Times',
		'washingtonpost.com': 'Washington Post',
		'www.washingtonpost.com': 'Washington Post',
		'cnn.com': 'CNN',
		'www.cnn.com': 'CNN',
		'bbc.com': 'BBC',
		'www.bbc.com': 'BBC',
		'reuters.com': 'Reuters',
		'www.reuters.com': 'Reuters',
		'techcrunch.com': 'TechCrunch',
		'www.techcrunch.com': 'TechCrunch',
		'arstechnica.com': 'Ars Technica',
		'www.arstechnica.com': 'Ars Technica'
	};

	return siteMap[site] || (site || 'Unknown').replace('www.', '').replace('.com', '').replace(/\b\w/g, l => l.toUpperCase());
}

function parseArticleMetadata(html) {
	let author = '';
	let date = '';

	// Try to extract author
	const authorPatterns = [
		/<meta name="author" content="([^"]+)"/i,
		/<meta property="article:author" content="([^"]+)"/i,
		/<span class="[^"]*author[^"]*"[^>]*>([^<]+)</i,
		/<div class="[^"]*author[^"]*"[^>]*>([^<]+)</i,
		/<p class="[^"]*author[^"]*"[^>]*>([^<]+)</i
	];

	for (const pattern of authorPatterns) {
		const match = html.match(pattern);
		if (match) {
			author = match[1].trim();
			break;
		}
	}

	// Try to extract date
	const datePatterns = [
		/<meta property="article:published_time" content="([^"]+)"/i,
		/<meta name="publication-date" content="([^"]+)"/i,
		/<time[^>]*datetime="([^"]+)"/i,
		/<span class="[^"]*date[^"]*"[^>]*>([^<]+)</i,
		/<div class="[^"]*date[^"]*"[^>]*>([^<]+)</i
	];

	for (const pattern of datePatterns) {
		const match = html.match(pattern);
		if (match) {
			const dateStr = match[1].trim();
			try {
				const parsedDate = new Date(dateStr);
				date = parsedDate.toLocaleDateString('en-US', {
					year: 'numeric',
					month: 'long',
					day: 'numeric'
				});
			} catch (e) {
				date = dateStr;
			}
			break;
		}
	}

	return { author, date };
}

async function generateTitleBasedSummary(env, title, url, summaryLength) {
	const prompt = summaryLength === 'short' ? `
You are a professional news summarizer. This article was behind a paywall, so create a summary based only on the title and URL following these instructions:

INSTRUCTIONS FOR SUMMARIZING NEWS ARTICLES (PAYWALL VERSION):
1. Output format:
   • Always produce exactly 4 concise bullet points.
   • Each bullet should capture a theme or highlight based on what can be inferred.
   • First bullet should acknowledge limited information due to paywall.

2. Content guidance (inferred from title/URL):
   • Focus on likely core disputes, claims, or main story elements.
   • Highlight probable counteractions and outcomes based on title.
   • Include notable figures/organizations mentioned in title.
   • Show likely broader implications or industry context.

3. Writing style:
   • Keep each bullet to 1–2 sentences.
   • Use active voice and plain language.
   • No filler, no intro/summary text before or after the bullets.

4. Critical lens:
   • Base inferences only on title and URL context clues.
   • Note that details may be incomplete due to paywall.
   • Avoid excessive speculation beyond what title suggests.

Title: ${title}
URL: ${url}
  ` : `
You are a professional news summarizer. This article was behind a paywall, so create a 6-bullet summary based only on the title and URL.

RULES:
- Base summary only on the title and URL context clues
- Use neutral, factual language without editorializing adjectives
- Acknowledge this is based on limited information
- Each bullet should focus on one theme

STRUCTURE:
1. Main event and context – What the article likely covers
2. Key background – Infer relevant background from title/URL
3. Likely current actions – What actions the story probably describes
4. Political/legal context – Government or regulatory aspects suggested
5. Potential outcomes – What might happen based on title
6. Industry impact – How this might affect the sector/market

FORMAT:
- 6 bullets total
- 2-3 sentences each
- 30-50 words per bullet
- Use "–" to separate the topic from details
- Include note about paywall limitation

Title: ${title}
URL: ${url}
  `;

	try {
		if (!env.OPENAI_API_KEY) {
			throw new Error('Missing OPENAI_API_KEY');
		}

		const openai = createOpenAI({
			apiKey: env.OPENAI_API_KEY,
		});

		const modelName = env.OPENAI_MODEL || 'gpt-5-nano';

		const { text } = await generateText({
			model: openai(modelName),
			prompt,
			maxTokens: 300,
		});

		return text;

	} catch (error) {
		console.error('Title-based summary generation error:', error);
		return null;
	}
}

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
		const { url, title, site, context, aiSummary, summaryLength, email } = data;

		// Validate required fields
		if (!url || !title || !email) {
		  return new Response(JSON.stringify({ 
			error: 'Missing required fields: url, title, and email are required' 
		  }), {
			status: 400,
			headers: {
			  'Content-Type': 'application/json',
			  'Access-Control-Allow-Origin': '*'
			}
		  });
		}

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
		  const summaryText = await generateSummary(
			env.ANTHROPIC_API_KEY,
			url,
			title,
			summaryLength
		  );
		  
		  if (summaryText) {
			const bullets = summaryText.split('\n').filter(line => line.trim());
			summaryHTML = `
			  <div style="margin: 20px 0;">
				<h2 style="font-size: 18px; font-weight: bold; color: #000; margin-bottom: 12px;">Summary (AI-generated):</h2>
				<ul style="margin: 0; padding-left: 20px;">
				  ${bullets.map(bullet => `<li style="margin-bottom: 6px;">${bullet.replace(/^[•\-*]\s*/, '')}</li>`).join('')}
				</ul>
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
			  Sent via QuickCapture
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
			from: 'QuickCapture <onboarding@resend.dev>', // Use your domain later
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
  
  async function generateSummary(apiKey, url, title, summaryLength) {
	try {
	  // First, try to fetch article content
	  const articleResponse = await fetch(url);
	  
	  // Check if we got a valid response
	  if (!articleResponse.ok) {
		console.log(`Failed to fetch article (${articleResponse.status}): ${url}`);
		// Fallback to title-only summary for paywalled/restricted content
		return generateTitleBasedSummary(apiKey, title, url, summaryLength);
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

	  // If content is too short or has paywall indicators, use title-based summary
	  if (textContent.length < 200 || hasPaywallIndicators) {
		console.log('Content appears to be paywalled or insufficient, using title-based summary');
		return generateTitleBasedSummary(apiKey, title, url, summaryLength);
	  }
  
	  const prompt = `
		Article Title: ${title}
		Article URL: ${url}
		
		Content: ${textContent}
		
		Please provide a ${summaryLength === 'short' ? '3 bullet point (or fewer)' : 'up to 7 bullet point'} summary of this article.
		Make each bullet point rich and informative, capturing the key insights and important details.
		Focus on the substance and main arguments, not just surface-level facts.
		Format as bullet points, one per line, without bullet symbols.
		Do not include any preamble like "Here is a summary" - just start with the bullet points directly.
	  `;
  
	  const response = await fetch('https://api.anthropic.com/v1/messages', {
		method: 'POST',
		headers: {
		  'Content-Type': 'application/json',
		  'x-api-key': apiKey,
		  'anthropic-version': '2023-06-01'
		},
		body: JSON.stringify({
		  model: 'claude-3-haiku-20240307',
		  max_tokens: 500,
		  messages: [
			{
			  role: 'user',
			  content: prompt
			}
		  ]
		})
	  });
  
	  if (!response.ok) {
		console.error('Claude API error:', await response.text());
		return null;
	  }
  
	  const data = await response.json();
	  return data.content[0].text;
  
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
  
  return siteMap[site] || site.replace('www.', '').replace('.com', '').replace(/\b\w/g, l => l.toUpperCase());
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

async function generateTitleBasedSummary(apiKey, title, url, summaryLength) {
  const prompt = `
	Based only on this article title and URL, provide a ${summaryLength === 'short' ? '3 bullet point (or fewer)' : 'up to 7 bullet point'} summary of what this article is likely about:
	
	Title: ${title}
	URL: ${url}
	
	Note: This content was behind a paywall, so base your summary on the title and context clues from the URL.
	Make each bullet point rich and informative, providing substantial insights about what the article likely covers.
	Format as bullet points, one per line, without bullet symbols.
	Be informative but acknowledge the limitation.
	Do not include any preamble like "Here is a summary" - just start with the bullet points directly.
  `;

  try {
	const response = await fetch('https://api.anthropic.com/v1/messages', {
	  method: 'POST',
	  headers: {
		'Content-Type': 'application/json',
		'x-api-key': apiKey,
		'anthropic-version': '2023-06-01'
	  },
	  body: JSON.stringify({
		model: 'claude-3-haiku-20240307',
		max_tokens: 300,
		messages: [
		  {
			role: 'user',
			content: prompt
		  }
		]
	  })
	});

	if (!response.ok) {
	  console.error('Claude API error for title-based summary:', await response.text());
	  return null;
	}

	const data = await response.json();
	return data.content[0].text;
	
  } catch (error) {
	console.error('Title-based summary generation error:', error);
	return null;
  }
}
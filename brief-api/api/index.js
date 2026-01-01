import { generateText } from 'ai';
import { openai } from '@ai-sdk/openai';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

const json = (data, status = 200) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
  });

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') return new Response(null, { headers: CORS_HEADERS });
    if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

    try {
      const body = await request.json();
      const {
        url,
        email,
        title: inputTitle,
        context = '',
        summaryLength = 'short',
      } = body || {};

      if (!url || !email) return json({ error: 'Missing required fields: url and email are required' }, 400);
      if (!isValidEmail(email)) return json({ error: 'Invalid email address format' }, 400);

      // Derive site + title
      const { site, title } = await deriveSiteAndTitle(url, inputTitle);

      // Try to fetch and simplify page text (best-effort)
      let text = '';
      try {
        const res = await fetch(url);
        if (res.ok) {
          const html = await res.text();
          text = extractText(html);
        }
      } catch {}

      // Summarize (falls back to title-only if content is too thin)
      const summaryText = await summarize(env, { title, url, text, summaryLength });
      const summaryHTML = renderSummaryList(summaryText);

      // Compose minimal email HTML
      const emailHTML = renderEmail({ title, url, context, summaryHTML });

      // Send via Resend
      const emailResponse = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${env.RESEND_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: 'Brief <brief@send-brief.com>',
          to: [email],
          subject: `${prettySite(site)}: ${title}`,
          html: emailHTML,
        }),
      });

      if (!emailResponse.ok) throw new Error('Failed to send email');

      return json({ success: true });
    } catch (error) {
      console.error('Error:', error);
      return json({ error: error?.message || 'Unknown error' }, 500);
    }
  },
};

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

async function deriveSiteAndTitle(url, providedTitle) {
  try {
    const urlObj = new URL(url);
    const site = urlObj.hostname;
    if (providedTitle) return { site, title: providedTitle };

    // Best-effort: fetch <title>; fall back to hostname
    try {
      const res = await fetch(url);
      if (res.ok) {
        const html = await res.text();
        const m = html.match(/<title[^>]*>([^<]+)<\/title>/i);
        if (m && m[1]) return { site, title: m[1].trim() };
      }
    } catch {}
    return { site, title: site };
  } catch {
    throw new Error('Invalid URL provided');
  }
}

function extractText(html) {
  return html
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
    .replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, '')
    .replace(/<[^>]+>/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, 8000); // keep it short
}

async function summarize(env, { title, url, text, summaryLength }) {
  if (!env.OPENAI_API_KEY) throw new Error('Missing OPENAI_API_KEY');
  const provider = openai(env.OPENAI_API_KEY);
  const modelName = env.OPENAI_MODEL || 'gpt-4o-mini';

  const useLong = summaryLength !== 'short';
  const haveText = (text || '').length >= 200;

  const prompt = haveText
    ? `Summarize the article below into ${useLong ? '6' : '3'} concise, factual bullet points.
Title: ${title}
URL: ${url}
Text: ${text}`
    : `Based only on the title and URL, provide ${useLong ? '6' : '3'} cautious bullet points about what the article likely covers. Acknowledge limited information.
Title: ${title}
URL: ${url}`;

  const { text: out } = await generateText({
    model: provider(modelName),
    prompt,
    maxTokens: useLong ? 500 : 300,
  });

  return out || '';
}

function renderSummaryList(text) {
  const bullets = (text || '')
    .split('\n')
    .map((l) => l.trim())
    .filter(Boolean)
    .map((b) => b.replace(/^[•\-*]\s*/, ''));
  if (!bullets.length) return '';
  return `
    <div style="margin: 20px 0;">
      <h2 style="font-size: 16px; font-weight: 600; color: #000; margin-bottom: 8px;">Summary</h2>
      <ul style="margin: 0; padding-left: 20px;">${bullets.map((b) => `<li style="margin-bottom: 6px;">${b}</li>`).join('')}</ul>
    </div>`;
}

function renderEmail({ title, url, context, summaryHTML }) {
  return `
  <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; line-height: 1.6; color: #111;">
    <h1 style="font-size: 22px; font-weight: 700; margin: 16px 0;">${title}</h1>
    <div style="margin: 12px 0;"><a href="${url}" style="color: #0066cc; text-decoration: none;">${url}</a></div>
    ${context ? `<div style="border-left: 4px solid #f59e0b; padding: 10px 14px; margin: 16px 0; background: #fffbf0;"><strong>Note:</strong> ${context}</div>` : ''}
    ${summaryHTML}
    <div style="color: #999; font-size: 13px; margin-top: 28px; padding-top: 12px; border-top: 1px solid #eee;">Sent via Brief</div>
  </div>`;
}

function prettySite(site) {
  return (site || 'Unknown').replace(/^www\./, '').replace(/\..*$/, '').replace(/\b\w/g, (l) => l.toUpperCase());
}


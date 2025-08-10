# QuickCapture API Documentation

The QuickCapture API is built on Cloudflare Workers and provides a simple endpoint for sending article summaries to email addresses.

## Base URL
```
https://quickcapture-api.daniel-ensign.workers.dev
```

## Authentication
No authentication is required for the public API. Rate limiting may apply.

## Endpoints

### POST `/`
Send an article summary to an email address with optional AI-generated summary.

#### Request Headers
```
Content-Type: application/json
```

#### Request Body
```json
{
  "url": "string (required) - The URL of the article",
  "title": "string (required) - The title of the article", 
  "site": "string (required) - The hostname of the site (e.g., 'nytimes.com')",
  "email": "string (required) - Email address to send the summary to",
  "context": "string (optional) - Personal note or context about the article",
  "aiSummary": "boolean (optional) - Whether to generate an AI summary",
  "summaryLength": "string (optional) - 'short' (≤3 points) or 'long' (≤7 points)"
}
```

#### Example Request
```javascript
const response = await fetch('https://quickcapture-api.daniel-ensign.workers.dev', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    url: 'https://www.nytimes.com/2025/08/09/world/americas/example-article.html',
    title: 'Example Article Title',
    site: 'www.nytimes.com',
    email: 'user@example.com',
    context: 'Important article for research',
    aiSummary: true,
    summaryLength: 'short'
  })
});

const result = await response.json();
```

#### Success Response (200)
```json
{
  "success": true
}
```

#### Error Responses

**400 Bad Request - Missing Required Fields**
```json
{
  "error": "Missing required fields: url, title, and email are required"
}
```

**400 Bad Request - Invalid Email**
```json
{
  "error": "Invalid email address format"
}
```

**500 Internal Server Error**
```json
{
  "error": "Failed to send email"
}
```

## Email Format

### Subject Line
```
Website Name: Article Title
```
Example: `New York Times: Example Article Title`

### Email Body
The email is formatted as HTML with:

1. **Article Title** (large heading)
2. **Publication Date** (if available, in italics)
3. **Author(s)** (if available, in italics)  
4. **Article URL** (as clickable link)
5. **Personal Note** (if provided, in highlighted box)
6. **AI Summary** (if requested, with bullet points)
7. **Footer** ("Sent via QuickCapture")

## AI Summary Features

### Content Processing
- Attempts to fetch and parse article content from the provided URL
- Strips HTML tags and extracts readable text
- Limited to first 10,000 characters for processing

### Paywall Detection
The API automatically detects paywalled or restricted content by checking for:
- HTTP error responses (4xx, 5xx)
- Common paywall indicators: "paywall", "subscribe", "login required", etc.
- Insufficient content (less than 200 characters)

### Fallback Behavior
When content is inaccessible, the API falls back to generating a title-based summary using only:
- Article title
- URL context clues
- Acknowledgment of the limitation

### AI Model
- **Model**: Claude 3 Haiku (claude-3-haiku-20240307)
- **Provider**: Anthropic API
- **Max Tokens**: 500 for content-based summaries, 300 for title-based
- **Focus**: Rich, informative bullet points capturing key insights

## Website Name Mapping

The API includes built-in mapping for common news sites to display proper names in subject lines:

| Domain | Display Name |
|--------|-------------|
| nytimes.com | New York Times |
| washingtonpost.com | Washington Post |
| cnn.com | CNN |
| bbc.com | BBC |
| reuters.com | Reuters |
| techcrunch.com | TechCrunch |
| arstechnica.com | Ars Technica |

For unmapped domains, the API automatically formats the domain name (removes "www.", capitalizes words).

## Article Metadata Extraction

The API attempts to extract metadata from articles using multiple patterns:

### Author Extraction
- `<meta name="author" content="...">`
- `<meta property="article:author" content="...">`
- HTML elements with "author" class names

### Date Extraction  
- `<meta property="article:published_time" content="...">`
- `<meta name="publication-date" content="...">`
- `<time datetime="...">`
- HTML elements with "date" class names

Dates are automatically formatted as "Month Day, Year" (e.g., "August 9, 2025").

## Rate Limits

Currently no explicit rate limits are enforced, but Cloudflare Workers has built-in protections. Excessive usage may be throttled.

## Error Handling

The API includes comprehensive error handling for:
- Invalid or missing request parameters
- Network failures when fetching articles
- AI API failures (Anthropic)
- Email delivery failures (Resend)

All errors are returned as JSON with descriptive error messages.

## Privacy & Security

- Email addresses are used only for sending summaries and are not stored
- No user data is retained after processing
- CORS is enabled for web applications
- All communications use HTTPS

## Dependencies

The API relies on these external services:
- **Anthropic API** for AI summary generation
- **Resend API** for email delivery
- **Cloudflare Workers** for hosting and edge computing

## Status & Monitoring

- **Health**: No dedicated health endpoint (successful POST indicates healthy service)
- **Observability**: Enabled through Cloudflare Workers analytics
- **Logs**: Available in Cloudflare dashboard for debugging
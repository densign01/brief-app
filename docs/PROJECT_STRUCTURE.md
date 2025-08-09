# Project Structure

This document explains the organization and structure of the QuickCapture project.

## 📁 Repository Structure

```
quickcapture/
├── README.md                 # Main project documentation
├── LICENSE                   # MIT License
├── package.json             # NPM package configuration
├── index.html              # Main frontend application
├── bookmarklet.js          # Legacy bookmarklet code
│
├── api/                    # Backend Cloudflare Worker
│   ├── index.js           # Main Worker code
│   ├── wrangler.jsonc     # Cloudflare Worker configuration  
│   └── package.json       # Worker dependencies
│
└── docs/                   # Documentation
    ├── API.md             # API documentation
    ├── DEPLOYMENT.md      # Deployment guide
    ├── CONTRIBUTING.md    # Contribution guidelines
    ├── LANDING.md         # Marketing landing page
    ├── FAQ.md             # Frequently asked questions
    ├── SCREENSHOTS.md     # Screenshot requirements
    ├── PROJECT_STRUCTURE.md  # This file
    │
    └── screenshots/       # Documentation images
        ├── main-interface.png
        ├── settings-modal.png
        ├── email-example.png
        └── mobile-view.png
```

## 🏗️ Architecture Overview

### Frontend (`index.html`)
**Technology Stack:**
- Vanilla HTML5, CSS3, JavaScript (ES6+)
- No build process or dependencies required
- Responsive design with CSS Grid and Flexbox
- Local Storage API for email persistence

**Key Components:**
```javascript
// Main application state
let currentData = null;        // Current article data
let aiToggleState = false;     // AI summary toggle
let selectedLength = 'short';  // Summary length preference

// Core functions
analyzeUrl()                   // Extract article information
sendEmail()                    // Send to backend API
updatePreview()                // Update article preview
setupEventListeners()          // Initialize UI interactions
```

**CSS Architecture:**
- Mobile-first responsive design
- CSS custom properties for theming
- Flexbox layouts for components
- Grid layout for main structure
- No external CSS frameworks

### Backend (`api/index.js`)
**Technology Stack:**
- Cloudflare Workers (V8 JavaScript runtime)
- Web Standards APIs (fetch, Response, etc.)
- External service integrations

**Core Functions:**
```javascript
// Main request handler
async fetch(request, env, ctx)

// Article processing
async generateSummary(apiKey, url, title, summaryLength)
async generateTitleBasedSummary(apiKey, title, url, summaryLength)
parseArticleMetadata(html)

// Utilities
getWebsiteName(site)
```

**External Integrations:**
- **Anthropic API** - Claude 3 Haiku for AI summaries
- **Resend API** - Email delivery service
- **Article parsing** - HTTP fetch and HTML parsing

## 📊 Data Flow

### 1. User Interaction
```
User pastes URL → Frontend validates → Analyzes article
```

### 2. Article Processing
```
Extract title/site → Display preview → User configures options
```

### 3. Email Generation
```
Frontend sends request → Backend fetches article → AI processes content
```

### 4. Email Delivery
```
Generate HTML email → Send via Resend → Return success/error
```

## 🔧 Configuration Files

### `package.json` (Frontend)
```json
{
  "name": "quickcapture-frontend",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
```

### `api/wrangler.jsonc` (Backend)
```json
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "quickcapture-api",
  "main": "index.js",
  "compatibility_date": "2025-08-09",
  "compatibility_flags": ["global_fetch_strictly_public"],
  "observability": { "enabled": true }
}
```

## 🌐 Environment Variables

### Backend Secrets (Cloudflare Workers)
```bash
RESEND_API_KEY      # Email delivery service
ANTHROPIC_API_KEY   # AI summary generation
```

### Frontend Configuration (Optional)
```javascript
// All configuration is embedded in index.html
const API_ENDPOINT = 'https://quickcapture-api.your-domain.workers.dev';
```

## 🎨 Styling Architecture

### CSS Organization
```css
/* Global Resets */
* { box-sizing: border-box; margin: 0; padding: 0; }

/* Layout Components */
.container { /* Main app container */ }
.header { /* App header with title */ }
.content { /* Main content area */ }

/* Form Components */
.form-section { /* Input field containers */ }
.toggle-section { /* AI toggle controls */ }
.url-input-section { /* URL input area */ }

/* UI Components */
.preview-card { /* Article preview */ }
.settings-modal { /* Settings overlay */ }
.toggle-switch { /* Custom toggle component */ }

/* State Classes */
.visible { display: block; }
.disabled { opacity: 0.5; pointer-events: none; }
.loading { /* Loading states */ }
.success { /* Success messages */ }
.error { /* Error messages */ }
```

### Responsive Breakpoints
```css
/* Mobile-first approach */
/* Base styles: 320px+ (mobile) */

@media (min-width: 768px) {
  /* Tablet styles */
}

@media (min-width: 1024px) {
  /* Desktop styles */
}
```

## 🔄 API Design

### Request/Response Patterns
```javascript
// Standard request format
{
  url: string,      // Required: Article URL
  title: string,    // Required: Article title
  site: string,     // Required: Site hostname
  email: string,    // Required: User email
  context?: string, // Optional: Personal note
  aiSummary?: boolean,     // Optional: Enable AI summary
  summaryLength?: 'short' | 'long'  // Optional: Summary length
}

// Standard response format
{
  success: boolean,
  error?: string    // Present only if success is false
}
```

### Error Handling Patterns
```javascript
// Consistent error structure
try {
  // Operation
  return { success: true, data: result };
} catch (error) {
  console.error('Operation failed:', error);
  return new Response(JSON.stringify({ 
    error: error.message 
  }), { 
    status: 500,
    headers: { 
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*' 
    }
  });
}
```

## 🚀 Deployment Architecture

### Frontend (Vercel)
- **Static site** deployment
- **Global CDN** distribution
- **Automatic HTTPS** certificate
- **Custom domains** supported
- **Preview deployments** for PRs

### Backend (Cloudflare Workers)
- **Edge computing** platform
- **Global deployment** to 200+ cities
- **Automatic scaling** based on demand
- **Built-in observability** and analytics
- **Environment secrets** management

## 📱 Browser Compatibility

### Minimum Requirements
- **Chrome 60+** (2017)
- **Firefox 55+** (2017)
- **Safari 12+** (2018)
- **Edge 79+** (2020)

### Modern Web Standards Used
- **Fetch API** for HTTP requests
- **Local Storage** for email persistence
- **CSS Grid & Flexbox** for layouts
- **ES6+ JavaScript** (async/await, arrow functions)
- **Web Standards** (no polyfills required)

## 🔐 Security Considerations

### Frontend Security
- **Input validation** for URLs and email addresses
- **HTTPS enforcement** in production
- **No sensitive data storage** beyond email address
- **CORS compliance** for API requests

### Backend Security
- **Input sanitization** and validation
- **Email format validation** with regex
- **Rate limiting** (built into Cloudflare)
- **Secrets management** via Wrangler
- **HTTPS-only** communication

## 📈 Performance Characteristics

### Frontend Performance
- **Lightweight** - No external dependencies
- **Fast loading** - Single HTML file with embedded CSS/JS
- **Minimal JavaScript** - ~20KB uncompressed
- **Efficient rendering** - No virtual DOM overhead

### Backend Performance
- **Cold start** - <10ms typical
- **Response time** - <100ms for simple requests
- **AI processing** - 1-3 seconds depending on article length
- **Email delivery** - 1-5 seconds via Resend
- **Global edge** - <50ms latency worldwide

## 🧪 Testing Strategy

### Manual Testing Checklist
- [ ] URL validation and article analysis
- [ ] Email address validation
- [ ] AI summary generation (both lengths)
- [ ] Email delivery and formatting
- [ ] Mobile responsive design
- [ ] Error handling scenarios
- [ ] Cross-browser compatibility

### Automated Testing (Future)
- Unit tests for utility functions
- Integration tests for API endpoints
- E2E tests for critical user flows
- Performance testing for scalability

## 📚 Documentation Standards

### Code Documentation
- **JSDoc comments** for complex functions
- **Inline comments** for business logic
- **README files** for each major component
- **API documentation** with examples

### User Documentation
- **Getting started** guides
- **Feature explanations** with screenshots
- **Troubleshooting** guides
- **FAQ** for common questions

---

*This structure is designed for maintainability, scalability, and developer productivity while keeping the project simple and focused on core functionality.*
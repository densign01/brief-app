# Brief

Brief is a web application that allows users to save and summarize articles by sending them to their email with optional AI-generated summaries powered by Google Gemini.

## 🚀 Features

- **Article Analysis**: Paste any article URL to analyze and capture
- **Email Delivery**: Send formatted articles directly to your email
- **AI Summaries**: Optional AI-generated bullet-point summaries (short or long)
- **Privacy-First**: Your email is stored locally and never shared
- **Paywall Handling**: Smart fallback for paywalled content
- **Clean Formatting**: Professional email templates with proper styling

## 🌐 Live Demo

**Frontend**: [https://quickcapture-frontend-pdpe4ufhu-densign01s-projects.vercel.app](https://quickcapture-frontend-pdpe4ufhu-densign01s-projects.vercel.app)

## 🧩 Browser Extension

Brief is also available as a browser extension! The extension provides the same functionality in a convenient popup that works on any webpage.

### 📥 Install Browser Extension

**Chrome/Edge (Sideload)**:
1. Download or clone this repository
2. Run `./build-extension.sh` to build the extension
3. Open `chrome://extensions/` in Chrome or `edge://extensions/` in Edge
4. Enable "Developer mode" 
5. Click "Load unpacked" and select the `dist-extension` folder

**Safari**:
1. Use Xcode to create a Safari Extension App project
2. Copy files from `dist-extension/` to the extension bundle
3. Build and install via Xcode

### 🎯 Extension Features
- **One-click capture** from any webpage
- **Automatic page detection** of URL and title
- **Right-click context menu** integration
- **Keyboard shortcut** (Cmd/Ctrl + Shift + Q)
- **Same AI features** as the web app

## 📱 How to Use

1. **Paste Article URL** - Enter the URL of any article you want to save
2. **Analyze Article** - Click to extract article information
3. **Enter Email** - Provide your email address (saved locally for convenience)
4. **Add Context** (Optional) - Include personal notes about the article
5. **Enable AI Summary** (Optional) - Choose between short (≤3 points) or long (≤7 points) summaries
6. **Send to Email** - Receive a beautifully formatted email with the article

## 🏗️ Architecture

### Frontend (Vercel)
- **Technology**: Vanilla HTML, CSS, JavaScript
- **Hosting**: Vercel
- **Features**: 
  - URL analysis and preview
  - Email configuration with local storage
  - Settings modal
  - Responsive design

### Backend (Cloudflare Workers)
- **Technology**: Cloudflare Workers
- **AI Model**: Gemini 2.0 Flash (via Google Gemini API)
- **Email Service**: Resend API
- **Features**:
  - Article content scraping
  - Paywall detection and fallback
  - AI summary generation
  - Email template rendering
  - CORS handling

## 🔧 Technical Details

### Email Format
Emails are sent with the subject format: `Website Name: Article Title`

Each email includes:
- Article title, author, and date (when available)
- Direct link to the original article
- User's optional context note
- AI-generated summary (when enabled)
- Clean, professional styling

### AI Summary Features
- **Paywall Handling**: Falls back to title-based summaries for restricted content
- **Error Recovery**: Graceful handling of API failures
- **Content Validation**: Checks for insufficient or blocked content
- **Smart Prompting**: Instructs AI to avoid preambles and jump straight to bullet points

### API Endpoints

#### POST `/` (Backend)
Send article to email with optional AI summary.

**Request Body:**
```json
{
  "url": "https://example.com/article",
  "title": "Article Title",
  "site": "example.com",
  "email": "user@example.com",
  "context": "Optional note",
  "aiSummary": true,
  "summaryLength": "short"
}
```

**Response:**
```json
{
  "success": true
}
```

## 🚀 Deployment

### Frontend (Vercel)
```bash
cd brief-web
npm init -y
vercel --prod
```

### Backend (Cloudflare Workers)
```bash
cd brief-api
wrangler deploy
```

Required environment variables for the Worker:
- `RESEND_API_KEY`: Your Resend API key
- `GOOGLE_API_KEY`: Your Google Gemini API key

## 🎯 Future Enhancements

- [ ] **Mobile Apps**: iOS and Android versions
- [x] **Browser Extensions**: Chrome, Safari, Firefox extensions
- [ ] **Better Article Parsing**: Integration with Readability.js or similar
- [ ] **Custom Email Templates**: User-customizable formatting
- [ ] **Batch Processing**: Handle multiple articles at once
- [ ] **Reading Lists**: Save articles for later processing
- [ ] **Team Features**: Shared reading lists and collaboration
- [ ] **Analytics**: Usage insights and reading statistics

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🔐 Privacy

- Your email address is stored only in your browser's local storage
- No user data is collected or stored on our servers
- Email addresses are used only for sending article summaries
- AI processing is handled through Google Gemini's API

## 🛠️ Development

To run locally:

1. **Frontend**: Open `index.html` in your browser or serve with any static server
2. **Backend**: Use `wrangler dev` for local development

## 📞 Support

For issues or feature requests, please create an issue in this repository.

---

Built with ❤️ for better reading and knowledge management.

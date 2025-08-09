# Contributing to QuickCapture

Thank you for your interest in contributing to QuickCapture! This document provides guidelines for contributing to the project.

## 🤝 How to Contribute

### Reporting Issues
- **Check existing issues** first to avoid duplicates
- **Use clear, descriptive titles** for bug reports and feature requests
- **Provide detailed information** including:
  - Steps to reproduce (for bugs)
  - Expected vs actual behavior
  - Browser/environment details
  - Screenshots if applicable

### Suggesting Features
- **Search existing issues** for similar feature requests
- **Explain the use case** and why the feature would be valuable
- **Consider backwards compatibility** and implementation complexity
- **Be open to discussion** about alternative approaches

## 🚀 Development Setup

### Prerequisites
- Node.js 18+
- Git
- Code editor (VS Code recommended)

### Local Setup
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/quickcapture.git
cd quickcapture

# Install dependencies
npm install

# For backend development
cd api/
npm install -g wrangler
wrangler login

# For frontend development  
# Open index.html in browser or use:
python -m http.server 8000
```

### Environment Configuration
Create necessary API keys for testing:
- Resend API key (for email testing)
- Anthropic API key (for AI summary testing)

```bash
# Set up Worker secrets for local testing
wrangler secret put RESEND_API_KEY
wrangler secret put ANTHROPIC_API_KEY
```

## 🛠️ Making Changes

### Code Style
- **Use consistent formatting** (Prettier recommended)
- **Follow existing code patterns** in the codebase
- **Write clear, descriptive variable and function names**
- **Add comments for complex logic**

### Frontend Guidelines
- **Vanilla JavaScript** - no frameworks required
- **Responsive design** - ensure mobile compatibility
- **Accessibility** - follow WCAG guidelines
- **Performance** - optimize for fast loading

### Backend Guidelines
- **Cloudflare Workers** environment constraints
- **Error handling** - comprehensive error responses
- **Security** - validate all inputs
- **Performance** - minimize cold start time

### Commit Messages
Use clear, descriptive commit messages:
```
feat: add dark mode toggle to settings
fix: resolve email validation edge case
docs: update API documentation for new endpoint
refactor: simplify article parsing logic
```

## 🧪 Testing

### Manual Testing
- **Test core functionality** (URL analysis, email sending)
- **Test error scenarios** (invalid URLs, network failures)
- **Test across browsers** (Chrome, Firefox, Safari)
- **Test on mobile devices**

### API Testing
```bash
# Test the API endpoint
curl -X POST http://localhost:8787 \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/article",
    "title": "Test Article", 
    "site": "example.com",
    "email": "test@example.com"
  }'
```

### Frontend Testing
- Open `index.html` in multiple browsers
- Test with real article URLs
- Verify email delivery
- Test error handling (network offline, invalid URLs)

## 📝 Pull Request Process

### Before Submitting
1. **Fork the repository** and create a feature branch
2. **Make your changes** following the guidelines above
3. **Test thoroughly** on your local environment
4. **Update documentation** if needed
5. **Write clear commit messages**

### PR Guidelines
- **Use descriptive titles** and detailed descriptions
- **Reference related issues** (e.g., "Fixes #123")
- **Include screenshots** for UI changes
- **List any breaking changes**
- **Request specific reviewers** if you know who should review

### PR Template
```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature  
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement

## Testing
- [ ] Manual testing completed
- [ ] Cross-browser testing done
- [ ] Mobile testing done
- [ ] API testing completed

## Screenshots
(Include screenshots for UI changes)

## Additional Notes
Any additional context or considerations.
```

## 🎯 Areas for Contribution

### High Priority
- **Mobile app development** (React Native, Flutter)
- **Browser extensions** (Chrome, Firefox, Safari)
- **Better article parsing** (Readability.js integration)
- **User authentication** and personal reading lists
- **Improved error handling** and user feedback

### Medium Priority
- **Additional AI models** (OpenAI, local models)
- **Email template customization**
- **Analytics and usage tracking**
- **Internationalization** (i18n)
- **Performance optimizations**

### Nice to Have
- **Dark mode** implementation
- **Keyboard shortcuts**
- **Batch article processing**
- **Social sharing features**
- **Reading time estimates**

## 🏗️ Architecture Overview

### Frontend (`index.html`)
- **Single-page application** with vanilla JavaScript
- **Local storage** for email persistence
- **Fetch API** for backend communication
- **Responsive CSS** with mobile-first design

### Backend (`api/index.js`)
- **Cloudflare Workers** serverless function
- **Event-driven architecture** with async/await
- **External API integrations** (Anthropic, Resend)
- **Error handling** with detailed logging

### Key Components
- **Article analysis**: URL parsing and content extraction
- **AI summaries**: Claude 3 Haiku integration
- **Email delivery**: Resend API with HTML templates
- **Paywall detection**: Smart fallback mechanisms

## 🔧 Development Tips

### Debugging
```bash
# View Worker logs in real-time
wrangler tail your-worker-name

# Test Worker locally
cd api/ && wrangler dev

# Debug frontend in browser DevTools
```

### Common Patterns
```javascript
// Error handling pattern
try {
  const result = await someAsyncOperation();
  return { success: true, data: result };
} catch (error) {
  console.error('Operation failed:', error);
  return { success: false, error: error.message };
}

// CORS response pattern
return new Response(JSON.stringify(data), {
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
  }
});
```

## 📚 Resources

### Documentation
- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Vercel Documentation](https://vercel.com/docs)
- [Anthropic API Docs](https://docs.anthropic.com/)
- [Resend API Docs](https://resend.com/docs)

### Tools
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/)
- [Vercel CLI](https://vercel.com/docs/cli)
- [VS Code](https://code.visualstudio.com/)
- [Postman](https://www.postman.com/) for API testing

## 🎉 Recognition

Contributors will be:
- **Listed in the README** contributors section
- **Mentioned in release notes** for significant contributions
- **Invited to join** the core team for consistent contributors

## ❓ Questions?

- **Create an issue** for technical questions
- **Start a discussion** for broader topics
- **Check existing documentation** first
- **Be respectful and constructive** in all interactions

## 📄 License

By contributing to QuickCapture, you agree that your contributions will be licensed under the [MIT License](../LICENSE).

---

Thank you for helping make QuickCapture better! 🚀
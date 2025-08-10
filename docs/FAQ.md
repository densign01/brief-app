# Frequently Asked Questions (FAQ)

## 🚀 **Getting Started**

### **Q: How do I start using QuickCapture?**
A: Simply visit the [live demo](https://quickcapture-frontend-mqijk85sg-densign01s-projects.vercel.app), paste an article URL, enter your email address, and click "Send to Email". No account required!

### **Q: What types of URLs work with QuickCapture?**
A: QuickCapture works with most article URLs including:
- News websites (NY Times, Washington Post, CNN, BBC)
- Blog posts and Medium articles
- Technical documentation and tutorials
- Research papers and academic articles
- Most text-based content online

### **Q: Do I need to create an account?**
A: No! QuickCapture is designed to work without any account creation. Your email address is stored locally on your device for convenience.

---

## 📧 **Email & Delivery**

### **Q: How quickly will I receive the email?**
A: Emails are typically delivered within 5-10 seconds. Delivery time may vary based on your email provider and internet connection.

### **Q: Why didn't I receive the email?**
A: Check these common issues:
- **Spam folder** - QuickCapture emails might be filtered
- **Email address** - Ensure it's typed correctly
- **Internet connection** - Verify your connection is stable
- **Email provider** - Some providers have delays

### **Q: What email format do I receive?**
A: You'll receive a professionally formatted HTML email with:
- Clean subject line: "Website Name: Article Title"
- Article metadata (author, date when available)
- Direct link to the original article
- Your personal notes (if added)
- AI summary (if requested)
- QuickCapture footer

### **Q: Can I customize the email format?**
A: Currently, the email format is standardized for consistency. Custom templates are planned for a future release.

---

## 🤖 **AI Summaries**

### **Q: How do AI summaries work?**
A: QuickCapture uses Claude 3 Haiku to analyze article content and generate intelligent bullet-point summaries. The AI focuses on key insights, main arguments, and important details.

### **Q: What's the difference between "Short" and "Long" summaries?**
A: 
- **Short**: 3 bullet points or fewer, ideal for quick overviews
- **Long**: Up to 7 bullet points, providing more comprehensive analysis

### **Q: Why does my summary say it's based on the title only?**
A: This happens when the article content is behind a paywall or access restriction. QuickCapture automatically falls back to generating insights based on the title and URL context.

### **Q: How accurate are the AI summaries?**
A: Claude 3 Haiku provides high-quality summaries, but AI-generated content should always be verified against the original source. Summaries are clearly marked as "AI-generated" in emails.

### **Q: Can I turn off AI summaries?**
A: Yes! Simply leave the "AI Summary" toggle off when sending articles. You'll receive just the article information and your personal notes.

---

## 🔒 **Privacy & Security**

### **Q: Is my data safe with QuickCapture?**
A: Yes! QuickCapture is built with privacy-first principles:
- Your email address is stored only on your device
- No user accounts or data collection
- Article content is processed temporarily and not stored
- All communications use HTTPS encryption

### **Q: What information does QuickCapture store?**
A: QuickCapture stores:
- **On your device**: Your email address in browser local storage
- **On servers**: Nothing! No user data is retained after processing

### **Q: Can QuickCapture see my email content?**
A: No. QuickCapture only sends emails through the Resend service. We cannot access your inbox or read your emails.

### **Q: What happens to the articles I process?**
A: Article content is fetched temporarily to generate summaries, then discarded. No article content or URLs are stored in our systems.

---

## 🛠️ **Technical Issues**

### **Q: The website isn't loading. What should I do?**
A: Try these troubleshooting steps:
1. Refresh the page (Ctrl+F5 or Cmd+Shift+R)
2. Clear your browser cache
3. Try a different browser or incognito/private mode
4. Check your internet connection
5. Try again in a few minutes (may be temporary server issue)

### **Q: I'm getting a "Failed to send email" error. Why?**
A: This could be due to:
- **Temporary server issue** - Try again in a few minutes
- **Invalid email format** - Double-check your email address
- **Network connectivity** - Check your internet connection
- **Service maintenance** - Check our status page or GitHub issues

### **Q: The article preview isn't showing. What's wrong?**
A: Common causes:
- **Invalid URL** - Ensure the URL is complete and correct
- **Network issues** - Check your internet connection
- **Unsupported content** - Some dynamic sites may not work
- Try copying the URL directly from the address bar

### **Q: Can I use QuickCapture on mobile devices?**
A: Yes! QuickCapture is fully responsive and works great on phones and tablets. The interface automatically adapts to your screen size.

---

## 💡 **Features & Usage**

### **Q: Can I save multiple articles at once?**
A: Currently, QuickCapture processes one article at a time. Batch processing is on our roadmap for future releases.

### **Q: How do I organize my saved articles?**
A: Since articles are sent to your email, you can:
- Create email folders/labels for different topics
- Use your email's search functionality
- Add descriptive context notes to help with searching
- Set up email filters based on subject line patterns

### **Q: Can I share articles with team members?**
A: Yes! You can:
- Enter multiple email addresses separated by commas (if supported by your email)
- Forward the received emails to team members
- Copy the formatted content for sharing elsewhere
- Add context notes explaining why the article is relevant

### **Q: What if an article is behind a paywall?**
A: QuickCapture intelligently detects paywalled content and:
- Generates a title-based summary using available information
- Clearly indicates the limitation in the summary
- Still provides valuable context about what the article likely covers
- Includes the direct link so you can access it with your subscription

---

## 🚀 **Advanced Usage**

### **Q: Can I integrate QuickCapture with other tools?**
A: Currently, QuickCapture is a standalone web application. API access and integrations are planned for future releases.

### **Q: Is there a browser extension available?**
A: Not yet, but browser extensions for Chrome, Firefox, and Safari are high-priority items on our roadmap.

### **Q: Can I self-host QuickCapture?**
A: Yes! QuickCapture is open source. See our [deployment guide](DEPLOYMENT.md) for instructions on running your own instance.

### **Q: How can I contribute to QuickCapture?**
A: We welcome contributions! Check out our [contributing guide](CONTRIBUTING.md) for ways to help:
- Report bugs and suggest features
- Improve documentation
- Submit code improvements
- Help with testing and feedback

---

## 📈 **Limitations & Future Plans**

### **Q: What are the current limitations?**
A: Current limitations include:
- One article at a time processing
- Limited email template customization
- No user accounts or reading history
- Some dynamic websites may not parse correctly

### **Q: What features are planned for the future?**
A: Our roadmap includes:
- **Mobile apps** for iOS and Android
- **Browser extensions** for one-click saving
- **Batch processing** for multiple articles
- **Custom email templates** and formatting options
- **Reading lists** and organization features
- **Team collaboration** tools

### **Q: How often is QuickCapture updated?**
A: QuickCapture is actively maintained with regular updates for bug fixes, performance improvements, and new features. Check our GitHub repository for the latest releases.

---

## 💳 **Pricing & Usage**

### **Q: Is QuickCapture free to use?**
A: Yes! QuickCapture is completely free for personal use. There are no hidden costs, premium tiers, or usage limits for individual users.

### **Q: Are there any usage limits?**
A: For fair use, there may be reasonable rate limits to prevent abuse, but these shouldn't affect normal usage patterns.

### **Q: Will QuickCapture always be free?**
A: The core functionality will remain free. We may introduce premium features for teams or enterprises in the future, but individual use will stay free.

---

## 🤝 **Support & Community**

### **Q: How can I get help with QuickCapture?**
A: Several support options are available:
- Check this FAQ for common questions
- Browse our [documentation](README.md)
- Search [existing GitHub issues](https://github.com/USERNAME/quickcapture/issues)
- Create a new issue for bugs or feature requests
- Join our [community discussions](https://github.com/USERNAME/quickcapture/discussions)

### **Q: How can I stay updated on new features?**
A: 
- ⭐ **Star the GitHub repository** to get notifications
- 👀 **Watch the repository** for all updates
- 🐦 **Follow us on social media** (if applicable)
- 📧 **Check release notes** for new versions

### **Q: Can I request specific features?**
A: Absolutely! We love hearing from users. Please:
- Search existing feature requests first
- Create a detailed GitHub issue explaining your use case
- Join discussions to vote on and refine feature ideas
- Consider contributing code if you're a developer

---

## 🔄 **Still Have Questions?**

If your question isn't answered here:

1. **Search our documentation** in the `/docs` folder
2. **Check GitHub issues** for similar questions
3. **Create a new issue** with the "question" label
4. **Start a discussion** in our GitHub discussions

We're always happy to help and improve QuickCapture based on user feedback!

---

*Last updated: August 2025*
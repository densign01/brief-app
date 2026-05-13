# QuickCapture iOS Shortcut Setup Guide

## Current Status ✅

Your QuickCapture API has been successfully updated with Vercel AI SDK and deployed to:
**https://quickcapture-api.daniel-ensign.workers.dev**

## Next Steps to Complete Setup

### 1. Add API Keys to Cloudflare Worker

You need to add your AI provider API keys as secrets:

```bash
cd quickcapture-api
wrangler secret put GOOGLE_API_KEY
```

**Get these keys:**
- **Google Gemini API Key**: Create an API key in [Google AI Studio](https://aistudio.google.com/) for Gemini access

Brief now sends email through Cloudflare Email Sending. Before deploying, make sure `send-brief.com` is onboarded in Cloudflare Email Sending and that the Worker has the `EMAIL` binding from `wrangler.jsonc`.

### 2. Create iOS Shortcut (Simplified!)

**On your iPhone/iPad:**

1. **Open Shortcuts app** → Tap "+" to create new shortcut

2. **Add these actions in order:**

   **Action 1: Get My Shortcuts**
   - Search "Get My Shortcuts" → Add it

   **Action 2: Get URLs from Input**
   - Search "Get URLs from Input" → Add it
   - Connect to previous action

   **Action 3: Ask for Input**
   - Search "Ask for Input" → Add it
   - Set Input Type: Text
   - Set Prompt: "Email address"
   - Set Default Answer: your@email.com

   **Action 4: Get Contents of URL**
   - Search "Get Contents of URL" → Add it
   - Set URL: `https://quickcapture-api.daniel-ensign.workers.dev`
   - Set Method: POST
   - Add Headers: `Content-Type = application/json`
   - Set Request Body (JSON):
   ```json
   {
     "url": "[URL from Get URLs]",
     "email": "[Provided Input]"
   }
   ```

   **Action 5: Show Result**
   - Search "Show Result" → Add it
   - Connect to previous action

3. **Configure Shortcut:**
   - Name it "Brief Article"
   - Set icon (optional)
   - Enable "Use with Share Sheet"
   - Set accepted types: URLs, Safari Web Pages

4. **Save the shortcut**

**That's it! Much simpler - the server now handles:**
- ✅ Title extraction from the webpage
- ✅ Domain parsing from URL
- ✅ Default AI summary settings
- ✅ All the complex logic

### 3. Test the Setup

1. **Open Safari** → Go to any news article
2. **Tap Share button** → Find "Brief Article" 
3. **Enter your email** → Tap Done
4. **Check your email** for the article with AI summary

### 4. Configure Google Gemini (Default)

The API uses Google Gemini directly by default.

- Required secret: `GOOGLE_API_KEY`
Example:
```bash
wrangler secret put GOOGLE_API_KEY
wrangler deploy
```

## Troubleshooting

### "Missing GOOGLE_API_KEY"
- Add the `GOOGLE_API_KEY` secret

### "Failed to send email"
- Check that Cloudflare Email Sending is enabled for `send-brief.com`
- Check that `brief@send-brief.com` is an allowed sender for the Worker `EMAIL` binding
- Verify the email address format is valid

### Shortcut not appearing in Share Sheet
- Make sure "Use with Share Sheet" is enabled
- Restart the Shortcuts app
- Check that accepted types include URLs and Safari Web Pages

### API errors
- Check Cloudflare Workers logs: `wrangler tail`
- Verify your API keys are active and have sufficient credits

## Features

✅ **One-tap article capture** from any iOS app  
✅ **AI-powered summaries** (short or long)  
✅ **Email delivery** with clean formatting  
✅ **Paywall handling** with fallback summaries  
✅ **Gemini AI summary support**
✅ **Privacy-first** - no data stored on servers  

## Support

- **Cloudflare Workers Dashboard**: [dash.cloudflare.com](https://dash.cloudflare.com)
- **API Logs**: `wrangler tail` in the project directory
- **Test API directly**: Use curl or Postman with the endpoint

---

*Built with Vercel AI SDK for flexible AI provider switching*

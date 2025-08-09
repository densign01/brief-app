# Deployment Guide

This guide covers deploying both the frontend and backend components of QuickCapture.

## Prerequisites

- Node.js 18+ installed
- Git installed
- Accounts for:
  - [Vercel](https://vercel.com) (for frontend)
  - [Cloudflare](https://cloudflare.com) (for backend API)
  - [Resend](https://resend.com) (for email delivery)
  - [Anthropic](https://console.anthropic.com) (for AI summaries)

## API Keys Required

Before deployment, obtain these API keys:

1. **Resend API Key**
   - Sign up at [resend.com](https://resend.com)
   - Go to API Keys section
   - Create a new API key

2. **Anthropic API Key**
   - Sign up at [console.anthropic.com](https://console.anthropic.com)
   - Go to API Keys section
   - Create a new API key

## Backend Deployment (Cloudflare Workers)

### 1. Install Wrangler CLI
```bash
npm install -g wrangler
```

### 2. Authenticate with Cloudflare
```bash
wrangler login
```
Follow the browser prompts to authenticate.

### 3. Configure Environment Variables
Navigate to the API directory and set up secrets:

```bash
cd api/
wrangler secret put RESEND_API_KEY
# Enter your Resend API key when prompted

wrangler secret put ANTHROPIC_API_KEY  
# Enter your Anthropic API key when prompted
```

### 4. Deploy the Worker
```bash
wrangler deploy
```

The worker will be deployed to a URL like:
```
https://quickcapture-api.your-subdomain.workers.dev
```

### 5. Test the Deployment
```bash
curl -X POST https://your-worker-url.workers.dev \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "title": "Test Article",
    "site": "example.com",
    "email": "your-email@example.com"
  }'
```

## Frontend Deployment (Vercel)

### 1. Install Vercel CLI
```bash
npm install -g vercel
```

### 2. Authenticate with Vercel
```bash
vercel login
```

### 3. Update API Endpoint
Edit `index.html` and update the API endpoint to your deployed Worker URL:

```javascript
// In the sendEmail function, update this line:
const response = await fetch('https://your-worker-url.workers.dev', {
```

### 4. Deploy to Vercel
From the project root directory:
```bash
vercel --prod
```

Follow the prompts:
- Link to existing project or create new: **Create new**
- Project name: `quickcapture` (or your preference)
- Directory: **Keep default (current directory)**

### 5. Configure Custom Domain (Optional)
In the Vercel dashboard:
1. Go to your project settings
2. Navigate to "Domains"
3. Add your custom domain
4. Follow DNS configuration instructions

## Environment-Specific Configuration

### Development
For local development:

```bash
# Backend (API)
cd api/
wrangler dev

# Frontend
# Simply open index.html in browser or use:
python -m http.server 8000
```

### Staging
Create a staging environment:

```bash
# Deploy to staging
wrangler deploy --name quickcapture-api-staging
vercel --prod --scope your-team
```

### Production
Use the deployment steps above for production deployment.

## Custom Domains

### Backend (Cloudflare)
1. In Cloudflare dashboard, go to Workers & Pages
2. Select your worker
3. Go to Settings > Triggers
4. Add custom domain

### Frontend (Vercel)
1. In Vercel dashboard, go to project settings
2. Navigate to Domains
3. Add your custom domain
4. Update DNS records as instructed

## Environment Variables & Secrets

### Backend Secrets (Cloudflare)
```bash
# Required secrets
wrangler secret put RESEND_API_KEY
wrangler secret put ANTHROPIC_API_KEY

# Optional: Custom email domain
wrangler secret put EMAIL_DOMAIN
```

### Frontend Environment Variables (Vercel)
If needed, add environment variables in Vercel dashboard:
- Go to Project Settings > Environment Variables
- Add variables for different environments

## Monitoring & Observability

### Cloudflare Workers Analytics
- Real-time metrics in Cloudflare dashboard
- Request volume, error rates, response times
- Geographic distribution of requests

### Vercel Analytics
- Page views and performance metrics
- Available in Vercel dashboard
- Can be enhanced with Vercel Analytics package

## Scaling Considerations

### Backend (Cloudflare Workers)
- Automatically scales to handle traffic
- 100,000 requests/day on free tier
- No server management required
- Global edge deployment

### Frontend (Vercel)
- Global CDN distribution
- Automatic HTTPS
- Instant cache invalidation
- No configuration needed for scaling

## Backup & Disaster Recovery

### Code Backup
- Source code is backed up in Git repository
- Deploy keys and secrets should be documented securely

### Configuration Backup
```bash
# Export Worker configuration
wrangler whoami
wrangler secret list

# Document API keys in secure location
```

## Troubleshooting

### Common Issues

**Worker deployment fails:**
```bash
# Check authentication
wrangler whoami

# Verify wrangler.jsonc configuration
# Ensure required secrets are set
wrangler secret list
```

**Frontend API calls fail:**
- Verify CORS headers in Worker
- Check API endpoint URL in frontend code
- Inspect browser network tab for errors

**Email delivery fails:**
- Verify Resend API key is correct
- Check Resend dashboard for delivery status
- Ensure "from" email domain is verified in Resend

**AI summaries not working:**
- Verify Anthropic API key
- Check API usage limits
- Review Worker logs for AI API errors

### Debugging

**View Worker Logs:**
```bash
wrangler tail your-worker-name
```

**Test Worker Locally:**
```bash
cd api/
wrangler dev
```

**View Vercel Deployment Logs:**
- Check deployment logs in Vercel dashboard
- Use Vercel CLI: `vercel logs`

## Security Best Practices

1. **API Keys:** Never commit API keys to version control
2. **HTTPS:** Always use HTTPS in production
3. **CORS:** Configure CORS appropriately for your domains
4. **Rate Limiting:** Consider implementing rate limiting for production
5. **Input Validation:** The API includes basic validation, but consider additional checks

## Cost Optimization

### Cloudflare Workers
- Free tier: 100,000 requests/day
- Paid: $5/month for 10 million requests
- Consider caching strategies for frequently accessed content

### Vercel
- Free tier: Generous limits for personal projects
- Pro: $20/month for enhanced features
- Monitor bandwidth usage

### External APIs
- **Anthropic:** Pay-per-use, monitor token usage
- **Resend:** Free tier includes 3,000 emails/month

## Updates & Maintenance

### Automated Deployments
Set up GitHub Actions for automated deployments:

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: npm install -g wrangler vercel
      - run: wrangler deploy
      - run: vercel --prod --token ${{ secrets.VERCEL_TOKEN }}
```

### Dependency Updates
```bash
# Update Wrangler
npm update -g wrangler

# Update Vercel CLI  
npm update -g vercel
```

### Health Monitoring
Consider setting up monitoring:
- Uptime monitoring (e.g., Pingdom, UptimeRobot)
- Error alerting (e.g., Sentry)
- Performance monitoring (built into Cloudflare/Vercel)
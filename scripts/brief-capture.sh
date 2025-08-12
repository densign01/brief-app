#!/bin/bash

# Brief Article Capture Script
# Usage: ./brief-capture.sh "https://example.com/article" "your@email.com"

URL="$1"
EMAIL="$2"
API_ENDPOINT="https://quickcapture-api.daniel-ensign.workers.dev"

if [ -z "$URL" ] || [ -z "$EMAIL" ]; then
    echo "Usage: $0 <URL> <EMAIL>"
    echo "Example: $0 'https://example.com/article' 'you@email.com'"
    exit 1
fi

# Extract site from URL
SITE=$(echo "$URL" | sed -E 's|https?://([^/]+).*|\1|')

# Get page title using curl (basic extraction)
TITLE=$(curl -s "$URL" | grep -o '<title[^>]*>[^<]*' | sed 's/<title[^>]*>//' | head -1)

if [ -z "$TITLE" ]; then
    TITLE="Article from $SITE"
fi

echo "Capturing article..."
echo "URL: $URL"
echo "Title: $TITLE"
echo "Email: $EMAIL"

# Send to Brief API
RESPONSE=$(curl -s -X POST "$API_ENDPOINT" \
    -H "Content-Type: application/json" \
    -d "{
        \"url\": \"$URL\",
        \"title\": \"$TITLE\",
        \"site\": \"$SITE\",
        \"context\": \"\",
        \"aiSummary\": true,
        \"summaryLength\": \"short\",
        \"email\": \"$EMAIL\"
    }")

if echo "$RESPONSE" | grep -q '"success":true'; then
    echo "✅ Article sent successfully!"
else
    echo "❌ Failed to send article"
    echo "Response: $RESPONSE"
fi
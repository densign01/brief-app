// Content script for Brief Safari extension
// This script runs on all web pages

// Extract page metadata
function getPageMetadata() {
  const url = window.location.href;
  const title = document.title;
  const site = window.location.hostname;
  
  // Try to get better title from meta tags or headers
  let betterTitle = title;
  
  // Check for Open Graph title
  const ogTitle = document.querySelector('meta[property="og:title"]');
  if (ogTitle && ogTitle.content) {
    betterTitle = ogTitle.content;
  }
  
  // Check for Twitter title
  const twitterTitle = document.querySelector('meta[name="twitter:title"]');
  if (twitterTitle && twitterTitle.content && !ogTitle) {
    betterTitle = twitterTitle.content;
  }
  
  // Check for article title
  const articleTitle = document.querySelector('h1');
  if (articleTitle && articleTitle.textContent.trim() && articleTitle.textContent.trim().length > 10) {
    betterTitle = articleTitle.textContent.trim();
  }
  
  return {
    url,
    title: betterTitle,
    site,
    description: getPageDescription(),
    canonical: getCanonicalUrl()
  };
}

function getPageDescription() {
  // Try to get description from meta tags
  const ogDescription = document.querySelector('meta[property="og:description"]');
  if (ogDescription && ogDescription.content) {
    return ogDescription.content;
  }
  
  const metaDescription = document.querySelector('meta[name="description"]');
  if (metaDescription && metaDescription.content) {
    return metaDescription.content;
  }
  
  // Fallback to first paragraph
  const firstP = document.querySelector('p');
  if (firstP && firstP.textContent.trim()) {
    return firstP.textContent.trim().substring(0, 200) + '...';
  }
  
  return '';
}

function getCanonicalUrl() {
  const canonical = document.querySelector('link[rel="canonical"]');
  return canonical ? canonical.href : window.location.href;
}

// Listen for messages from popup or background script
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'getPageMetadata') {
    const metadata = getPageMetadata();
    sendResponse(metadata);
  }
  
  if (request.action === 'highlightSelection') {
    // Get selected text if any
    const selection = window.getSelection().toString().trim();
    sendResponse({ selectedText: selection });
  }
});

// Optional: Add right-click context menu detection
document.addEventListener('contextmenu', (e) => {
  // Store the element that was right-clicked for potential use
  window.lastContextTarget = e.target;
});

// Optional: Keyboard shortcut listener
document.addEventListener('keydown', (e) => {
  // Ctrl/Cmd + Shift + Q to trigger Brief
  if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'Q') {
    e.preventDefault();
    
    // Send message to background script to open popup
    chrome.runtime.sendMessage({ action: 'openBrief' });
  }
});
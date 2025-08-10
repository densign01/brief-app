// Service worker for Brief Safari extension (Manifest V3)
chrome.runtime.onInstalled.addListener(() => {
  console.log('Brief extension installed');
  
  // Create context menu item (with error handling)
  try {
    if (chrome.contextMenus) {
      chrome.contextMenus.create({
        id: 'brief-page',
        title: 'Send page to Brief',
        contexts: ['page']
      });
    }
  } catch (error) {
    console.log('Context menu creation failed:', error);
  }
});

// Handle action clicks (Manifest V3 equivalent of browserAction)
chrome.action.onClicked.addListener((tab) => {
  // This will open the popup, no additional action needed
  console.log('Brief clicked for tab:', tab.url);
});

// Handle messages from content script or popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'getPageInfo') {
    // Get current tab information
    chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
      if (tabs[0]) {
        const pageInfo = {
          url: tabs[0].url,
          title: tabs[0].title,
          site: new URL(tabs[0].url).hostname
        };
        sendResponse(pageInfo);
      }
    });
    return true; // Keep message channel open for async response
  }
  
  if (request.action === 'sendToAPI') {
    // Handle API requests from popup
    fetch('https://quickcapture-api.daniel-ensign.workers.dev', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(request.data)
    })
    .then(response => {
      console.log('API Response Status:', response.status);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      return response.json();
    })
    .then(result => {
      console.log('API Response Data:', result);
      sendResponse({ success: true, data: result });
    })
    .catch(error => {
      console.error('API Error:', error);
      sendResponse({ success: false, error: error.message });
    });
    return true; // Keep message channel open for async response
  }
});

// Context menu click handler (with error handling)
if (chrome.contextMenus) {
  chrome.contextMenus.onClicked.addListener((info, tab) => {
    if (info.menuItemId === 'brief-page') {
      // In Manifest V3, we can't programmatically open popup
      // User needs to click the extension icon
      console.log('Context menu clicked - user should click extension icon');
    }
  });
}
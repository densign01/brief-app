// Popup script for Brief Safari extension
let currentData = null;
let aiToggleState = false;
let selectedLength = 'short';

// Initialize popup when opened
document.addEventListener('DOMContentLoaded', async () => {
    // Load saved email from extension storage
    chrome.storage.sync.get(['brief-email'], (result) => {
        if (result['brief-email']) {
            document.getElementById('email').value = result['brief-email'];
        }
    });

    // Get current page information
    try {
        const pageInfo = await getCurrentPageInfo();
        if (pageInfo) {
            currentData = pageInfo;
            updatePreview(currentData);
            
            // Auto-focus email if empty
            const emailInput = document.getElementById('email');
            if (!emailInput.value) {
                emailInput.focus();
            }
        }
    } catch (error) {
        showError('Could not load page information');
        console.error('Error loading page info:', error);
    }

    setupEventListeners();
});

function getCurrentPageInfo() {
    return new Promise((resolve, reject) => {
        // First try to get info from background script
        chrome.runtime.sendMessage({ action: 'getPageInfo' }, (response) => {
            if (chrome.runtime.lastError) {
                reject(chrome.runtime.lastError);
                return;
            }
            
            if (response) {
                resolve(response);
            } else {
                // Fallback: get info from content script
                chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                    if (tabs[0]) {
                        chrome.tabs.sendMessage(tabs[0].id, { action: 'getPageMetadata' }, (response) => {
                            if (chrome.runtime.lastError) {
                                // If content script not available, use basic tab info
                                resolve({
                                    url: tabs[0].url,
                                    title: tabs[0].title,
                                    site: new URL(tabs[0].url).hostname
                                });
                            } else {
                                resolve(response);
                            }
                        });
                    } else {
                        reject(new Error('No active tab found'));
                    }
                });
            }
        });
    });
}

function setupEventListeners() {
    // AI Toggle
    document.getElementById('ai-toggle').addEventListener('click', () => {
        aiToggleState = !aiToggleState;
        const toggle = document.getElementById('ai-toggle');
        const options = document.getElementById('summary-options');
        
        if (aiToggleState) {
            toggle.classList.add('active');
            options.classList.remove('disabled');
        } else {
            toggle.classList.remove('active');
            options.classList.add('disabled');
        }
    });

    // Summary Length Options
    document.querySelectorAll('.summary-option').forEach(option => {
        option.addEventListener('click', () => {
            if (!aiToggleState) return;
            
            document.querySelectorAll('.summary-option').forEach(opt => 
                opt.classList.remove('active'));
            option.classList.add('active');
            selectedLength = option.dataset.length;
        });
    });

    // Email save
    document.getElementById('email').addEventListener('change', (e) => {
        chrome.storage.sync.set({ 'brief-email': e.target.value });
    });

    // Send Button
    document.getElementById('send-button').addEventListener('click', sendEmail);
    
    // Enter key in email field
    document.getElementById('email').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            sendEmail();
        }
    });
}

function updatePreview(data) {
    document.getElementById('preview-site').textContent = data.site.toUpperCase();
    document.getElementById('preview-title').textContent = data.title;
    document.getElementById('preview-url').textContent = data.url;
    document.getElementById('preview-url').href = data.url;
}

function showError(message) {
    const errorElement = document.getElementById('error-message');
    errorElement.textContent = message;
    errorElement.style.display = 'block';
    setTimeout(() => {
        errorElement.style.display = 'none';
    }, 5000);
}

function showSuccess(message) {
    const successElement = document.getElementById('success-message');
    successElement.textContent = message;
    successElement.style.display = 'block';
    setTimeout(() => {
        successElement.style.display = 'none';
    }, 3000);
}

async function sendEmail() {
    if (!currentData) {
        showError('Please reload the extension and try again');
        return;
    }

    const email = document.getElementById('email').value.trim();
    if (!email) {
        showError('Please enter your email address');
        document.getElementById('email').focus();
        return;
    }

    const contextValue = document.getElementById('context').value;
    const sendButton = document.getElementById('send-button');
    const loading = document.getElementById('loading');

    // Hide previous messages
    document.getElementById('success-message').style.display = 'none';
    document.getElementById('error-message').style.display = 'none';
    
    // Show loading state
    sendButton.disabled = true;
    loading.style.display = 'block';

    try {
        const requestData = {
            url: currentData.url,
            title: currentData.title,
            site: currentData.site,
            context: contextValue,
            aiSummary: aiToggleState,
            summaryLength: selectedLength,
            email: email
        };

        // Use background script to make API call to avoid CORS issues
        const response = await new Promise((resolve, reject) => {
            chrome.runtime.sendMessage(
                { action: 'sendToAPI', data: requestData },
                (response) => {
                    if (chrome.runtime.lastError) {
                        reject(chrome.runtime.lastError);
                    } else {
                        resolve(response);
                    }
                }
            );
        });

        if (response.success && response.data.success) {
            showSuccess('Email sent successfully! 📧');
            // Clear context
            document.getElementById('context').value = '';
        } else {
            throw new Error(response.data?.error || response.error || 'Unknown error');
        }
    } catch (error) {
        console.error('Error sending email:', error);
        showError(`Failed to send email: ${error.message}`);
    } finally {
        loading.style.display = 'none';
        sendButton.disabled = false;
    }
}
# Screenshots Guide

This document describes the screenshots needed for the QuickCapture landing page and documentation.

## Required Screenshots

### 1. Main Interface (`main-interface.png`)
**Recommended size**: 1200x800px
**Device**: Desktop browser
**Description**: The primary QuickCapture interface showing all key elements

**What to capture**:
- URL input field with placeholder text
- "Analyze Article" button
- Article preview card (visible after analysis)
- Email input field with example email
- "Add a note" textarea with sample context
- AI Summary toggle (both off and on states if possible)
- Summary length options (Short/Long)
- "Send to Email" button
- Clean, modern styling

**Sample article to use**: 
```
URL: https://www.nytimes.com/2025/08/09/world/americas/example-article.html
Title: "Example Article Title About Technology Trends"
Site: www.nytimes.com
```

### 2. Settings Modal (`settings-modal.png`)
**Recommended size**: 800x600px  
**Device**: Desktop browser
**Description**: The settings overlay with help information

**What to capture**:
- Settings modal opened over the main interface
- "Settings" header with close button
- "About QuickCapture" section with description
- "How to Use" section with numbered steps
- "Privacy" section explaining data handling
- "Close" button at bottom
- Semi-transparent background overlay

### 3. Email Example (`email-example.png`)
**Recommended size**: 600x900px
**Device**: Email client (Gmail, Apple Mail, etc.)
**Description**: A received QuickCapture email showing the formatted output

**What to capture**:
- Subject line: "New York Times: Example Article Title"
- Large article title as heading
- Publication date in italics
- Author name in italics
- Clickable article URL
- Context note in highlighted orange box
- "Summary (AI-generated):" heading
- 3-4 bullet points of AI summary content
- "Sent via QuickCapture" footer
- Clean email client interface

**Sample email content**:
```
Subject: New York Times: Technology Trends Reshape Modern Workplace

Body:
Technology Trends Reshape Modern Workplace

August 9, 2025
By Jane Smith

https://www.nytimes.com/2025/08/09/world/americas/technology-trends-workplace.html

Note: Important for our quarterly planning meeting

Summary (AI-generated):
• Remote work tools have evolved significantly, with AI-powered collaboration platforms becoming standard in most organizations
• Companies are investing heavily in employee digital literacy programs to bridge the technology skills gap
• The integration of virtual and augmented reality in workplace training has shown measurable improvements in employee engagement and retention

Sent via QuickCapture
```

### 4. Mobile View (`mobile-view.png`)
**Recommended size**: 375x812px (iPhone dimensions)
**Device**: Mobile browser (iOS Safari or Android Chrome)
**Description**: QuickCapture interface on mobile device

**What to capture**:
- Full mobile interface in portrait orientation
- Touch-friendly button sizes
- Responsive layout adaptation
- Mobile keyboard visible (optional)
- Same functionality as desktop but optimized for mobile
- Settings gear icon in header
- All form elements properly sized for mobile

### 5. Error Handling (`error-handling.png`) - Optional
**Recommended size**: 1200x800px
**Device**: Desktop browser
**Description**: Error state showing how QuickCapture handles issues gracefully

**What to capture**:
- Error message displayed (red background)
- Clear error text (e.g., "Please enter a valid URL")
- Form still accessible for correction
- Professional error handling

### 6. Loading State (`loading-state.png`) - Optional
**Recommended size**: 1200x800px
**Device**: Desktop browser
**Description**: Loading state while processing article

**What to capture**:
- "Sending email..." loading message
- Disabled send button
- Loading spinner or progress indicator
- Rest of interface properly disabled

## Screenshot Creation Tips

### Taking Screenshots

1. **Browser Setup**:
   - Use Chrome or Safari for consistency
   - Set window size to recommended dimensions
   - Ensure good lighting and contrast
   - Use clean, distraction-free browser (close tabs, bookmarks)

2. **Content Preparation**:
   - Use realistic sample data
   - Ensure text is readable at display size
   - Show actual functionality, not just mockups

3. **Technical Quality**:
   - High resolution (2x retina if possible)
   - PNG format for crisp text
   - No compression artifacts
   - Consistent lighting and contrast

### Sample Test Data

Use these realistic examples for screenshots:

**News Articles**:
- NY Times: Technology, politics, business articles
- Washington Post: Current events, analysis
- TechCrunch: Startup news, technology trends

**Email Addresses**:
- john.doe@example.com
- researcher@university.edu
- team@company.com

**Context Notes**:
- "Important for quarterly planning meeting"
- "Research for upcoming presentation"
- "Interesting perspective on market trends"
- "Follow up on this next week"

### Editing Guidelines

1. **Privacy Protection**:
   - Blur or replace any real email addresses
   - Use example.com domains only
   - No real personal information

2. **Consistency**:
   - Same browser/device for related screenshots
   - Consistent color scheme and styling
   - Similar content themes across screenshots

3. **Annotations** (if needed):
   - Use subtle arrows or highlights
   - Keep annotations minimal and clean
   - Ensure annotations don't obscure functionality

## File Organization

Save screenshots in this structure:
```
docs/screenshots/
├── main-interface.png
├── settings-modal.png  
├── email-example.png
├── mobile-view.png
├── error-handling.png (optional)
└── loading-state.png (optional)
```

## Usage in Documentation

Screenshots will be used in:
- `README.md` - Main interface screenshot
- `docs/LANDING.md` - All screenshots with descriptions
- GitHub repository social preview
- Future marketing materials

## Updating Screenshots

When updating screenshots:
1. Maintain consistent styling with current version
2. Update all related screenshots if UI changes significantly
3. Ensure all screenshots reflect current feature set
4. Test screenshots in different documentation contexts

---

**Note**: If you need help creating any of these screenshots, the actual QuickCapture application can be used to generate authentic examples. Visit the live demo and follow the steps outlined above to capture real usage scenarios.
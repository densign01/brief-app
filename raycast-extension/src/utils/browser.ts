import { runAppleScript } from '@raycast/utils';

export async function getCurrentURL(): Promise<string> {
	const script = `
    tell application "System Events"
      set frontApp to name of first application process whose frontmost is true
    end tell
    
    if frontApp is "Safari" then
      tell application "Safari"
        return URL of current tab of front window
      end tell
    else if frontApp is "Google Chrome" then
      tell application "Google Chrome"
        return URL of active tab of front window
      end tell
    else if frontApp is "Microsoft Edge" then
      tell application "Microsoft Edge"
        return URL of active tab of front window
      end tell
    else if frontApp is "Arc" then
      tell application "Arc"
        return URL of active tab of front window
      end tell
    else
      error "No supported browser is currently active"
    end if
  `;

	try {
		const result = await runAppleScript(script);
		return result.trim();
	} catch (error) {
		throw new Error('Failed to get current URL. Make sure a supported browser (Safari, Chrome, Edge, or Arc) is active.');
	}
}

export async function getPageTitle(): Promise<string> {
	const script = `
    tell application "System Events"
      set frontApp to name of first application process whose frontmost is true
    end tell
    
    if frontApp is "Safari" then
      tell application "Safari"
        return name of current tab of front window
      end tell
    else if frontApp is "Google Chrome" then
      tell application "Google Chrome"
        return title of active tab of front window
      end tell
    else if frontApp is "Microsoft Edge" then
      tell application "Microsoft Edge"
        return title of active tab of front window
      end tell
    else if frontApp is "Arc" then
      tell application "Arc"
        return title of active tab of front window
      end tell
    else
      error "No supported browser is currently active"
    end if
  `;

	try {
		const result = await runAppleScript(script);
		return result.trim();
	} catch (error) {
		throw new Error('Failed to get page title. Make sure a supported browser (Safari, Chrome, Edge, or Arc) is active.');
	}
}

# Brief Release Checklist

This checklist is for preparing the next Brief App Store update.

Current release candidate:
- Version: 1.2
- Build: 6
- macOS bundle ID: `com.danielensign.Brief`
- macOS share extension bundle ID: `com.danielensign.Brief.Extension`

## Before Upload

1. Confirm the repo is on the intended branch and the release commits are pushed.
2. Confirm there are no unrelated local changes staged for release.
3. Confirm the App Store Connect private key exists outside the repo:
   `~/.appstoreconnect/private_keys/AuthKey_PAQ942SRH8.p8`
4. Confirm Xcode has the needed platforms installed.
   - macOS release builds are currently verified.
   - iOS simulator release builds are currently verified with iOS 26.4.1.
5. Confirm the backend Worker is deployed and verified after the Cloudflare Email Sending switch.
   - `send-brief.com` must be onboarded in Cloudflare Email Sending.
   - The Worker must have the `EMAIL` Send Email binding from `brief-api/wrangler.jsonc`.
   - A real Brief send should deliver from `brief@send-brief.com`.
   - AI Summary uses Gemini first and Anthropic as a backup if `ANTHROPIC_API_KEY` is configured.
   - The Anthropic backup path is deployed and smoke-tested. The current `GOOGLE_API_KEY` still cannot call the Generative Language API, but this is not blocking the release while the backup is configured.
6. Confirm the Mac App Store package export succeeds.
   - Current verified package: `/Users/densign/Desktop/BriefArchives/macOS-Export/Brief.pkg.pkg`
   - Package signature: `3rd Party Mac Developer Installer: Daniel Ensign (PTP9R9BR3L)`.
   - App and share extension inside the package are signed with `Apple Distribution: Daniel Ensign (PTP9R9BR3L)`.

## Local Verification

Run these checks before creating an App Store archive:

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/brief-api
npm test
npm audit
npx wrangler deploy --dry-run
```

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/brief-web
npm test
npm audit
```

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app
git diff --check
xcodebuild -project Brief/Brief.xcodeproj -scheme "Brief (macOS)" -configuration Release -destination "generic/platform=macOS" CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Brief/Brief.xcodeproj -scheme "Brief (iOS)" -configuration Release -destination "platform=iOS Simulator,name=iPhone 17,OS=26.4.1" CODE_SIGNING_ALLOWED=NO build
```

## Mac App Store Upload

Before uploading the app, deploy and smoke-test the Worker after explicit approval:

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/brief-api
npx wrangler deploy
```

After the Cloudflare Email Sending path is verified with a real email, remove the old unused Resend secret:

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/brief-api
npx wrangler secret delete RESEND_API_KEY
```

Use this first if you want a local signed package without uploading:

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/Brief
fastlane mac build_macos
```

Only run this after an explicit approval checkpoint, because it creates and uploads a signed App Store package:

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/Brief
fastlane mac release_macos
```

Expected output artifact:
- `~/Desktop/BriefArchives/macOS-Export/Brief.pkg.pkg`

## AI Summary Provider Recovery

If AI-on sends deliver with `Summary could not be generated for this article.`, check the Worker logs before submitting to the App Store. Known Gemini failures include an expired key (`API key expired. Please renew the API key.`) or a key/project restriction that blocks the Generative Language API (`API_KEY_SERVICE_BLOCKED`).

The Worker tries Google Gemini first. If Gemini fails and `ANTHROPIC_API_KEY` is configured, it tries Anthropic before falling back to the "Summary could not be generated" email text. The Anthropic backup tries a short list of official Claude model names so one unavailable model does not break the backup path.

After renewing the Google Gemini key, update the live Worker secret only after an explicit approval checkpoint:

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/brief-api
npx wrangler secret put GOOGLE_API_KEY
```

If using the Anthropic backup, confirm this secret exists before deploying the backup path:

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/brief-api
npx wrangler secret list
```

Then repeat the smoke test:
- Open the local macOS app.
- Confirm the AI Summary consent copy appears if consent has not already been accepted.
- Send a normal article with AI Summary on.
- Confirm the email includes a generated summary instead of the fallback text.
- Confirm the received link opens the expected page.

Current status: the Anthropic backup is deployed and verified. Google Gemini still returns `API_KEY_SERVICE_BLOCKED`, so keep `ANTHROPIC_API_KEY` configured until Google API access is fixed.

## Current Release Notes

Use these notes for the App Store version update:

```text
Reliability improvements for saving and sharing links:
- Safer handling of article text and AI summaries before email delivery.
- More reliable web-link validation in the app and share extensions.
- More reliable email delivery infrastructure.
- Better timeout handling and clearer send failures from share sheets.
```

## Manual Checks

Before submitting for review:
- Open Brief on macOS and confirm the saved email still appears.
- Share a normal web page from Safari into Brief.
- Send with AI Summary off.
- Send with AI Summary on, confirming the consent copy still appears when needed.
- Confirm the received email opens the correct link.
- Confirm the received email is sent through the deployed Cloudflare Worker from `brief@send-brief.com`.

If a local macOS launch fails with `Provisioning profile does not allow this device`, Xcode needs to register this Mac for the `com.danielensign.Brief` development profile and refresh provisioning. Do that only after an explicit approval checkpoint because it changes Apple developer account state.

## Cleared Release Gates

### Cloudflare Email Sending deploy

Status: cleared on May 13, 2026.

- `npx wrangler deploy` succeeded for the live Worker.
- A real email to `daniel.ensign@gmail.com` was delivered from `brief@send-brief.com`.
- The old unused `RESEND_API_KEY` Worker secret was deleted after verification.

If future deploys fail because of missing email permissions:

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/brief-api
npx wrangler login
npx wrangler whoami
npx wrangler deploy --dry-run
```

Continue only when the dry run shows:

```text
env.EMAIL ... Send Email
```

Also confirm `send-brief.com` is onboarded in Cloudflare Email Sending before deploying.

### Mac App Store package export

Status: cleared on May 13, 2026.

- Xcode is signed into the Daniel Ensign Apple developer team.
- `fastlane mac build_macos` succeeded.
- The signed package was exported to `/Users/densign/Desktop/BriefArchives/macOS-Export/Brief.pkg.pkg`.
- `pkgutil --check-signature` reports `3rd Party Mac Developer Installer: Daniel Ensign (PTP9R9BR3L)`.
- The expanded package contains `Brief.app` and `Brief Extension.appex` signed with `Apple Distribution: Daniel Ensign (PTP9R9BR3L)`.

If this breaks again, first confirm Xcode is signed into the Apple developer team, then re-run:

```sh
cd /Users/densign/Documents/Coding-Projects/brief-app/Brief
fastlane mac build_macos
```

### AI Summary smoke test

Status: cleared on May 13, 2026.

- `npx wrangler deploy` succeeded for Worker version `6a48f7ba-6120-4ace-bee9-639408f0f65b`.
- Live AI-on send to `daniel.ensign@gmail.com` returned `{"success":true}`.
- Gmail confirmed delivery from `Brief <brief@send-brief.com>` with subject `Example: Brief Final AI Smoke Test - Example Domain`.
- The email included a generated AI summary instead of `Summary could not be generated for this article.`
- The email included `https://example.com`, and `https://example.com` returned HTTP 200 during the smoke test.
- Worker logs still show Gemini `API_KEY_SERVICE_BLOCKED`, so the passing summary came through the deployed Anthropic backup path.

### Local macOS app smoke test

Status: cleared for local launch, no-AI sends, share extension, and backend AI summary delivery on May 13, 2026.

- Xcode refreshed the Brief development provisioning profiles and this Mac is now included in both the app and share-extension development profiles.
- The local macOS Debug build launches successfully.
- Settings shows the saved email `daniel.ensign@gmail.com`.
- A no-AI send from the local macOS app delivered from `Brief <brief@send-brief.com>` with subject `Example: Example Domain`.
- History shows the new `Example Domain` sent item.
- The macOS share extension is registered with `com.apple.share-services` and the embedded extension is signed with the Brief app group.
- Safari's Share menu opens the Brief share extension, pre-fills the Example.com title and URL, and a no-AI share-extension send delivered from `Brief <brief@send-brief.com>`.
- AI Summary consent copy appears before enabling the feature.
- Live backend AI-on smoke now delivers a generated summary through the Anthropic backup path.

## Known Blockers

- App Store upload/submission should wait for approval because it touches App Store Connect.
- The live Worker `GOOGLE_API_KEY` currently cannot call the Generative Language API. This should be fixed after release, but AI summaries are not blocked while the verified Anthropic backup remains configured.

## 0.15.0 — 2026-10-25

### What’s New
- Added source-level regression test for iOS voice session capture.

### Bug Fixes
- Fixed undefined Swift identifiers `completedSession` and `completedLanguage` in voice upload path (compile blocker).
- Captured session/language before asynchronous upload and prevented overlapping recording while upload is active.
- Fixed Android cursor movement over supplementary Unicode scalars (e.g. emoji surrogate pairs).
- Released Android SpeechRecognizer on input finish.
- Removed redundant XcodeGen Info.plist executable injection; the explicit extension Info.plist owns CFBundleExecutable.
- Set main iOS app display name to Myanmar Keyboard.

### Known Issues
- iOS Keyboard Extension cannot record microphone audio directly. Companion-app voice workflow is not live streaming and not proven on-device.
- App Group entitlement requires correctly provisioned signing; Personal Team may not support it.
- Myanmar layout, grapheme deletion, speech accuracy and native builds remain unverified.
- Android voice uses device SpeechRecognizer, not Cloud Whisper.

## 0.14.0 — 2026-10-25

### What’s New
- Added backend MIME-to-filename validation tests for Whisper uploads.
- Added iOS voice session guard to avoid inserting results from a different session.

### Bug Fixes
- Fixed incorrectly named MP3/WebM audio uploads.
- Prevented an older async transcription result from overwriting a newer session.
- Aligned version metadata and explicitly declared the extension executable in XcodeGen.

### Known Limitations
- No macOS Xcode or Android SDK build was run in this environment. iPhone installation is **not verified**.
- iOS keyboard microphone recording is unsupported; the host app voice bridge is not direct live dictation.
- Full-access / app-group entitlements and signing may require a paid Apple developer team; verify on device.
- The Myanmar key layout has not been usability validated.
- Server token authentication is prototype-only, not production-grade user authentication.

## 0.13.0 — 2026-10-25

### What's New
- Explicit iOS keyboard extension executable, bundle and version metadata.
- Source integrity tests, repository hygiene and iPhone installation troubleshooting guide.

### Bug Fixes
- Addressed missing `CFBundleExecutable` in extension Info.plist (device verification pending).
- Prevented stale voice transcription from inserting immediately on microphone key press.
- Aligned Android version to v0.13.0.

### Validation
- Python static checks and backend mock tests only. No native iOS/Android build or physical device test performed here.

# Version history

## 0.12.0 — 2026-10-25
### What's New
- Added Python FastAPI prototype with server-side Whisper API adapter and configurable model.
- Added on-demand iOS WAV recording and HTTPS cloud transcription on Stop.
- Added authenticated endpoint, upload size/type limits, language validation and unit tests.
- Added iOS cloud configuration and test plan.
### Bug Fixes
- Removed misleading iOS background recording configuration and unsupported claims.
- Added explicit user-triggered insertion of completed voice transcripts from the App Group bridge.
### Known Issues
- No live partial transcription; recording must stop before upload.
- iOS recording only works in companion app foreground; no keyboard microphone access.
- Prototype client token unsuitable for public production distribution.
- Cloud API and native device builds not tested; speech accuracy not measured.

# Version history

## 0.11.0 — 2026-10-25
### What's New
- Experimental iOS live transcription bridge via App Group shared preferences.
- Keyboard polls for transcription changes and inserts text at the current caret without a copy/paste action.
- Host app publishes recognition session IDs, active state, and partial transcripts.
- XcodeGen signing entitlements for the App Group and host background-audio configuration.
### Bug Fixes / Safety
- Stop automatic replacement if the user edits/moves the caret and the previously inserted suffix no longer matches.
- Never read shared transcription without keyboard Full Access.
### Known Issues
- iOS keyboard extension cannot record audio; recording must be started in the host app.
- Background recording, Myanmar recognition availability, and App Store approval are unverified.
- Native compilation and device tests pending.

## 0.10.0
- Android voice input and iOS companion-app speech recognition introduced.
- Password-field restrictions improved.

## 0.9.0
- Version history introduced; keyboard branding and input guards updated.

# Code audit — v0.15.0

Scope: inspected all first-party Swift/Kotlin/Python source, iOS plist/XcodeGen settings, Android manifest/Gradle, entitlements and tests.

## Fixed in this release
1. `ios/KeyboardApp/KeyboardApp.swift`: `completedLanguage` and `completedSession` were referenced without declarations; Swift compile blocker. Capture values before async upload.
2. Same file: duplicate recording/upload could overlap. Added guards and consumed `audioURL` after stop.
3. `android/.../KeyboardService.kt`: moving caret by one UTF-16 unit could land inside a surrogate pair. Move by Unicode code point instead (not a full grapheme solution).
4. Same file: speech recognizer was not destroyed on input finish.
5. `ios/project.yml`: redundant `INFOPLIST_KEY_CFBundleExecutable` removed when explicit extension Info.plist is used.

## Outstanding high-priority issues
- iOS microphone access is not allowed inside third-party keyboard extensions; App Group transfer does not solve app switching or live capture.
- App Group entitlements may fail to provision with Personal Team. Do not remove entitlement silently: voice bridge would stop working.
- `isSecureContext` based on nil surrounding text is a heuristic, not a reliable password detector.
- Android Myanmar layout is provisional; `BreakIterator` deletion does not guarantee correct Burmese grapheme clusters.
- iOS keyboard has an empty shortcut map and no settings persistence.
- iOS extension polling relies on shared UserDefaults and has no guaranteed background delivery.
- Cloud API uses a single prototype bearer token; unsafe to embed in distributed app. Add per-user auth, quotas, abuse prevention, HTTPS and retention policy.
- Backend lacks request concurrency controls and upstream response-size limits; JSON parse failures can propagate as 500.
- Android `SpeechRecognizer` is device-dependent; `my-MM` support not guaranteed.
- No Gradle wrapper; XcodeGen, Xcode and Android SDK are needed for reproducible builds.

## Validation
- Python unit/source tests and archive integrity can be run here.
- No native iOS/Android compiler/device is available in this environment. Do not treat source tests as native build verification.

## iPhone install diagnostic
After building, inspect the **built** `.appex/Info.plist` with `plutil -p` and ensure `CFBundleExecutable` equals the executable filename and that executable exists. Verify extension provisioning/signing. Do not rely on source plist alone.

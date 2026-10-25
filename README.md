*Preview poster only — not yet on the App Store or Google Play.*

![Myanmar Keyboard — Voice Typing preview](branding/marketing-voice.jpg)

# Myanmar Keyboard — v0.14.0
by Min SiThu (itsmeminsithu)

Native iOS/Android keyboard project with an **experimental cloud Myanmar speech recognition** backend. **Not production-ready.**

## What's New (v0.14.0)
- Added the missing `CFBundleExecutable` to the keyboard extension Info.plist, matching the iPhone installer error.
- Added explicit extension bundle metadata and synchronized iOS version/build settings.
- Added source integrity tests, `.gitignore`, GitHub upload guidance and iOS install troubleshooting.

## Bug Fixes (v0.14.0)
- Prevented microphone key from immediately inserting an old cached transcription.
- Updated stale Android app version metadata to 0.14.0.
- Removed unused keyboard voice bridge state.

## Previous v0.12 features
- `backend/`: authenticated prototype ASR endpoint, using OpenAI `whisper-1` transcription with `language=my` or `en`.
- iOS host app records 16 kHz PCM WAV and uploads **only when the user taps Stop**. It then publishes the completed transcript to the App Group bridge.
- iOS keyboard microphone key arms insertion for a subsequent transcript into the focused text field; no user copy/paste.
- Backend response includes latency and model name for manual benchmarks.
- Mocked ASR unit tests added.

## Important limitations
- **Not live dictation:** audio is uploaded on Stop; it does not show words while speaking.
- iOS keyboard extensions cannot record microphone audio. Host app must be used for recording. App switching is required.
- Host app does not record in background. There is no claim that the host app will record while another app is foreground.
- `ASRPrototypeToken` is a prototype-only credential and **must not be embedded in production clients**. Replace with short-lived per-user tokens issued by a proper authentication service.
- Voice data is sent to the configured backend and upstream ASR provider only after user action. Review consent, retention and privacy policy before launch.
- No real API requests, iOS/Android native builds, or device tests performed in this environment.

## Backend local setup (Python 3.10+)
```sh
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export OPENAI_API_KEY='YOUR_SERVER_SIDE_KEY'
export ASR_CLIENT_TOKEN='DEVELOPMENT_ONLY_TOKEN'
uvicorn app:app --host 127.0.0.1 --port 8000
python -m unittest discover -s tests -v
```
To test locally, POST multipart `file` (WAV/M4A) and `language=my` to `/v1/transcribe`, with `Authorization: Bearer DEVELOPMENT_ONLY_TOKEN`. For iOS devices, deploy behind HTTPS and configure `ASRServerURL` and `ASRPrototypeToken` in `ios/project.yml` **for a private development build only**. Never commit actual credentials. App Group signing must match your Apple Developer team.

## iOS build
```sh
cd ios
xcodegen generate
open YayParKeyboard.xcodeproj
```
Enable App Groups for both targets and replace bundle IDs with your own. Use a physical iPhone to test microphone, server upload and manual keyboard insertion. The Swift source has not been compiled on macOS here.

## Android
Android's existing native speech recognition implementation remains unchanged in this release; it does **not** yet call the cloud backend.

## Validation
Run `cd backend && python3 -m unittest discover -s tests -v`. See `CHANGELOG.md` and `docs/CLOUD_ASR_TEST_PLAN.md`.

## GitHub upload

```sh
git init
git add .
git commit -m "Release v0.14.0: iOS extension installer metadata fix"
git branch -M main
git remote add origin https://github.com/devminsithu/YayParKeyboard.git
git push -u origin main
```

Create the empty repository first, or use `gh repo create devminsithu/YayParKeyboard --private --source=. --remote=origin --push` if GitHub CLI is configured. The remote URL above is a **suggested new repository path**, not a claim that the repo exists. Do not commit API keys, server tokens or Apple signing files.

For iOS installation see `docs/IOS_INSTALL_TROUBLESHOOTING.md`.

## v0.14.0 What’s New / Bug Fixes

See [CHANGELOG.md](CHANGELOG.md) for tested fixes and outstanding iOS installation / voice limitations.


## v0.15 code audit
See `docs/CODE_AUDIT_v0.15.md` for confirmed defects, remaining risks and validation boundaries.

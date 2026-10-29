![Myanmar Keyboard — Voice Typing Keyboard preview](branding/marketing-voice2.jpg)

*Preview poster only — not yet on the App Store or Google Play.*

# Myanmar Keyboard — v0.14.0
by Min SiThu (itsmeminsithu)

Status first, because it matters here: this is v0.15 audited source. The iOS and Android builds have not been verified, and I have not tested it on a device. It is not production-ready, and it is not on the App Store or Google Play.

## What this is

A Myanmar keyboard for iOS and Android, with a cloud speech-to-text backend that is still experimental.

The keyboard gives you a Myanmar layout on both platforms. For voice: the iOS host app records audio, you tap Stop, it uploads the recording, and the finished transcript goes into the focused text field. That is not live dictation. iOS keyboard extensions cannot record microphone audio themselves, which is why recording happens in the host app.

The backend is a Python FastAPI prototype. It transcribes with OpenAI Whisper (`whisper-1`, `my` or `en`), behind a prototype bearer token. That token is not production auth and must not ship inside a distributed app.

## v0.14.0 changes

- Added the missing `CFBundleExecutable` to the keyboard extension Info.plist, matching the iPhone installer error.
- Added explicit extension bundle metadata, and synced the iOS version/build settings.
- Added source integrity tests, `.gitignore`, GitHub upload notes and iOS install troubleshooting.

Fixes:

- The microphone key no longer inserts an old cached transcription straight away.
- Stale Android app version metadata updated to 0.14.0.
- Removed unused keyboard voice bridge state.

## What came in with v0.12

- `backend/`: prototype ASR endpoint, OpenAI `whisper-1` transcription with `language=my` or `en`.
- iOS host app records 16 kHz PCM WAV and uploads **only when you tap Stop**. It then publishes the transcript to the App Group bridge.
- The iOS keyboard microphone key arms insertion of the next transcript into the focused text field. No copy/paste step.
- Backend responses include latency and model name, for manual benchmarks.
- Mocked ASR unit tests.

## Limits worth knowing before you try it

- **Not live dictation.** Audio uploads on Stop. Words do not appear while you speak.
- iOS keyboard extensions cannot record microphone audio. You record in the host app, so app switching is required.
- The host app does not record in the background. I am not claiming it records while another app is in front.
- `ASRPrototypeToken` is prototype-only. **Do not embed it in production clients.** Use short-lived per-user tokens from a proper auth service instead.
- Voice data goes to the configured backend and the upstream ASR provider, and only after a user action. Sort out consent, retention and a privacy policy before any launch.
- No real API requests, iOS/Android native builds, or device tests were done in this environment.

## Backend, locally (Python 3.10+)

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

To test: POST a multipart `file` (WAV/M4A) and `language=my` to `/v1/transcribe`, with `Authorization: Bearer DEVELOPMENT_ONLY_TOKEN`. For iOS devices, put it behind HTTPS and set `ASRServerURL` and `ASRPrototypeToken` in `ios/project.yml` — **private development build only**. Never commit real credentials. App Group signing has to match your Apple Developer team.

## iOS build

```sh
cd ios
xcodegen generate
open YayParKeyboard.xcodeproj
```

Enable App Groups on both targets and replace the bundle IDs with your own. Test on a physical iPhone: microphone, server upload, insertion from the keyboard. The Swift source was not compiled on macOS here.

## Android

The existing native speech recognition is unchanged in this release. It does **not** call the cloud backend yet.

## Checks

Run `cd backend && python3 -m unittest discover -s tests -v`. See `CHANGELOG.md` and `docs/CLOUD_ASR_TEST_PLAN.md`.

## Putting it on GitHub

```sh
git init
git add .
git commit -m "Release v0.14.0: iOS extension installer metadata fix"
git branch -M main
git remote add origin https://github.com/devminsithu/YayParKeyboard.git
git push -u origin main
```

Create the empty repository first, or run `gh repo create devminsithu/YayParKeyboard --private --source=. --remote=origin --push` if the GitHub CLI is set up. That remote URL is a **suggested new repository path**, not a claim that the repo exists. Do not commit API keys, server tokens or Apple signing files.

iOS install problems: see `docs/IOS_INSTALL_TROUBLESHOOTING.md`.

## v0.14.0 notes and the v0.15 audit

[CHANGELOG.md](CHANGELOG.md) has the tested fixes and the open iOS installation / voice limitations. `docs/CODE_AUDIT_v0.15.md` has the confirmed defects, remaining risks and validation boundaries from the v0.15 code audit.

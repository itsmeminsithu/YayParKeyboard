# Voice acceptance tests

## Android
1. Launch app, grant microphone permission. Enable and select keyboard.
2. Open ordinary editable field; tap microphone; speak Burmese; verify recognized text is committed.
3. Switch English; verify en-US result.
4. Deny microphone permission; verify permission prompt workflow without crash.
5. Test device with no recognition service; verify graceful failure.
6. Test password and number-password fields; microphone must not activate.
7. Switch input fields while listening; verify recognition cancels.
8. Check system speech provider's offline/network/privacy behavior.

## iOS
1. Install host and keyboard extension, enable keyboard.
2. Open host app, grant microphone and speech permissions, transcribe Burmese and English.
3. Copy text, open Notes, switch to Myanmar Keyboard, tap Paste.
4. Deny permissions and test unsupported language/recognizer unavailable.
5. Confirm no microphone control exists inside extension; Apple platform restriction.

## Existing keyboard regressions
- Myanmar vowels/medials/stacking, emoji deletion, selection replacement, cursor motion, secure input, landscape, app switching.

# iOS live voice bridge test

Prerequisites: real iPhone, valid Apple signing, matching App Group entitlements, Allow Full Access enabled, microphone + speech permissions granted.

1. Confirm `my-MM` availability. If unavailable, test `en-US` separately; do not call this Myanmar voice typing.
2. Start host app recording and keep it active; open Notes manually and select Myanmar Keyboard.
3. Speak a phrase and check whether text appears **without** Paste.
4. Continue speaking and verify partial revisions do not duplicate words.
5. Move caret mid-transcription; verify the keyboard does not delete unrelated text.
6. Try secure password field; verify shared text is not inserted.
7. Switch away and back, rotate screen, interrupt microphone with a call, lock/unlock.
8. Verify audio session stops when requested and privacy indicator turns off.
9. Verify behavior when Full Access is disabled, when ASR unavailable, and when host app is killed.
10. Inspect device console for App Group and audio background errors.

Release blocker: passing real-device tests, build validation, and Apple policy review. The bridge is experimental.

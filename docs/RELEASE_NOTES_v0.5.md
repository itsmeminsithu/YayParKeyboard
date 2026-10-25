# v0.5 Native Productivity Core

Implemented in both native keyboards:
- Text expansion on Space using example shortcuts `@@` → `hello@example.com`, `brb` → `be right back` (replace sample email before release).
- Three keyboard key-height presets via Size toolbar button.
- Spacebar horizontal pan cursor movement, with platform-dependent behavior.
- Android selection-aware cursor movement and shortcut expansion.

Not implemented: editable shortcuts UI, pinned clipboard history, Myanmar word prediction, language auto-detection, swipe word entry, translation, voice recognition, backup. These are still planned.

IMPORTANT: This source has not been compiled with Xcode/Gradle or tested on devices. Spacebar pan/gesture interaction, Unicode composition and keyboard resizing need real-device QA. Not customer ready.

# v0.6 Static audit and fixes

## Fixed / mitigated
- Android cursor movement now accounts for `ExtractedText.startOffset` (previous code used a relative bound with an absolute selection).
- Android backspace now removes a trailing Myanmar combining sequence together with the preceding code point; this is an approximation, not full Unicode grapheme segmentation.
- Android clipboard now guards empty ClipData before accessing item 0.
- Android spacebar gesture handles ACTION_CANCEL.
- iOS spacebar now receives 4x width using layout constraints instead of equal widths.
- iOS shift is disabled for Myanmar/numeric/symbol layouts.
- Removed unused imports / unused iOS property.

## Known unresolved issues (do not ship to customers)
- Full Myanmar standard layout, grapheme deletion, cursor movement across grapheme clusters, key repeat, accessibility and Dynamic Type need tests and improvements.
- iOS keyboard view height/host app compatibility not validated.
- iOS and Android clipboard permissions, IME action handling, and shortcut editing need tests.
- Text shortcuts still use demo placeholders; do not present as user-configurable.
- Word prediction, speech recognition, translation, pinned clipboard, backups and swipe typing are not implemented.
- Neither Xcode nor Android SDK/Gradle is available in this environment. No successful native build or device test is claimed.

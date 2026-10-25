# v0.7 targeted static review

## Changes
1. Android backspace: replaced hand-rolled combining-mark check with BreakIterator character boundary. Remaining risk: Myanmar syllables can span multiple Unicode grapheme clusters; test complex stacked consonants and kinzi.
2. Android cursor: invalid extracted selection guard; selection offsets are absolute. Some editors may not return extracted text.
3. iOS: explicit host keyboard height constraint and less brittle proportional key widths. Must verify on iPhone SE and Dynamic Type.
4. iOS: shortcut deletion iterates Swift Character rather than Unicode scalar count. Host textDocumentProxy can truncate context.

## Test checklist on real devices
- Enable IME; switch Myanmar/English; enter Myanmar stacked consonants, vowel signs and punctuation; backspace at each position.
- Select text, paste, type shortcuts; move cursor at beginning/end and with emoji.
- Test Notes, Messages, Safari, Telegram; secure fields must revert to system keyboard on iOS.
- Rotate device, change appearance, test narrow screen and accessibility text sizes.
- Verify no clipboard is stored without user action and no keystroke/network logging.

## Release blockers
- No native compilation or device test performed.
- Myanmar layout not independently validated against a standard.
- Advanced voice, translation, prediction, sync, and pinned clipboard remain unimplemented.

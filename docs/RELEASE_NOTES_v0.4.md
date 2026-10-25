# v0.4 Native Keyboard Iteration

Developer: by Min SiThu (itsmeminsithu)

## Implemented in source
- Explicit clipboard paste action on both platforms (subject to OS paste permissions)
- Dedicated numeric pad mode
- Android system keyboard picker key
- Android editor action handling for Return/Done
- Preserved Myanmar/English keys, cursor navigation, light/dark appearance, and official icon

## Known limitations
- Myanmar layouts are prototypes, not validated against a complete standardized keyboard map.
- No smart prediction, auto language detection, clipboard history, voice recognition, translation, cloud backup, or swipe typing yet.
- iOS keyboard extensions cannot record microphone audio. Voice typing needs a separate host-app workflow.
- No full Android or Xcode build has been performed here. Run on actual devices before distribution.
- The current UI uses basic platform buttons; further usability, accessibility, and performance work is required.

## Next implementation target
- Unicode-safe Myanmar layout, shift/long-press variants, robust deletion, composition tests, accessibility, and user-configurable shortcuts.

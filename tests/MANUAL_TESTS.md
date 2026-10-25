# Device Regression Checklist (NOT YET EXECUTED)

## Android
- [ ] Compile with Android Studio and install on API 26 and API 35+
- [ ] Enable IME, switch language, enter Myanmar and English
- [ ] Delete combining characters and stacked consonants
- [ ] Select text; left arrow moves to start, right arrow moves to end
- [ ] Paste works only after explicit tap in ordinary text fields
- [ ] Paste is disabled in text and numeric password fields
- [ ] Space tap inserts one space; swipe moves cursor
- [ ] Verify action key on search, done and multiline inputs

## iOS
- [ ] Generate Xcode project; compile host app and keyboard extension
- [ ] Install extension, enable keyboard, switch via globe key
- [ ] Type and delete Myanmar combining/stacked characters
- [ ] Verify no clipping on small phones and landscape orientation
- [ ] Check paste prompts and paste behavior in normal vs secure inputs
- [ ] Verify size presets, spacebar swipe, return key, VoiceOver

Do not mark items passed without device evidence.

from pathlib import Path
root=Path(__file__).resolve().parents[1]
a=(root/'android/app/src/main/java/org/minsithu/yaypar/KeyboardService.kt').read_text()
i=(root/'ios/KeyboardExtension/KeyboardViewController.swift').read_text()
assert 'InputMethodService' in a and 'UIInputViewController' in i
assert 'hello@example.com' not in a+i
assert 'primaryClip' in a and 'UIPasteboard.general.string' in i
assert 'adjustTextPosition' in i and 'moveCursor(1)' in a
assert (root/'ios/KeyboardApp/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png').is_file()
print('Static source checks passed (not a build or device test).')

assert (root/'CHANGELOG.md').is_file()
assert 'secureField' in a and 'TYPE_TEXT_VARIATION_PASSWORD' in a
assert 'Myanmar Keyboard' in (root/'android/app/src/main/AndroidManifest.xml').read_text()
assert 'versionName = "0.13.0"' in (root/'android/app/build.gradle.kts').read_text()
print('v0.13 documentation and security assertions passed.')

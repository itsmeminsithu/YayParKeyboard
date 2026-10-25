# iOS installation checks (v0.13)

The iOS keyboard is an app extension. **The containing KeyboardApp must install before the keyboard appears in Settings.**

1. In `ios/`, run `xcodegen generate` and open `YayParKeyboard.xcodeproj`.
2. In Xcode, set your Apple Team for **both** KeyboardApp and KeyboardExtension. Confirm extension bundle ID begins with the host app ID and both targets use the same App Group entitlement if the voice bridge is enabled.
3. Product → Clean Build Folder, select KeyboardApp scheme and your unlocked iPhone, then Run.
4. If installation fails, inspect the **built** extension, not only source plist:

```sh
APP=$(find "$HOME/Library/Developer/Xcode/DerivedData" -path '*/Build/Products/Debug-iphoneos/KeyboardApp.app' -type d -print -quit)
EXT="$APP/PlugIns/KeyboardExtension.appex"
/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$EXT/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$EXT/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :NSExtension:NSExtensionPointIdentifier' "$EXT/Info.plist"
ls -l "$EXT/KeyboardExtension"
```

5. On iPhone open the host app once, then Settings → General → Keyboard → Keyboards → Add New Keyboard.

**Important:** No macOS Xcode/device build was executed in the source packaging environment. If the installer still rejects the bundle, capture the final built Info.plist, signing status and full Xcode install log. Do not add an `INFOPLIST_KEY_CFBundleExecutable` override to the host target.

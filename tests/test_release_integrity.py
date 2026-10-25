import pathlib
import plistlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]

class ReleaseIntegrity(unittest.TestCase):
    def test_keyboard_extension_plist(self):
        with (ROOT / "ios/KeyboardExtension/Info.plist").open("rb") as f:
            info = plistlib.load(f)
        self.assertEqual(info["CFBundleExecutable"], "$(EXECUTABLE_NAME)")
        self.assertEqual(info["CFBundleVersion"], "$(CURRENT_PROJECT_VERSION)")
        self.assertEqual(info["NSExtension"]["NSExtensionPointIdentifier"], "com.apple.keyboard-service")
        self.assertTrue(info["NSExtension"]["NSExtensionPrincipalClass"].endswith(".KeyboardViewController"))

    def test_build_settings(self):
        project = (ROOT / "ios/project.yml").read_text()
        self.assertIn("INFOPLIST_FILE: KeyboardExtension/Info.plist", project)
        self.assertIn("GENERATE_INFOPLIST_FILE: NO", project)
        self.assertIn("CURRENT_PROJECT_VERSION: 15", project)
        self.assertIn("MARKETING_VERSION: 0.15.0", project)
        self.assertIn("org.minsithu.yaypar.KeyboardApp.KeyboardExtension", project)

    def test_voice_stop_captures_session_and_language(self):
        swift = (ROOT / "ios/KeyboardApp/KeyboardApp.swift").read_text()
        self.assertIn("let completedSession = sessionID", swift)
        self.assertIn("let completedLanguage = language", swift)

    def test_no_checked_in_secrets(self):
        self.assertFalse((ROOT / "backend/.env").exists())
        self.assertFalse((ROOT / "ios/secrets.xcconfig").exists())

if __name__ == "__main__":
    unittest.main()

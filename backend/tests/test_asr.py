import json
import os
import unittest
from unittest.mock import patch
from asr import transcribe

class FakeResponse:
    def __enter__(self): return self
    def __exit__(self, *args): pass
    def read(self): return json.dumps({'text': 'မင်္ဂလာပါ'}).encode()

class ASRTests(unittest.TestCase):
    def test_burmese_payload_and_response(self):
        def open_request(request, timeout):
            self.assertIn(b'name="language"\r\n\r\nmy', request.data)
            self.assertIn(b'name="model"\r\n\r\nwhisper-1', request.data)
            self.assertIn(b'RIFF', request.data)
            self.assertEqual(timeout, 40)
            return FakeResponse()
        with patch.dict(os.environ, {'OPENAI_API_KEY': 'fake'}):
            result = transcribe(b'RIFF', 'audio/wav', opener=open_request)
        self.assertEqual(result['text'], 'မင်္ဂလာပါ')
    def test_audio_file_extensions(self):
        for mime, suffix in [("audio/wav", "wav"), ("audio/mp4", "m4a"), ("audio/mpeg", "mp3"), ("audio/webm", "webm")]:
            def check(request, timeout):
                self.assertIn(("filename=\"speech." + suffix + "\"").encode(), request.data)
                return FakeResponse()
            with patch.dict(os.environ, {"OPENAI_API_KEY": "fake"}):
                transcribe(b"audio", mime, opener=check)

    def test_rejects_unsupported_language(self):
        with self.assertRaises(ValueError): transcribe(b'a', 'audio/wav', 'xx')
    def test_rejects_oversized_audio(self):
        with self.assertRaises(ValueError): transcribe(b'a' * (12 * 1024 * 1024 + 1), 'audio/wav')

if __name__ == '__main__': unittest.main()

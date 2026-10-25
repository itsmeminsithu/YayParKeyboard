"""Server-only OpenAI transcription adapter; no API keys in mobile apps."""
import json
import os
import time
import urllib.error
import urllib.request
import uuid

MAX_AUDIO_BYTES = 12 * 1024 * 1024
SUPPORTED_TYPES = {"audio/wav", "audio/x-wav", "audio/m4a", "audio/mp4", "audio/mpeg", "audio/webm"}

class TranscriptionError(Exception):
    pass

def transcribe(audio: bytes, content_type: str, language: str = "my", *, opener=None):
    if language not in ("my", "en"):
        raise ValueError("unsupported language")
    if content_type not in SUPPORTED_TYPES:
        raise ValueError("unsupported audio type")
    if not audio or len(audio) > MAX_AUDIO_BYTES:
        raise ValueError("audio must be between 1 byte and 12 MiB")
    key = os.environ.get("OPENAI_API_KEY")
    if not key:
        raise TranscriptionError("OPENAI_API_KEY not configured")
    boundary = "----MyanmarKeyboard" + uuid.uuid4().hex
    def part(name, value, filename=None, mime=None):
        disposition = f'Content-Disposition: form-data; name="{name}"'
        if filename: disposition += f'; filename="{filename}"'
        header = f'--{boundary}\r\n{disposition}\r\n'
        if mime: header += f'Content-Type: {mime}\r\n'
        return (header + '\r\n').encode() + value + b'\r\n'
    model = os.environ.get("ASR_MODEL", "whisper-1")
    suffixes = {"audio/wav": "wav", "audio/x-wav": "wav", "audio/m4a": "m4a", "audio/mp4": "m4a", "audio/mpeg": "mp3", "audio/webm": "webm"}
    filename = "speech." + suffixes[content_type]
    payload = b''.join((part('model', model.encode()), part('language', language.encode()), part('file', audio, filename, content_type), f'--{boundary}--\r\n'.encode()))
    req = urllib.request.Request('https://api.openai.com/v1/audio/transcriptions', data=payload, method='POST', headers={'Authorization': f'Bearer {key}', 'Content-Type': f'multipart/form-data; boundary={boundary}'})
    start = time.monotonic()
    try:
        with (opener or urllib.request.urlopen)(req, timeout=40) as response:
            result = json.loads(response.read())
    except (urllib.error.HTTPError, urllib.error.URLError, TimeoutError) as exc:
        raise TranscriptionError('upstream transcription request failed') from exc
    text = result.get('text')
    if not isinstance(text, str):
        raise TranscriptionError('upstream response missing text')
    return {'text': text, 'language': language, 'model': model, 'latency_ms': round((time.monotonic() - start) * 1000)}

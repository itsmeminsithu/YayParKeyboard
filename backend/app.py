"""Minimal prototype endpoint. Deploy behind HTTPS and a trusted auth gateway."""
import os
import secrets
from fastapi import FastAPI, File, Form, Header, HTTPException, UploadFile
from asr import MAX_AUDIO_BYTES, SUPPORTED_TYPES, TranscriptionError, transcribe

app = FastAPI(title="Myanmar Keyboard ASR", docs_url=None, redoc_url=None)

@app.get('/health')
def health():
    return {'status': 'ok'}

@app.post('/v1/transcribe')
async def recognize(file: UploadFile = File(...), language: str = Form('my'), authorization: str | None = Header(None)):
    token = os.environ.get('ASR_CLIENT_TOKEN')
    if not token:
        raise HTTPException(503, 'server authentication not configured')
    if not authorization or not secrets.compare_digest(authorization, 'Bearer ' + token):
        raise HTTPException(401, 'unauthorized')
    if language not in ('my', 'en') or file.content_type not in SUPPORTED_TYPES:
        raise HTTPException(415, 'unsupported language or audio type')
    data = await file.read(MAX_AUDIO_BYTES + 1)
    if not data or len(data) > MAX_AUDIO_BYTES:
        raise HTTPException(413, 'invalid audio size')
    try:
        return transcribe(data, file.content_type, language)
    except TranscriptionError:
        raise HTTPException(502, 'transcription service unavailable')

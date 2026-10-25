# Cloud ASR validation
1. Start backend with credentials only in server environment. Verify `/health`.
2. Verify POST without token returns 401; without configured server token returns 503.
3. Verify >12 MiB files return 413, unsupported language/type return 415.
4. Record 10+ Myanmar clips with regional accents and background noise. Measure transcription errors manually and latency using response `latency_ms`.
5. iOS: grant microphone permission, record, tap Stop, wait for text. Switch to Notes with custom keyboard, tap 🎙 to insert shared transcript. Verify no text appears without explicit 🎙 action.
6. Confirm secure/password fields do not insert transcript. Verify no duplicate insertions, switching target apps, and offline/error conditions.
7. Validate server TLS, per-user authentication, quotas, privacy disclosure, data deletion and App Store compliance before release.

import SwiftUI
import AVFoundation
import UIKit

private enum VoiceBridge {
 static let group = "group.org.minsithu.yaypar.voice"
 static let textKey = "voice.currentText"
 static let revisionKey = "voice.revision"
 static let sessionKey = "voice.session"
 static let activeKey = "voice.active"
 static func publish(_ text: String, session: String, active: Bool) {
  guard let store = UserDefaults(suiteName: group) else { return }
  store.set(text, forKey: textKey)
  store.set(session, forKey: sessionKey)
  store.set(active, forKey: activeKey)
  store.set(UUID().uuidString, forKey: revisionKey)
 }
}


@main struct MyanmarKeyboardApp: App {
 var body: some Scene { WindowGroup { VoiceCompanionView() } }
}

struct VoiceCompanionView: View {
 @StateObject private var recorder = VoiceRecorder()
 var body: some View {
  VStack(spacing: 18) {
   Text("Myanmar Keyboard").font(.title.bold())
   Text("by Min SiThu (itsmeminsithu)").font(.footnote)
   Text("Settings → General → Keyboard → Keyboards → Add New Keyboard → Myanmar Keyboard")
    .multilineTextAlignment(.center)
   Picker("Language", selection: $recorder.language) {
    Text("မြန်မာ").tag("my-MM"); Text("English").tag("en-US")
   }.pickerStyle(.segmented)
   Button(recorder.isRecording ? "Stop recording" : "Start voice typing") {
    if recorder.isRecording { recorder.stop() } else { recorder.start() }
   }.buttonStyle(.borderedProminent)
   if recorder.isUploading { ProgressView("Transcribing…") }
   TextEditor(text: $recorder.transcript).frame(minHeight: 140).border(.gray.opacity(0.3))
   Text("Cloud prototype: record here, tap Stop, wait for transcription, then switch to a text field using Myanmar Keyboard. Automatic insertion requires the keyboard bridge to be active. No live streaming or background microphone recording.")
    .font(.footnote).foregroundStyle(.secondary)
   if !recorder.error.isEmpty { Text(recorder.error).foregroundStyle(.red) }
  }.padding()
 }
}

@MainActor final class VoiceRecorder: ObservableObject {
 @Published var transcript = ""
 @Published var isRecording = false
 @Published var language = "my-MM"
 @Published var error = ""
 @Published var isUploading = false
 private var recorder: AVAudioRecorder?
 private var sessionID = UUID().uuidString
 private var audioURL: URL?

 func start() {
  guard !isRecording && !isUploading else { return }
  Task {
   let allowed = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
    AVAudioSession.sharedInstance().requestRecordPermission { continuation.resume(returning: $0) }
   }
   guard allowed else { error = "Microphone permission denied"; return }
   do {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.record, mode: .default)
    try session.setActive(true)
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".wav")
    let settings: [String: Any] = [AVFormatIDKey: Int(kAudioFormatLinearPCM), AVSampleRateKey: 16000, AVNumberOfChannelsKey: 1, AVLinearPCMBitDepthKey: 16, AVLinearPCMIsFloatKey: false]
    let next = try AVAudioRecorder(url: url, settings: settings)
    guard next.record() else { throw NSError(domain: "Voice", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not start recording"]) }
    audioURL = url; recorder = next; sessionID = UUID().uuidString
    transcript = ""; error = ""; isRecording = true
    VoiceBridge.publish("", session: sessionID, active: true)
   } catch { self.error = error.localizedDescription }
  }
 }
 func stop() {
  guard isRecording else { return }
  recorder?.stop(); recorder = nil; isRecording = false
  try? AVAudioSession.sharedInstance().setActive(false)
  guard let url = audioURL else { return }
  audioURL = nil
  let completedSession = sessionID
  let completedLanguage = language
  isUploading = true
  Task {
   defer { isUploading = false; try? FileManager.default.removeItem(at: url) }
   do {
    let text = try await CloudASRClient.transcribe(url: url, language: completedLanguage == "my-MM" ? "my" : "en")
    guard completedSession == sessionID else { return }
    transcript = text
    VoiceBridge.publish(text, session: completedSession, active: true)
   } catch { self.error = error.localizedDescription }
  }
 }
}

private enum CloudASRClient {
 // Set these at build time via an untracked xcconfig or build environment.
 // NEVER ship a permanent shared server token in a public app.
 static func transcribe(url: URL, language: String) async throws -> String {
  guard let address = Bundle.main.object(forInfoDictionaryKey: "ASRServerURL") as? String,
        let endpoint = URL(string: address), endpoint.scheme == "https" else {
   throw NSError(domain: "CloudASR", code: 1, userInfo: [NSLocalizedDescriptionKey: "Configure HTTPS ASRServerURL in host app Info.plist"])
  }
  guard let token = Bundle.main.object(forInfoDictionaryKey: "ASRPrototypeToken") as? String, !token.isEmpty else {
   throw NSError(domain: "CloudASR", code: 2, userInfo: [NSLocalizedDescriptionKey: "Prototype token missing; production requires user-scoped auth"])
  }
  let bytes = try Data(contentsOf: url)
  guard !bytes.isEmpty, bytes.count <= 12 * 1024 * 1024 else {
   throw NSError(domain: "CloudASR", code: 3, userInfo: [NSLocalizedDescriptionKey: "Recording must be below 12 MiB"])
  }
  let boundary = "Voice-" + UUID().uuidString
  var body = Data()
  func append(_ string: String) { body.append(Data(string.utf8)) }
  append("--\(boundary)\r\nContent-Disposition: form-data; name=\"language\"\r\n\r\n\(language)\r\n")
  append("--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"voice.wav\"\r\nContent-Type: audio/wav\r\n\r\n")
  body.append(bytes)
  append("\r\n--\(boundary)--\r\n")
  var request = URLRequest(url: endpoint.appendingPathComponent("v1/transcribe"))
  request.httpMethod = "POST"
  request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.httpBody = body
  request.timeoutInterval = 45
  let (responseData, response) = try await URLSession.shared.data(for: request)
  guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
   throw NSError(domain: "CloudASR", code: 4, userInfo: [NSLocalizedDescriptionKey: "Server transcription failed"])
  }
  struct Result: Decodable { let text: String }
  return try JSONDecoder().decode(Result.self, from: responseData).text
 }
}

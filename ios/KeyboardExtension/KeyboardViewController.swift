import UIKit

final class KeyboardViewController: UIInputViewController {
 private var myanmar = true
 private var symbols = false
 private var shift = false
 private var numberPad = false
 private var keyboardHeight: CGFloat = 43
 private let shortcuts: [String: String] = [:] // User-configured shortcuts will be loaded from local settings
 private var stack = UIStackView()
 private var isSecureContext: Bool { textDocumentProxy.documentContextBeforeInput == nil && textDocumentProxy.documentContextAfterInput == nil }
 private var heightConstraint: NSLayoutConstraint?
 private let voiceStore = UserDefaults(suiteName: "group.org.minsithu.yaypar.voice")
 private var voiceTimer: Timer?
 private var lastVoiceRevision: String?
 private var voiceSession: String?
 private var insertedVoiceText = ""
 private var voiceInsertionEnabled = false
 private var voiceArmSession: String?
 override func viewWillAppear(_ animated: Bool) {
  super.viewWillAppear(animated)
  voiceTimer?.invalidate()
  voiceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in self?.pollVoice() }
 }
 override func viewWillDisappear(_ animated: Bool) {
  super.viewWillDisappear(animated)
  voiceTimer?.invalidate(); voiceTimer = nil
  voiceInsertionEnabled = false
 }
 private func pollVoice() {
  guard hasFullAccess, !isSecureContext, let store = voiceStore else { return }
  guard let revision = store.string(forKey: "voice.revision"), revision != lastVoiceRevision else { return }
  lastVoiceRevision = revision
  let session = store.string(forKey: "voice.session") ?? ""
  let text = store.string(forKey: "voice.currentText") ?? ""
  if voiceSession != session {
   voiceSession = session
   insertedVoiceText = ""
   voiceInsertionEnabled = false
   voiceArmSession = nil
  }
  guard voiceInsertionEnabled, voiceArmSession == session, !text.isEmpty else { return }
  // Only replace our own suffix when the host still exposes it at the caret.
  let before = textDocumentProxy.documentContextBeforeInput ?? ""
  if !insertedVoiceText.isEmpty && !before.hasSuffix(insertedVoiceText) {
   voiceInsertionEnabled = false // User edited or moved the caret: never delete their text.
   return
  }
  if !insertedVoiceText.isEmpty {
   for _ in insertedVoiceText { textDocumentProxy.deleteBackward() }
  }
  textDocumentProxy.insertText(text)
  insertedVoiceText = text
  voiceInsertionEnabled = false // One completed transcription per session; no repeated insertion.
 }

 private let myRows = ["ဆတနမအပကငသစဟ", "ေျိ်ါ့ြုူး", "ဖထခလဘညဒဓဂရဝ", "ဇဈဗံယွဿ"]
 private let enRows = ["qwertyuiop", "asdfghjkl", "zxcvbnm"]
 private let symRows = ["1234567890", "@#$%&-+()", "*/:;!?.,"]
 override func viewDidLoad() { super.viewDidLoad(); build() }
 override func viewWillLayoutSubviews() { super.viewWillLayoutSubviews(); updateColors() }
 private func build() {
  heightConstraint?.isActive = false
  stack.removeFromSuperview()
  stack = UIStackView(); stack.axis = .vertical; stack.spacing = 5
  stack.translatesAutoresizingMaskIntoConstraints = false
  view.addSubview(stack)
  NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6)])
  let top = row([myanmar ? "မြန်မာ" : "English", "#+=", "123", "Paste", "🎙", "◀", "▶", "Size"]); stack.addArrangedSubview(top)
  let rows = numberPad ? ["123", "456", "789", ".0,"] : (symbols ? symRows : (myanmar ? myRows : enRows))
  for r in rows { stack.addArrangedSubview(row(r.map { String($0) })) }
  stack.addArrangedSubview(row(["⇧", "🌐", "space", "⌫", "↵"]))
  let rowCount = CGFloat(stack.arrangedSubviews.count)
  let desiredHeight = rowCount * keyboardHeight + max(0, rowCount - 1) * stack.spacing + 12
  heightConstraint = view.heightAnchor.constraint(equalToConstant: desiredHeight)
  heightConstraint?.priority = .defaultHigh
  heightConstraint?.isActive = true
  updateColors()
 }
 private func row(_ keys: [String]) -> UIStackView {
  let line = UIStackView(); line.axis = .horizontal; line.distribution = .fill; line.spacing = 4
  for key in keys {
   let b = UIButton(type: .system); b.setTitle(key, for: .normal); b.titleLabel?.font = .systemFont(ofSize: key == "space" ? 13 : 19, weight: .regular)
   b.layer.cornerRadius = 6; b.heightAnchor.constraint(equalToConstant: keyboardHeight).isActive = true
   b.translatesAutoresizingMaskIntoConstraints = false
   b.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
   b.titleLabel?.adjustsFontSizeToFitWidth = true
   b.titleLabel?.minimumScaleFactor = 0.5
   b.accessibilityHint = key == "space" ? "Tap for space; swipe to move cursor" : nil
   b.accessibilityLabel = key; if key != "🌐" { b.addAction(UIAction { [weak self] _ in self?.pressed(key) }, for: .touchUpInside) }
   if key == "🌐" { b.addTarget(self, action: #selector(advanceToNextInputMode), for: .touchUpInside) }
   if key == "space" { let pan = UIPanGestureRecognizer(target: self, action: #selector(spacePanned(_:))); pan.cancelsTouchesInView = true; b.addGestureRecognizer(pan) }
   line.addArrangedSubview(b)
  }
  let buttons = line.arrangedSubviews.compactMap { $0 as? UIButton }
  if let first = buttons.first {
   for button in buttons.dropFirst() {
    let ratio: CGFloat = button.currentTitle == "space" ? 4 : ((button.currentTitle == "⌫" || button.currentTitle == "↵") ? 1.3 : 1)
    let constraint = button.widthAnchor.constraint(equalTo: first.widthAnchor, multiplier: ratio)
    constraint.priority = .defaultHigh
    constraint.isActive = true
   }
  }
  return line
 }
 private func pressed(_ key: String) {
  switch key {
  case "မြန်မာ", "English": myanmar.toggle(); symbols = false; numberPad = false; build()
  case "#+=": symbols.toggle(); numberPad = false; build()
  case "123": numberPad.toggle(); symbols = false; build()
  case "Size": keyboardHeight = keyboardHeight == 43 ? 51 : (keyboardHeight == 51 ? 38 : 43); build()
  case "🎙":
   // iOS forbids microphone access from a keyboard extension.
   // The user must manually start a session in the companion app.
   // Never claim this key starts recording.
   voiceInsertionEnabled = hasFullAccess && !isSecureContext
   voiceArmSession = voiceStore?.string(forKey: "voice.session")
   // Arm only for the current session; never paste an unrelated session.
   lastVoiceRevision = voiceStore?.string(forKey: "voice.revision")
   pollVoice()
  case "Paste":
   // Explicit user action only; iOS may request pasteboard access.
   if hasFullAccess && !isSecureContext, let text = UIPasteboard.general.string { textDocumentProxy.insertText(text) }
  case "◀": textDocumentProxy.adjustTextPosition(byCharacterOffset: -1)
  case "▶": textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
  case "⇧": if !myanmar && !symbols && !numberPad { shift.toggle(); build() }
  case "🌐": break
  case "space":
   let before = isSecureContext ? "" : (textDocumentProxy.documentContextBeforeInput ?? "")
   if let shortcut = shortcuts.keys.sorted(by: { $0.count > $1.count }).first(where: { before.hasSuffix($0) }), let expansion = shortcuts[shortcut] {
    for _ in shortcut { textDocumentProxy.deleteBackward() }
    textDocumentProxy.insertText(expansion + " ")
   } else { textDocumentProxy.insertText(" ") }
  case "⌫": textDocumentProxy.deleteBackward() // Host handles deletion semantics
  case "↵": textDocumentProxy.insertText("\n")
  default: textDocumentProxy.insertText(shift && !myanmar && !symbols ? key.uppercased() : key); if shift { shift = false; build() }
  }
 }
 @objc private func spacePanned(_ gesture: UIPanGestureRecognizer) {
  let x = gesture.translation(in: gesture.view).x
  if gesture.state == .changed && abs(x) >= 18 {
   let steps = Int(x / 18)
   textDocumentProxy.adjustTextPosition(byCharacterOffset: steps)
   gesture.setTranslation(.zero, in: gesture.view)
  }
 }
 private func updateColors() {
  let dark = traitCollection.userInterfaceStyle == .dark
  view.backgroundColor = dark ? UIColor(red: 0.13, green: 0.14, blue: 0.16, alpha: 1) : UIColor(red: 0.9, green: 0.92, blue: 0.94, alpha: 1)
  for row in stack.arrangedSubviews.compactMap({ $0 as? UIStackView }) { for button in row.arrangedSubviews.compactMap({ $0 as? UIButton }) {
    button.backgroundColor = dark ? UIColor(white: 0.28, alpha: 1) : .white
    button.setTitleColor(dark ? .white : .black, for: .normal)
  } }
 }
}

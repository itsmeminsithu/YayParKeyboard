package org.minsithu.yaypar

import android.content.ClipboardManager
import android.content.Context
import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.os.Bundle
import android.widget.Toast
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.inputmethodservice.InputMethodService
import android.view.Gravity
import android.view.MotionEvent
import android.view.inputmethod.ExtractedTextRequest
import android.text.InputType
import java.text.BreakIterator
import java.util.Locale
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.Button
import android.widget.LinearLayout

class KeyboardService : InputMethodService() {
 private var myanmar = true
 private var symbols = false
 private var shift = false
 private var numberPad = false
 private var keyHeight = 47
 private val shortcuts = emptyMap<String, String>() // Never insert a fabricated email address
 private var root: LinearLayout? = null
 private var secureField = false
 private var speech: SpeechRecognizer? = null
 private var listening = false
 private val myRows = listOf("ဆတနမအပကငသစဟ", "ေျိ်ါ့ြုူး", "ဖထခလဘညဒဓဂရဝ", "ဇဈဗံယွဿ")
 private val enRows = listOf("qwertyuiop", "asdfghjkl", "zxcvbnm")
 private val symRows = listOf("1234567890", "@#₹$%&-+()", "*/:;!?\"'.,")
 override fun onStartInput(attribute: EditorInfo?, restarting: Boolean) {
  super.onStartInput(attribute, restarting)
  val variation = (attribute?.inputType ?: 0) and InputType.TYPE_MASK_VARIATION
  val inputClass = (attribute?.inputType ?: 0) and InputType.TYPE_MASK_CLASS
  secureField = (inputClass == InputType.TYPE_CLASS_TEXT && (variation == InputType.TYPE_TEXT_VARIATION_PASSWORD ||
   variation == InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD || variation == InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD)) ||
   (inputClass == InputType.TYPE_CLASS_NUMBER && variation == InputType.TYPE_NUMBER_VARIATION_PASSWORD)
  if (root != null) redraw()
 }
 override fun onCreateInputView(): View {
  root = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL; setPadding(4,8,4,8) }
  redraw(); return root!!
 }
 private fun key(label: String, weight: Float = 1f, action: () -> Unit): Button = Button(this).apply {
  text = label; textSize = if (label.length > 3) 13f else 19f; isAllCaps = false
  minHeight = 0; minimumHeight = 0; setPadding(0,0,0,0)
  val dark = (resources.configuration.uiMode and 0x30) == 0x20
  setTextColor(if (dark) Color.WHITE else Color.rgb(30,33,38))
  background = GradientDrawable().apply { cornerRadius = 12f * resources.displayMetrics.density; setColor(if (dark) Color.rgb(64,67,73) else Color.WHITE) }
  setOnClickListener { action() }
  layoutParams = LinearLayout.LayoutParams(0, (keyHeight * resources.displayMetrics.density).toInt(), weight).apply { setMargins(2,3,2,3) }
 }
 private fun commit(s: String) { currentInputConnection?.commitText(s,1) }
 private fun commitSpace() {
  val ic = currentInputConnection ?: return
  val before = if (secureField) "" else ic.getTextBeforeCursor(80, 0)?.toString().orEmpty()
  val match = shortcuts.entries.firstOrNull { before.endsWith(it.key) }
  if (match != null) { ic.deleteSurroundingText(match.key.length, 0); ic.commitText(match.value + " ", 1) }
  else ic.commitText(" ", 1)
 }
 private fun moveCursor(delta: Int) {
  val ic = currentInputConnection ?: return
  val extracted = ic.getExtractedText(ExtractedTextRequest(), 0) ?: return
  val absoluteEnd = extracted.startOffset + (extracted.text?.length ?: 0)
  // ExtractedText selection offsets are absolute editor offsets, not relative to startOffset.
  val selection = if (delta < 0) extracted.selectionStart else extracted.selectionEnd
  if (selection < 0) return
  val text = extracted.text?.toString() ?: return
  val local = (selection - extracted.startOffset).coerceIn(0, text.length)
  val nextLocal = if (delta < 0) {
   if (local == 0) 0 else text.offsetByCodePoints(local, -1)
  } else {
   if (local == text.length) local else text.offsetByCodePoints(local, 1)
  }
  val position = (extracted.startOffset + nextLocal).coerceIn(extracted.startOffset, absoluteEnd)
  ic.setSelection(position, position)
 }
 private fun delete() {
  val ic = currentInputConnection ?: return
  if (!ic.getSelectedText(0).isNullOrEmpty()) { ic.commitText("", 1); return }
  val before = ic.getTextBeforeCursor(256, 0)?.toString().orEmpty()
  if (before.isEmpty()) return
  // Character-boundary approximation using locale-neutral Unicode break iteration.
  // Myanmar virama/medial clusters still require native-speaker device testing.
  val iterator = BreakIterator.getCharacterInstance(Locale.forLanguageTag(if (myanmar) "my-MM" else "en"))
  iterator.setText(before)
  val previous = iterator.preceding(before.length)
  if (previous != BreakIterator.DONE && previous < before.length) {
   ic.deleteSurroundingText(before.length - previous, 0)
  }
 }
 private fun startVoice() {
  if (secureField) return
  if (checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
   Toast.makeText(this, "Open Myanmar Keyboard app to enable microphone permission", Toast.LENGTH_LONG).show()
   startActivity(Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
   return
  }
  if (!SpeechRecognizer.isRecognitionAvailable(this)) {
   Toast.makeText(this, "Speech recognition is unavailable on this device", Toast.LENGTH_LONG).show(); return
  }
  if (listening) { speech?.stopListening(); return }
  speech?.destroy()
  speech = SpeechRecognizer.createSpeechRecognizer(this).also { recognizer ->
   recognizer.setRecognitionListener(object : RecognitionListener {
    override fun onReadyForSpeech(params: Bundle?) { listening = true }
    override fun onBeginningOfSpeech() {}
    override fun onRmsChanged(rmsdB: Float) {}
    override fun onBufferReceived(buffer: ByteArray?) {}
    override fun onEndOfSpeech() {}
    override fun onError(error: Int) { listening = false; Toast.makeText(this@KeyboardService, "Voice recognition failed ($error)", Toast.LENGTH_SHORT).show() }
    override fun onResults(results: Bundle?) {
     listening = false
     if (!secureField) results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull()?.let { commit(it) }
    }
    override fun onPartialResults(partialResults: Bundle?) {}
    override fun onEvent(eventType: Int, params: Bundle?) {}
   })
   recognizer.startListening(Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
    putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
    putExtra(RecognizerIntent.EXTRA_LANGUAGE, if (myanmar) "my-MM" else "en-US")
    putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
   })
  }
 }
 override fun onFinishInput() { speech?.cancel(); speech?.destroy(); speech = null; listening = false; super.onFinishInput() }
 override fun onDestroy() { speech?.destroy(); speech = null; super.onDestroy() }
 private fun redraw() {
  val container = root ?: return; container.removeAllViews()
  val dark = (resources.configuration.uiMode and 0x30) == 0x20
  container.setBackgroundColor(if (dark) Color.rgb(29,31,35) else Color.rgb(232,235,240))
  val top = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL }
  top.addView(key(if (myanmar) "မြန်မာ" else "English", 2f) { myanmar = !myanmar; symbols = false; redraw() })
  top.addView(key("#+=", 1f) { symbols = !symbols; numberPad = false; redraw() })
  top.addView(key("123", 1f) { numberPad = !numberPad; symbols = false; redraw() })
  top.addView(key(if (secureField) "Private" else "Paste", 1.4f) {
   if (secureField) return@key
   // Only access the clipboard after a user tap. Avoid persisting its contents.
   val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
   val clip = clipboard.primaryClip
   if (clip != null && clip.itemCount > 0) {
    val item = clip.getItemAt(0)
    item?.coerceToText(this)?.toString()?.takeIf { it.isNotEmpty() }?.let { commit(it) }
   }
  })
  top.addView(key(if (secureField) "🔒" else "🎤", 1f) { if (!secureField) startVoice() })
  top.addView(key("◀", 1f) { moveCursor(-1) })
  top.addView(key("▶", 1f) { moveCursor(1) })
  top.addView(key("Size", 1f) { keyHeight = when(keyHeight) { 47 -> 55; 55 -> 40; else -> 47 }; redraw() })
  container.addView(top)
  val rows = if (numberPad) listOf("123", "456", "789", ".0,") else if (symbols) symRows else if (myanmar) myRows else enRows
  for (row in rows) {
   val line = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL; gravity = Gravity.CENTER }
   for (c in row) line.addView(key(if (shift && !myanmar && !symbols) c.uppercase() else c.toString()) { commit(if (shift && !myanmar && !symbols) c.uppercase() else c.toString()); if (shift) { shift = false; redraw() } })
   container.addView(line)
  }
  val bottom = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL }
  bottom.addView(key("🌐") { (getSystemService(INPUT_METHOD_SERVICE) as android.view.inputmethod.InputMethodManager).showInputMethodPicker() })
  bottom.addView(key("⇧") { if (!myanmar && !symbols && !numberPad) { shift = !shift; redraw() } })
  bottom.addView(key("၊") { commit(if (myanmar) "၊" else ",") })
  val space = key("space", 5f) { commitSpace() }
  space.contentDescription = "Space. Swipe horizontally to move cursor"
  var startX = 0f
  var lastStep = 0
  var swiped = false
  space.setOnTouchListener { v, event ->
   when(event.actionMasked) {
    MotionEvent.ACTION_DOWN -> { startX = event.x; lastStep = 0; swiped = false; true }
    MotionEvent.ACTION_MOVE -> {
     val step = ((event.x - startX) / (18f * resources.displayMetrics.density)).toInt()
     val diff = step - lastStep
     if (diff != 0) { moveCursor(diff); lastStep = step; swiped = true }
     true
    }
    MotionEvent.ACTION_UP -> { if (!swiped) commitSpace(); v.performClick(); true }
    MotionEvent.ACTION_CANCEL -> true
    else -> false
   }
  }
  bottom.addView(space)
  bottom.addView(key("။") { commit(if (myanmar) "။" else ".") })
  bottom.addView(key("⌫", 1.3f) { delete() })
  bottom.addView(key("↵", 1.3f) {
   val action = currentInputEditorInfo?.imeOptions?.and(EditorInfo.IME_MASK_ACTION) ?: EditorInfo.IME_ACTION_NONE
   if (action != EditorInfo.IME_ACTION_NONE && action != EditorInfo.IME_ACTION_UNSPECIFIED) currentInputConnection?.performEditorAction(action) else commit("\n")
  })
  container.addView(bottom)
 }
}

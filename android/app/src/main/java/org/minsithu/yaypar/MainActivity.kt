package org.minsithu.yaypar

import android.app.Activity
import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.view.inputmethod.InputMethodManager

class MainActivity : Activity() {
 override fun onCreate(savedInstanceState: Bundle?) { super.onCreate(savedInstanceState)
  val root = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL; gravity = Gravity.CENTER; setPadding(32,32,32,32) }
  root.addView(TextView(this).apply { text = "ရေးပါ - Myanmar Keyboard\nUnicode • English • Private"; textSize = 23f; gravity = Gravity.CENTER })
  root.addView(Button(this).apply { text = "1. Enable Keyboard"; setOnClickListener { startActivity(Intent(Settings.ACTION_INPUT_METHOD_SETTINGS)) } })
  root.addView(Button(this).apply { text = "2. Choose Keyboard"; setOnClickListener { (getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager).showInputMethodPicker() } })
  root.addView(Button(this).apply { text = "3. Enable Voice Typing Permission"; setOnClickListener {
   if (checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED)
    requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), 100)
  } })
  root.addView(TextView(this).apply { text = "No internet permission. No keystrokes uploaded.\nChange keyboard theme in system dark mode."; gravity = Gravity.CENTER })
  setContentView(root)
 }
}

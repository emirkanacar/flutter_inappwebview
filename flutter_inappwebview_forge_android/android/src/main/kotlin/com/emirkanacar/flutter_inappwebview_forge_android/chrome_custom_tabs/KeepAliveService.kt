package com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder

open class KeepAliveService : Service() {
    companion object {
        private val sBinder = Binder()
    }

    override fun onBind(intent: Intent): IBinder = sBinder
}

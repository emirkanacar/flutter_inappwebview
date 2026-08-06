package com.emirkanacar.flutter_inappwebview_forge_android

import androidx.core.content.FileProvider

class InAppWebViewFileProvider : FileProvider() {
    companion object {
        @JvmField
        val fileProviderAuthorityExtension = "flutter_inappwebview_android.fileprovider"
    }
}

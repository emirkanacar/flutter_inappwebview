package com.emirkanacar.flutter_inappwebview_forge_android.types

open class WebMessage(
    @JvmField var data: String?,
    @JvmField var ports: MutableList<WebMessagePort>?
) : Disposable {
    override fun dispose() {
        ports?.clear()
    }
}

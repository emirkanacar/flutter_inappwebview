package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.os.Build
import android.print.PrintJobInfo
import androidx.annotation.RequiresApi
import java.util.HashMap

@RequiresApi(Build.VERSION_CODES.KITKAT)
open class PrintJobInfoExt {
    private var state: Int = 0
    private var copies: Int = 0
    private var numberOfPages: Int? = null
    private var creationTime: Long = 0L
    private var label: String = ""
    private var printerId: String? = null
    private var attributes: PrintAttributesExt? = null

    companion object {
        @JvmStatic
        fun fromPrintJobInfo(info: PrintJobInfo?): PrintJobInfoExt? {
            if (info == null) return null

            val result = PrintJobInfoExt()
            result.state = info.getState()
            result.copies = info.getCopies()
            result.numberOfPages = info.getPages()?.size
            result.creationTime = info.getCreationTime()
            result.label = info.getLabel()
            result.printerId = info.getPrinterId()?.getLocalId()
            result.attributes = PrintAttributesExt.fromPrintAttributes(info.getAttributes())
            return result
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("state", state)
        put("copies", copies)
        put("numberOfPages", numberOfPages)
        put("creationTime", creationTime)
        put("label", label)
        put("printer", HashMap<String, Any?>().apply { put("id", printerId) })
        put("attributes", attributes?.toMap())
    }
}

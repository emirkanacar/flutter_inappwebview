package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.os.Build
import android.print.PrintAttributes
import androidx.annotation.RequiresApi
import java.util.HashMap

@RequiresApi(Build.VERSION_CODES.KITKAT)
open class PrintAttributesExt {
    private var colorMode: Int = 0
    private var duplex: Int? = null
    private var orientation: Int? = null
    private var mediaSize: MediaSizeExt? = null
    private var resolution: ResolutionExt? = null
    private var margins: MarginsExt? = null

    companion object {
        @JvmStatic
        fun fromPrintAttributes(attributes: PrintAttributes?): PrintAttributesExt? {
            if (attributes == null) return null

            val attributesExt = PrintAttributesExt()
            attributesExt.colorMode = attributes.getColorMode()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                attributesExt.duplex = attributes.getDuplexMode()
            }
            val mediaSize = attributes.getMediaSize()
            if (mediaSize != null) {
                attributesExt.mediaSize = MediaSizeExt.fromMediaSize(mediaSize)
                attributesExt.orientation = if (mediaSize.isPortrait()) 0 else 1
            }
            attributesExt.resolution = ResolutionExt.fromResolution(attributes.getResolution())
            attributesExt.margins = MarginsExt.fromMargins(attributes.getMinMargins())
            return attributesExt
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("colorMode", colorMode)
        put("duplex", duplex)
        put("orientation", orientation)
        put("mediaSize", mediaSize?.toMap())
        put("resolution", resolution?.toMap())
        put("margins", margins?.toMap())
    }
}

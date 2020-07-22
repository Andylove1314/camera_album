package com.custom.camera_album

import android.content.Context
import android.view.View
import android.widget.TextView
import com.custom.camera_album.task.GuideView
import io.flutter.plugin.platform.PlatformView

class FlutterInsertView(context: Context) : PlatformView {
    
    ///用于穿透的view，可以自定义
    val contentView: TextView = TextView(context)
    
    override fun getView(): View {
        return contentView
    }
    override fun dispose() {}
}
package com.custom.camera_album

import android.content.Context
import android.view.View
import com.custom.camera_album.task.FlutterAlbum
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class FlutterInsertView(context: Context, channel: MethodChannel) : PlatformView {

    var channel = channel
    ///用于穿透的view，可以自定义
    val contentView: FlutterAlbum = FlutterAlbum(context)

    
    override fun getView(): View {
        contentView.setChannel(channel)
        return contentView
    }
    override fun dispose() {}
}
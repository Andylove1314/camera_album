package com.custom.camera_album

import android.content.Context
import android.view.View
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class FlutterInsertView(context: Context, channel: MethodChannel, args: Any?) : PlatformView {

    var chan = channel
    var param = args as Map<String, Object>

    //用于穿透的view，可以自定义
    val albun: FlutterAlbum = FlutterAlbum(context, chan, param)

    override fun getView(): View {
        return albun
    }
    override fun dispose() {

    }
}
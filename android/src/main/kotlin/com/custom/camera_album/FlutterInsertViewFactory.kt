package com.custom.camera_album

import android.content.Context
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

///穿透专用
class AndroidTextViewFactory(context: Context, channel: MethodChannel) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    var con = context
    var channel = channel

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val platform = FlutterInsertView(con, channel, args)
        platform.albun?.id = viewId

        return platform
        
    }
}
package com.custom.camera_album

import android.content.Context
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

///穿透专用
class AndroidTextViewFactory(con: Context, channel: MethodChannel) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    var con = con
    var channel = channel

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val androidTextView = FlutterInsertView(con,channel)
        androidTextView.contentView?.id = viewId
        return androidTextView
        
    }
}
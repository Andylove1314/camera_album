package com.custom.camera_album

import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformViewFactory

///穿透专用
class FlutterInsertViewFactory(context: Context, channel: MethodChannel) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    var con = context
    var channel = channel
    var platform:FlutterInsertView? = null

    override fun create(context: Context, viewId: Int, args: Any?): FlutterInsertView {
        platform = FlutterInsertView(con, channel, args)
        platform?.albun?.id = viewId

        return platform as FlutterInsertView
        
    }

    fun post(data: Intent?) {
        platform?.albun?.singleCropHandleResult(data)
    }

}
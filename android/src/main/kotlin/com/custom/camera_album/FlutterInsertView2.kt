package com.custom.camera_album

import android.content.Context
import android.view.View
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class FlutterInsertView2(context: Context, channel: MethodChannel, args: Any?) : PlatformView {

    var chan = channel
    var param = args as Map<String, Object>

    //用于穿透的view，可以自定义
    val camera: FlutterCamera = FlutterCamera(context,chan)

    override fun getView(): View {
        return camera
    }
    override fun dispose() {

        if (camera != null){
            camera?.onOestory()
        }

    }
}
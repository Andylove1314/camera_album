package com.custom.camera_album

import android.content.Context
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformViewFactory

///穿透专用
class FlutterInsertViewFactory2(context: Context, channel: MethodChannel) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    var con = context
    var channel = channel
    var platform:FlutterInsertView2? = null

    override fun create(context: Context, viewId: Int, args: Any?): FlutterInsertView2 {
        platform = FlutterInsertView2(con, channel, args)
        platform?.camera?.id = viewId
        return platform as FlutterInsertView2
    }
    
    fun takePhoto(){
        platform?.camera?.takePictures()
    }

    fun switchCamera(){
        platform?.camera?.toggleCamera()
    }

    fun setFlashMode(){
        platform?.camera?.setFlashMode()
    }


    fun startRecord(){
        platform?.camera?.recordStart()
    }
    
    fun stopRecord(){
        platform?.camera?.recordEnd(5000)
    }
    
    fun initCameraView(){
        platform?.camera?.initView()
    }

    fun checkCameraPermission(){
        platform?.camera?.checkCameraPermission()
    }

    fun showPermissionsDialog(isCamera: Boolean, errorMsg:String) {
        platform?.camera?.showPermissionsDialog(isCamera, errorMsg)
    }


}
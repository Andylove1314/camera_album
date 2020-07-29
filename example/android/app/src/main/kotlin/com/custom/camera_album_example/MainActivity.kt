package com.custom.camera_album_example

import com.custom.camera_album.AndroidTextViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        ///注册相应插件
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        ///注册原生view
       var channel = MethodChannel(flutterEngine.getDartExecutor(), "flutter/camera_album")
        val registry = flutterEngine.platformViewsController.registry
        registry.registerViewFactory("platform_gallery_view", AndroidTextViewFactory(this,channel))

    }
    
}

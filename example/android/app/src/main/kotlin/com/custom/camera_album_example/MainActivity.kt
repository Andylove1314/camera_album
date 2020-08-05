package com.custom.camera_album_example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.camera.camera2.Camera2Config

import androidx.camera.core.CameraXConfig


class MainActivity: FlutterActivity(){

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        ///注册相应插件
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}

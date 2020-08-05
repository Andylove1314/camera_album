package com.custom.camera_album_example;

import android.app.Application;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.camera.camera2.Camera2Config;
import androidx.camera.core.CameraXConfig;

import com.luck.picture.lib.app.IApp;
import com.luck.picture.lib.app.PictureAppMaster;
import com.luck.picture.lib.crash.PictureSelectorCrashUtils;
import com.luck.picture.lib.engine.PictureSelectorEngine;

import io.flutter.app.FlutterApplication;


/**
 * @author：luck
 * @date：2019-12-03 22:53
 * @describe：Application
 */

public class App extends FlutterApplication implements CameraXConfig.Provider {
    private static final String TAG = App.class.getSimpleName();

    @Override
    public void onCreate() {
        super.onCreate();

    }


    @NonNull
    @Override
    public CameraXConfig getCameraXConfig() {
        return Camera2Config.defaultConfig();
    }
}

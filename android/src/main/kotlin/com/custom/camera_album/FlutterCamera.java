package com.custom.camera_album;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.media.MediaPlayer;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.CameraX;
import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureException;
import androidx.camera.core.VideoCapture;
import androidx.camera.view.CameraView;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;

import com.luck.picture.lib.PictureMediaScannerConnection;
import com.luck.picture.lib.PictureSelectionModel;
import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.R;
import com.luck.picture.lib.camera.listener.CameraListener;
import com.luck.picture.lib.camera.listener.ImageCallbackListener;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureMimeType;
import com.luck.picture.lib.config.PictureSelectionConfig;
import com.luck.picture.lib.dialog.PictureCustomDialog;
import com.luck.picture.lib.permissions.PermissionChecker;
import com.luck.picture.lib.thread.PictureThreadUtils;
import com.luck.picture.lib.tools.AndroidQTransformUtils;
import com.luck.picture.lib.tools.DateUtils;
import com.luck.picture.lib.tools.MediaUtils;
import com.luck.picture.lib.tools.PictureFileUtils;
import com.luck.picture.lib.tools.SdkVersionUtils;
import com.luck.picture.lib.tools.StringUtils;

import java.io.File;
import java.io.IOException;
import java.lang.ref.WeakReference;

import io.flutter.plugin.common.MethodChannel;

/**
 * @author：luck
 * @date：2020-01-04 13:41
 * @describe：自定义相机View
 */
public class FlutterCamera extends RelativeLayout {

    ///权限请求码
    public final static int APPLY_CAMERA_PERMISSIONS_CODE = 22;
    public final static int APPLY_STORAGE_PERMISSIONS_CODE = 11;

    /**
     * 闪关灯状态
     */
    private static final int TYPE_FLASH_AUTO = 0x021;
    private static final int TYPE_FLASH_ON = 0x022;
    private static final int TYPE_FLASH_OFF = 0x023;
    private int type_flash = TYPE_FLASH_OFF;
    private PictureSelectionConfig mConfig;
    /**
     * 回调监听
     */
    private CameraListener mCameraListener;
    private ImageCallbackListener mImageCallbackListener;
    private CameraView mCameraView;
    private ImageView mImagePreview;
    private MediaPlayer mMediaPlayer;
    private TextureView mTextureView;
    private long recordTime = 0;
    private File mVideoFile;
    private File mPhotoFile;

    private MethodChannel channel;

    /**
     * 相机view
     */
    private View view;

    public FlutterCamera(Context context, MethodChannel chan) {
        super(context);
        this.channel = chan;
        setWillNotDraw(false);
        setBackgroundColor(ContextCompat.getColor(getContext(), R.color.picture_color_black));
        checkCameraPermission();
    }

    /**
     * 检测相机权限
     */
    public void checkCameraPermission(){

        // 验证存储权限
        boolean isExternalStorage = PermissionChecker
                .checkSelfPermission(getContext(), Manifest.permission.READ_EXTERNAL_STORAGE) &&
                PermissionChecker
                        .checkSelfPermission(getContext(), Manifest.permission.WRITE_EXTERNAL_STORAGE);
        if (!isExternalStorage) {
            PermissionChecker.requestPermissions((Activity) getContext(), new String[]{
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE}, APPLY_STORAGE_PERMISSIONS_CODE);
        }else {
            // 验证相机权限
            if (PermissionChecker
                    .checkSelfPermission(getContext(), Manifest.permission.CAMERA)) {
                boolean isRecordAudio = PermissionChecker.checkSelfPermission(getContext(), Manifest.permission.RECORD_AUDIO);
                if (isRecordAudio) {
                    initView();
                } else {
                    ///验证麦克风权限
                    PermissionChecker.requestPermissions((Activity)getContext(),
                            new String[]{Manifest.permission.RECORD_AUDIO}, PictureConfig.APPLY_RECORD_AUDIO_PERMISSIONS_CODE);
                }
            } else {
                PermissionChecker.requestPermissions((Activity)getContext(),
                        new String[]{Manifest.permission.CAMERA}, APPLY_CAMERA_PERMISSIONS_CODE);
            }
        }
    }

    public void initView() {

        PictureSelectionModel cameraOrAlbum =  new PictureSelectionModel(PictureSelector.create((Activity)getContext()),PictureMimeType.ofImage());
        cameraOrAlbum
                .imageEngine(GlideEngine.createGlideEngine());
        setPictureSelectionConfig(cameraOrAlbum.selectionConfig);

        view = LayoutInflater.from(getContext()).inflate(R.layout.flutter_camera_view, this);
        mCameraView = view.findViewById(R.id.cameraView);
        mCameraView.enableTorch(true);
        mTextureView = view.findViewById(R.id.video_play_preview);
        mImagePreview = view.findViewById(R.id.image_preview);
        setFlashRes();
        setBindToLifecycle((LifecycleOwner) new WeakReference<>(getContext()).get());
        setImageCallbackListener((file, imageView) -> {
            if (mConfig != null && PictureSelectionConfig.imageEngine != null && file != null) {
                PictureSelectionConfig.imageEngine.loadImage(getContext(), file.getAbsolutePath(), imageView);
            }
        });

        // 设置拍照或拍视频回调监听
        setCameraListener(new CameraListener() {
            @Override
            public void onPictureSuccess(@NonNull File file) {
                Log.i("拍照成功", file.getAbsolutePath());
                channel.invokeMethod("onTakeDone", file.getPath());
            }

            @Override
            public void onRecordSuccess(@NonNull File file) {



            }

            @Override
            public void onError(int videoCaptureError, @NonNull String message, @Nullable Throwable cause) {
                Log.i("TAG", "onError: " + message);
            }
        });
//        toggleCamera();

    }

    /**
     * 拍照
     */
    public void takePictures() {

    if(view == null){
        return;
    }

        mCameraView.setCaptureMode(CameraView.CaptureMode.IMAGE);
        File imageOutFile = createImageFile();
        if (imageOutFile == null) {
            return;
        }
        mPhotoFile = imageOutFile;
        mCameraView.takePicture(imageOutFile, ContextCompat.getMainExecutor(getContext()),
                new MyImageResultCallback(getContext(), mConfig, imageOutFile,
                        mImagePreview, mImageCallbackListener, mCameraListener,mPhotoFile));
    }

    /**
     * 视频录制
     */
    public void recordStart() {

        if(view == null){
            return;
        }

        mCameraView.setCaptureMode(CameraView.CaptureMode.VIDEO);
        mCameraView.startRecording(createVideoFile(), ContextCompat.getMainExecutor(getContext()),
                new VideoCapture.OnVideoSavedCallback() {
                    @Override
                    public void onVideoSaved(@NonNull File file) {
                        mVideoFile = file;
                        if (recordTime < 1500 && mVideoFile.exists() && mVideoFile.delete()) {
                            return;
                        }
                        if (SdkVersionUtils.checkedAndroid_Q() && PictureMimeType.isContent(mConfig.cameraPath)) {
                            PictureThreadUtils.executeByIo(new PictureThreadUtils.SimpleTask<Boolean>() {

                                @Override
                                public Boolean doInBackground() {
                                    return AndroidQTransformUtils.copyPathToDCIM(getContext(),
                                            file, Uri.parse(mConfig.cameraPath));
                                }

                                @Override
                                public void onSuccess(Boolean result) {
                                    PictureThreadUtils.cancel(PictureThreadUtils.getIoPool());
                                }
                            });
                        }
                        mTextureView.setVisibility(View.VISIBLE);
                        mCameraView.setVisibility(View.INVISIBLE);
                        if (mTextureView.isAvailable()) {
                            startVideoPlay(mVideoFile);
                        } else {
                            mTextureView.setSurfaceTextureListener(surfaceTextureListener);
                        }

                        if (mVideoFile != null){
                            mCameraListener.onRecordSuccess(mVideoFile);
                        }

                    }

                    @Override
                    public void onError(int videoCaptureError, @NonNull String message, @Nullable Throwable cause) {
                        if (mCameraListener != null) {
                            mCameraListener.onError(videoCaptureError, message, cause);
                        }
                    }
                });
    }

    /**
     * 结束录制
     * @param time
     */
    public void recordEnd(long time) {

        if(view == null){
            return;
        }

        recordTime = time;
        mCameraView.stopRecording();
        channel.invokeMethod("onRecodeDone", mVideoFile.getPath());
    }
    /**
     * 拍照回调
     */
    private static class MyImageResultCallback implements ImageCapture.OnImageSavedCallback {
        private WeakReference<Context> mContextReference;
        private WeakReference<PictureSelectionConfig> mConfigReference;
        private WeakReference<File> mFileReference;
        private WeakReference<ImageView> mImagePreviewReference;
        private WeakReference<ImageCallbackListener> mImageCallbackListenerReference;
        private WeakReference<CameraListener> mCameraListenerReference;
        private WeakReference<File> mSavedFile;

        public MyImageResultCallback(Context context, PictureSelectionConfig config,
                                     File imageOutFile, ImageView imagePreview, ImageCallbackListener imageCallbackListener,
                                     CameraListener cameraListener,File savedFile) {
            super();
            this.mContextReference = new WeakReference<>(context);
            this.mConfigReference = new WeakReference<>(config);
            this.mFileReference = new WeakReference<>(imageOutFile);
            this.mImagePreviewReference = new WeakReference<>(imagePreview);
            this.mImageCallbackListenerReference = new WeakReference<>(imageCallbackListener);
            this.mCameraListenerReference = new WeakReference<>(cameraListener);
            this.mSavedFile = new WeakReference<>(savedFile);
        }

        @Override
        public void onImageSaved(@NonNull ImageCapture.OutputFileResults outputFileResults) {


            Log.i("拍照成功", "success 。。。。");

            if (mConfigReference.get() != null) {
                if (SdkVersionUtils.checkedAndroid_Q() && PictureMimeType.isContent(mConfigReference.get().cameraPath)) {
                    PictureThreadUtils.executeByIo(new PictureThreadUtils.SimpleTask<Boolean>() {

                        @Override
                        public Boolean doInBackground() {
                            return AndroidQTransformUtils.copyPathToDCIM(mContextReference.get(),
                                    mFileReference.get(), Uri.parse(mConfigReference.get().cameraPath));
                        }

                        @Override
                        public void onSuccess(Boolean result) {
                            PictureThreadUtils.cancel(PictureThreadUtils.getIoPool());
                        }
                    });
                }
            }
            if (mImageCallbackListenerReference.get() != null
                    && mFileReference.get() != null
                    && mImagePreviewReference.get() != null) {
                mImageCallbackListenerReference.get().onLoadImage(mFileReference.get(), mImagePreviewReference.get());
            }
            if (mImagePreviewReference.get() != null) {
                mImagePreviewReference.get().setVisibility(View.VISIBLE);
            }
            if (mCameraListenerReference.get() != null) {
                mCameraListenerReference.get().onPictureSuccess(mSavedFile.get());
            }

        }

        @Override
        public void onError(@NonNull ImageCaptureException exception) {
            if (mCameraListenerReference.get() != null) {
                mCameraListenerReference.get().onError(exception.getImageCaptureError(), exception.getMessage(), exception.getCause());
            }
        }
    }

    private TextureView.SurfaceTextureListener surfaceTextureListener = new TextureView.SurfaceTextureListener() {
        @Override
        public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
            startVideoPlay(mVideoFile);
        }

        @Override
        public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {

        }

        @Override
        public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
            return false;
        }

        @Override
        public void onSurfaceTextureUpdated(SurfaceTexture surface) {

        }
    };

    private File createImageFile() {
        if (SdkVersionUtils.checkedAndroid_Q()) {
            String diskCacheDir = PictureFileUtils.getDiskCacheDir(getContext());
            File rootDir = new File(diskCacheDir);
            if (!rootDir.exists() && rootDir.mkdirs()) {
            }
            boolean isOutFileNameEmpty = TextUtils.isEmpty(mConfig.cameraFileName);
            String suffix = TextUtils.isEmpty(mConfig.suffixType) ? PictureFileUtils.POSTFIX : mConfig.suffixType;
            String newFileImageName = isOutFileNameEmpty ? DateUtils.getCreateFileName("IMG_") + suffix : mConfig.cameraFileName;
            File cameraFile = new File(rootDir, newFileImageName);
            Uri outUri = getOutUri(PictureMimeType.ofImage());
            if (outUri != null) {
                mConfig.cameraPath = outUri.toString();
            }
            return cameraFile;
        } else {
            String cameraFileName = "";
            if (!TextUtils.isEmpty(mConfig.cameraFileName)) {
                boolean isSuffixOfImage = PictureMimeType.isSuffixOfImage(mConfig.cameraFileName);
                mConfig.cameraFileName = !isSuffixOfImage ? StringUtils.renameSuffix(mConfig.cameraFileName, PictureMimeType.JPEG) : mConfig.cameraFileName;
                cameraFileName = mConfig.camera ? mConfig.cameraFileName : StringUtils.rename(mConfig.cameraFileName);
            }
            File cameraFile = PictureFileUtils.createCameraFile(getContext(),
                    PictureMimeType.ofImage(), cameraFileName, mConfig.suffixType, mConfig.outPutCameraPath);
            if (cameraFile != null) {
                mConfig.cameraPath = cameraFile.getAbsolutePath();
            }
            return cameraFile;
        }
    }

    private File createVideoFile() {
        if (SdkVersionUtils.checkedAndroid_Q()) {
            String diskCacheDir = PictureFileUtils.getVideoDiskCacheDir(getContext());
            File rootDir = new File(diskCacheDir);
            if (!rootDir.exists() && rootDir.mkdirs()) {
            }
            boolean isOutFileNameEmpty = TextUtils.isEmpty(mConfig.cameraFileName);
            String suffix = TextUtils.isEmpty(mConfig.suffixType) ? PictureMimeType.MP4 : mConfig.suffixType;
            String newFileImageName = isOutFileNameEmpty ? DateUtils.getCreateFileName("VID_") + suffix : mConfig.cameraFileName;
            File cameraFile = new File(rootDir, newFileImageName);
            Uri outUri = getOutUri(PictureMimeType.ofVideo());
            if (outUri != null) {
                mConfig.cameraPath = outUri.toString();
            }
            return cameraFile;
        } else {
            String cameraFileName = "";
            if (!TextUtils.isEmpty(mConfig.cameraFileName)) {
                boolean isSuffixOfImage = PictureMimeType.isSuffixOfImage(mConfig.cameraFileName);
                mConfig.cameraFileName = !isSuffixOfImage ? StringUtils
                        .renameSuffix(mConfig.cameraFileName, PictureMimeType.MP4) : mConfig.cameraFileName;
                cameraFileName = mConfig.camera ? mConfig.cameraFileName : StringUtils.rename(mConfig.cameraFileName);
            }
            File cameraFile = PictureFileUtils.createCameraFile(getContext(),
                    PictureMimeType.ofVideo(), cameraFileName, mConfig.suffixType, mConfig.outPutCameraPath);
            mConfig.cameraPath = cameraFile.getAbsolutePath();
            return cameraFile;
        }
    }

    private Uri getOutUri(int type) {
        return type == PictureMimeType.ofVideo()
                ? MediaUtils.createVideoUri(getContext(), mConfig.suffixType) : MediaUtils.createImageUri(getContext(), mConfig.suffixType);
    }

    private void setCameraListener(CameraListener cameraListener) {
        this.mCameraListener = cameraListener;
    }

    private void setPictureSelectionConfig(PictureSelectionConfig config) {
        this.mConfig = config;
    }

    private void setBindToLifecycle(LifecycleOwner lifecycleOwner) {
        mCameraView.bindToLifecycle(lifecycleOwner);
        lifecycleOwner.getLifecycle().addObserver((LifecycleEventObserver) (source, event) -> {

        });
    }

    private void setImageCallbackListener(ImageCallbackListener mImageCallbackListener) {
        this.mImageCallbackListener = mImageCallbackListener;
    }

    private void setFlashRes() {

        type_flash++;
        if (type_flash > 0x023)
            type_flash = TYPE_FLASH_AUTO;

        switch (type_flash) {
            case TYPE_FLASH_AUTO:
                mCameraView.setFlash(ImageCapture.FLASH_MODE_AUTO);
                break;
            case TYPE_FLASH_ON:
                mCameraView.setFlash(ImageCapture.FLASH_MODE_ON);
                break;
            case TYPE_FLASH_OFF:
                mCameraView.setFlash(ImageCapture.FLASH_MODE_OFF);
                break;
        }
    }

    /**
     * 设置闪光的灯模式
     */
    public void setFlashMode() {

        if(view == null){
            return;
        }

        type_flash++;
        if (type_flash > 0x023)
            type_flash = TYPE_FLASH_AUTO;

        setFlashRes();
    }



    /**
     * 切换摄像头
     */
    public void toggleCamera(){

        if(view == null){
            return;
        }

        mCameraView.toggleCamera();
    }

    /**
     * 重置状态
     */
    private void resetState() {
        if (mCameraView.getCaptureMode() == CameraView.CaptureMode.VIDEO) {
            if (mCameraView.isRecording()) {
                mCameraView.stopRecording();
            }
            if (mVideoFile != null && mVideoFile.exists()) {
                mVideoFile.delete();
                if (SdkVersionUtils.checkedAndroid_Q() && PictureMimeType.isContent(mConfig.cameraPath)) {
                    getContext().getContentResolver().delete(Uri.parse(mConfig.cameraPath), null, null);
                } else {
                    new PictureMediaScannerConnection(getContext(), mVideoFile.getAbsolutePath());
                }
            }
        } else {
            mImagePreview.setVisibility(INVISIBLE);
            if (mPhotoFile != null && mPhotoFile.exists()) {
                mPhotoFile.delete();
                if (SdkVersionUtils.checkedAndroid_Q() && PictureMimeType.isContent(mConfig.cameraPath)) {
                    getContext().getContentResolver().delete(Uri.parse(mConfig.cameraPath), null, null);
                } else {
                    new PictureMediaScannerConnection(getContext(), mPhotoFile.getAbsolutePath());
                }
            }
        }
        mCameraView.setVisibility(View.VISIBLE);
    }

    /**
     * 开始循环播放视频
     *
     * @param videoFile
     */
    private void startVideoPlay(File videoFile) {
        try {
            if (mMediaPlayer == null) {
                mMediaPlayer = new MediaPlayer();
            }
            mMediaPlayer.setDataSource(videoFile.getAbsolutePath());
            mMediaPlayer.setSurface(new Surface(mTextureView.getSurfaceTexture()));
            mMediaPlayer.setLooping(true);
            mMediaPlayer.setOnPreparedListener(mp -> {
                mp.start();

                float ratio = mp.getVideoWidth() * 1f / mp.getVideoHeight();
                int width1 = mTextureView.getWidth();
                ViewGroup.LayoutParams layoutParams = mTextureView.getLayoutParams();
                layoutParams.height = (int) (width1 / ratio);
                mTextureView.setLayoutParams(layoutParams);
            });
            mMediaPlayer.prepareAsync();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 停止视频播放
     */
    private void stopVideoPlay() {
        if (mMediaPlayer != null) {
            mMediaPlayer.stop();
            mMediaPlayer.release();
            mMediaPlayer = null;
        }
        mTextureView.setVisibility(View.GONE);
    }

   @SuppressLint("RestrictedApi")
   public void onOestory(){
       if (mCameraView != null) {
           CameraX.unbindAll();
           mCameraView = null;
       }
    }

    /**
     * 权限被拒绝弹框
     * @param isCamera
     * @param errorMsg
     */
    public void showPermissionsDialog(boolean isCamera, String errorMsg) {

        final PictureCustomDialog dialog =
                new PictureCustomDialog(getContext(), R.layout.picture_wind_base_dialog);
        dialog.setCancelable(false);
        dialog.setCanceledOnTouchOutside(false);
        Button btn_cancel = dialog.findViewById(R.id.btn_cancel);
        Button btn_commit = dialog.findViewById(R.id.btn_commit);
        btn_commit.setText(getContext().getString(R.string.picture_go_setting));
        TextView tvTitle = dialog.findViewById(R.id.tvTitle);
        TextView tv_content = dialog.findViewById(R.id.tv_content);
        tvTitle.setText(getContext().getString(R.string.picture_prompt));
        tv_content.setText(errorMsg);
        btn_cancel.setOnClickListener(v -> {
            dialog.dismiss();
        });
        btn_commit.setOnClickListener(v -> {

            PermissionChecker.launchAppDetailsSettings(getContext());
        });
        dialog.show();
    }
}

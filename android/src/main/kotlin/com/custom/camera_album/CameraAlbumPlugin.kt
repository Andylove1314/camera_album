package com.custom.camera_album


import android.app.Activity
import android.content.Context
import android.content.pm.ActivityInfo
import android.graphics.Color
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import com.luck.picture.lib.PictureSelector
import com.luck.picture.lib.R
import com.luck.picture.lib.config.PictureConfig
import com.luck.picture.lib.config.PictureMimeType
import com.luck.picture.lib.entity.LocalMedia
import com.luck.picture.lib.language.LanguageConfig
import com.luck.picture.lib.listener.OnResultCallbackListener
import com.luck.picture.lib.style.PictureCropParameterStyle
import com.luck.picture.lib.style.PictureParameterStyle
import com.luck.picture.lib.tools.SdkVersionUtils
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


/** CameraAlbumPlugin */
public class CameraAlbumPlugin: FlutterPlugin, MethodCallHandler, ActivityAware{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private val methodOpenAlbum = "openAlbum"

  private var con: Activity? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter/camera_album")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter/camera_album")
      channel.setMethodCallHandler(CameraAlbumPlugin())
    }
  }

  /**主题*/
  private fun getWhiteStyle(): PictureParameterStyle?{
    // 相册主题
    var mPictureParameterStyle = PictureParameterStyle()
    // 是否改变状态栏字体颜色(黑白切换)
    mPictureParameterStyle.isChangeStatusBarFontColor = true
    // 是否开启右下角已完成(0/9)风格
    mPictureParameterStyle.isOpenCompletedNumStyle = false
    // 是否开启类似QQ相册带数字选择风格
    mPictureParameterStyle.isOpenCheckNumStyle = false
    // 相册状态栏背景色
    mPictureParameterStyle.pictureStatusBarColor = Color.parseColor("#FFFFFF")
    // 相册列表标题栏背景色
    mPictureParameterStyle.pictureTitleBarBackgroundColor = Color.parseColor("#FFFFFF")
    // 相册列表标题栏右侧上拉箭头
    mPictureParameterStyle.pictureTitleUpResId = R.drawable.ic_orange_arrow_up
    // 相册列表标题栏右侧下拉箭头
    mPictureParameterStyle.pictureTitleDownResId = R.drawable.ic_orange_arrow_down
    // 相册文件夹列表选中圆点
    mPictureParameterStyle.pictureFolderCheckedDotStyle = R.drawable.picture_orange_oval
    // 相册返回箭头
    mPictureParameterStyle.pictureLeftBackIcon = R.drawable.ic_back_arrow
    // 标题栏字体颜色
    mPictureParameterStyle.pictureTitleTextColor = ContextCompat.getColor(con as Context, R.color.picture_color_black)
    // 相册右侧取消按钮字体颜色  废弃 改用.pictureRightDefaultTextColor和.pictureRightDefaultTextColor
    mPictureParameterStyle.pictureCancelTextColor = ContextCompat.getColor(con as Context, R.color.picture_color_black)
    // 选择相册目录背景样式
    mPictureParameterStyle.pictureAlbumStyle = R.drawable.picture_new_item_select_bg
    // 相册列表勾选图片样式
    mPictureParameterStyle.pictureCheckedStyle = R.drawable.picture_checkbox_selector
    // 相册列表底部背景色
    mPictureParameterStyle.pictureBottomBgColor = ContextCompat.getColor(con as Context, R.color.picture_color_fa)
    // 已选数量圆点背景样式
    mPictureParameterStyle.pictureCheckNumBgStyle = R.drawable.picture_num_oval
    // 相册列表底下预览文字色值(预览按钮可点击时的色值)
    mPictureParameterStyle.picturePreviewTextColor = ContextCompat.getColor(con as Context, R.color.picture_color_fa632d)
    // 相册列表底下不可预览文字色值(预览按钮不可点击时的色值)
    mPictureParameterStyle.pictureUnPreviewTextColor = ContextCompat.getColor(con as Context, R.color.picture_color_9b)
    // 相册列表已完成色值(已完成 可点击色值)
    mPictureParameterStyle.pictureCompleteTextColor = ContextCompat.getColor(con as Context, R.color.picture_color_fa632d)
    // 相册列表未完成色值(请选择 不可点击色值)
    mPictureParameterStyle.pictureUnCompleteTextColor = ContextCompat.getColor(con as Context, R.color.picture_color_9b)
    // 预览界面底部背景色
    mPictureParameterStyle.picturePreviewBottomBgColor = ContextCompat.getColor(con as Context, R.color.picture_color_white)
    // 原图按钮勾选样式  需设置.isOriginalImageControl(true); 才有效
    mPictureParameterStyle.pictureOriginalControlStyle = R.drawable.picture_original_checkbox
    // 原图文字颜色 需设置.isOriginalImageControl(true); 才有效
    mPictureParameterStyle.pictureOriginalFontColor = ContextCompat.getColor(con as Context, R.color.app_color_53575e)
    // 外部预览界面删除按钮样式
    mPictureParameterStyle.pictureExternalPreviewDeleteStyle = R.drawable.picture_icon_black_delete
    // 外部预览界面是否显示删除按钮
    mPictureParameterStyle.pictureExternalPreviewGonePreviewDelete = true
     return mPictureParameterStyle
  }


  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${Build.VERSION.RELEASE}")
    } else  if (call.method == methodOpenAlbum) {

      // 进入相册 以下是例子：不需要的api可以不写
      PictureSelector.create(con)
              .openGallery(PictureMimeType.ofAll()) // 全部.PictureMimeType.ofAll()、图片.ofImage()、视频.ofVideo()、音频.ofAudio()
              .imageEngine(GlideEngine.createGlideEngine()) // 外部传入图片加载引擎，必传项
              .isWeChatStyle(false) // 是否开启微信图片选择风格
              .isUseCustomCamera(true) // 是否使用自定义相机
              .setLanguage(LanguageConfig.ENGLISH) // 设置语言，默认中文
              .isPageStrategy(true) // 是否开启分页策略 & 每页多少条；默认开启
              .setPictureStyle(getWhiteStyle()) // 动态自定义相册主题
//              .setPictureCropStyle(mCropParameterStyle) // 动态自定义裁剪主题
//              .setPictureWindowAnimationStyle(mWindowAnimationStyle) // 自定义相册启动退出动画
//              .setRecyclerAnimationMode(animationMode) // 列表动画效果
              .isWithVideoImage(true) // 图片和视频是否可以同选,只在ofAll模式下有效
              .isMaxSelectEnabledMask(true) // 选择数到了最大阀值列表是否启用蒙层效果
              //.isAutomaticTitleRecyclerTop(false)// 连续点击标题栏RecyclerView是否自动回到顶部,默认true
              //.loadCacheResourcesCallback(GlideCacheEngine.createCacheEngine())// 获取图片资源缓存，主要是解决华为10部分机型在拷贝文件过多时会出现卡的问题，这里可以判断只在会出现一直转圈问题机型上使用
              //.setOutputCameraPath()// 自定义相机输出目录，只针对Android Q以下，例如 Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM) +  File.separator + "Camera" + File.separator;
              //.setButtonFeatures(CustomCameraView.BUTTON_STATE_BOTH)// 设置自定义相机按钮状态
              .maxSelectNum(1) // 最大图片选择数量
              .minSelectNum(1) // 最小选择数量
              .maxVideoSelectNum(1) // 视频最大选择数量
              //.minVideoSelectNum(1)// 视频最小选择数量
              //.closeAndroidQChangeVideoWH(!SdkVersionUtils.checkedAndroid_Q())// 关闭在AndroidQ下获取图片或视频宽高相反自动转换
              .imageSpanCount(4) // 每行显示个数
              .isReturnEmpty(false) // 未选择数据时点击按钮是否可以返回
              .closeAndroidQChangeWH(true) //如果图片有旋转角度则对换宽高,默认为true
              .closeAndroidQChangeVideoWH(!SdkVersionUtils.checkedAndroid_Q()) // 如果视频有旋转角度则对换宽高,默认为false
              //.isAndroidQTransform(false)// 是否需要处理Android Q 拷贝至应用沙盒的操作，只针对compress(false); && .isEnableCrop(false);有效,默认处理
              .setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED) // 设置相册Activity方向，不设置默认使用系统
              .isOriginalImageControl(true) // 是否显示原图控制按钮，如果设置为true则用户可以自由选择是否使用原图，压缩、裁剪功能将会失效
              //.bindCustomPlayVideoCallback(new MyVideoSelectedPlayCallback(getContext()))// 自定义视频播放回调控制，用户可以使用自己的视频播放界面
              //.bindCustomPreviewCallback(new MyCustomPreviewInterfaceListener())// 自定义图片预览回调接口
              //.bindCustomCameraInterfaceListener(new MyCustomCameraInterfaceListener())// 提供给用户的一些额外的自定义操作回调
              //.cameraFileName(System.currentTimeMillis() +".jpg")    // 重命名拍照文件名、如果是相册拍照则内部会自动拼上当前时间戳防止重复，注意这个只在使用相机时可以使用，如果使用相机又开启了压缩或裁剪 需要配合压缩和裁剪文件名api
              //.renameCompressFile(System.currentTimeMillis() +".jpg")// 重命名压缩文件名、 如果是多张压缩则内部会自动拼上当前时间戳防止重复
              //.renameCropFileName(System.currentTimeMillis() + ".jpg")// 重命名裁剪文件名、 如果是多张裁剪则内部会自动拼上当前时间戳防止重复
              .selectionMode(if (false) PictureConfig.MULTIPLE else PictureConfig.SINGLE) // 多选 or 单选
              .isSingleDirectReturn(true) // 单选模式下是否直接返回，PictureConfig.SINGLE模式下有效
              .isPreviewImage(true) // 是否可预览图片
              .isPreviewVideo(true) // 是否可预览视频
              //.querySpecifiedFormatSuffix(PictureMimeType.ofJPEG())// 查询指定后缀格式资源
              .isEnablePreviewAudio(true) // 是否可播放音频
              .isCamera(true) // 是否显示拍照按钮
              //.isMultipleSkipCrop(false)// 多图裁剪时是否支持跳过，默认支持
              //.isMultipleRecyclerAnimation(false)// 多图裁剪底部列表显示动画效果
              .isZoomAnim(true) // 图片列表点击 缩放效果 默认true
              //.imageFormat(PictureMimeType.PNG)// 拍照保存图片格式后缀,默认jpeg,Android Q使用PictureMimeType.PNG_Q
              .isEnableCrop(false) // 是否裁剪
              //.basicUCropConfig()//对外提供所有UCropOptions参数配制，但如果PictureSelector原本支持设置的还是会使用原有的设置
              .isCompress(false) // 是否压缩
              //.compressQuality(80)// 图片压缩后输出质量 0~ 100
              .synOrAsy(true) //同步true或异步false 压缩 默认同步
              //.queryMaxFileSize(10)// 只查多少M以内的图片、视频、音频  单位M
              //.compressSavePath(getPath())//压缩图片保存地址
              //.sizeMultiplier(0.5f)// glide 加载图片大小 0~1之间 如设置 .glideOverride()无效 注：已废弃
              //.glideOverride(160, 160)// glide 加载宽高，越小图片列表越流畅，但会影响列表图片浏览的清晰度 注：已废弃
//              .withAspectRatio(aspect_ratio_x, aspect_ratio_y) // 裁剪比例 如16:9 3:2 3:4 1:1 可自定义
              .hideBottomControls(true) // 是否显示uCrop工具栏，默认不显示
              .isGif(true) // 是否显示gif图片
              .freeStyleCropEnabled(true) // 裁剪框是否可拖拽
              .circleDimmedLayer(false) // 是否圆形裁剪
              //.setCropDimmedColor(ContextCompat.getColor(con as Context, R.color.app_color_white))// 设置裁剪背景色值
              //.setCircleDimmedBorderColor(ContextCompat.getColor(getApplicationContext(), R.color.app_color_white))// 设置圆形裁剪边框色值
              //.setCircleStrokeWidth(3)// 设置圆形裁剪边框粗细
              .showCropFrame(false) // 是否显示裁剪矩形边框 圆形裁剪时建议设为false
              .showCropGrid(false) // 是否显示裁剪矩形网格 圆形裁剪时建议设为false
              .isOpenClickSound(true) // 是否开启点击声音
              .selectionData(null) // 是否传入已选图片
              //.isDragFrame(false)// 是否可拖动裁剪框(固定)
              //.videoMinSecond(10)// 查询多少秒以内的视频
              //.videoMaxSecond(15)// 查询多少秒以内的视频
              //.recordVideoSecond(10)//录制视频秒数 默认60s
              //.isPreviewEggs(true)// 预览图片时 是否增强左右滑动图片体验(图片滑动一半即可看到上一张是否选中)
              //.cropCompressQuality(90)// 注：已废弃 改用cutOutQuality()
              .cutOutQuality(90) // 裁剪输出质量 默认100
              .minimumCompressSize(100) // 小于多少kb的图片不压缩
              //.cropWH()// 裁剪宽高比，设置如果大于图片本身宽高则无效
              //.cropImageWideHigh()// 裁剪宽高比，设置如果大于图片本身宽高则无效
              //.rotateEnabled(false) // 裁剪是否可旋转图片
              //.scaleEnabled(false)// 裁剪是否可放大缩小图片
              //.videoQuality()// 视频录制质量 0 or 1
              //.forResult(PictureConfig.CHOOSE_REQUEST);//结果回调onActivityResult code
              .forResult(MyResultCallback(channel,result))
    } else if("configure" == call.method){
    }else {
      result.notImplemented()
    }
  }


  /**
   * 返回结果回调
   */
  private class MyResultCallback(channel: MethodChannel,result: Result) : OnResultCallbackListener<LocalMedia> {

    var cha: MethodChannel? = channel
    var res:Result? = result

    override fun onResult(result: List<LocalMedia>) {
      for (media in result) {
        Log.i("所选文件", "原图:" + media.path)
        cha?.invokeMethod("onMessage", media.androidQToPath)
        res?.success("选择了照片")
      }
    }

    override fun onCancel() {
    }

  }

  override fun onDetachedFromActivity() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    con = binding.activity

  }

  override fun onDetachedFromActivityForConfigChanges() {
  }


}

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
import java.util.*


/** CameraAlbumPlugin */
public class CameraAlbumPlugin: FlutterPlugin, MethodCallHandler, ActivityAware{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private val methodOpenAlbum = "openAlbum"

  private lateinit var con:Activity
  fun setActivity(context: Activity) {
    con = context
  }


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
      var plugin = CameraAlbumPlugin()
      plugin.channel = MethodChannel(registrar.messenger(), "flutter/camera_album")
      plugin.con = registrar.activity()
      //method chanel
      plugin.channel.setMethodCallHandler(plugin)

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

      Log.i(":flutter调用参数" ,"${call.arguments}")

      ///业务参数
      var actionId: String? = call?.argument<String>("actionId")
      var title: String? = call?.argument<String>("title")
      var inType: String? = call?.argument<String>("inType")
      var guides: List<List<String>>? = call?.argument<List<List<String>>>("guides")
      var isMulti: Boolean? = call?.argument<Boolean>("isMulti")
      var multiCount: Int = call?.argument<Int>("multiCount")?:5
      var firstCamera: Boolean? = call?.argument<Boolean>("firstCamera")
      var showBottomCamera: Boolean? = call?.argument<Boolean>("showBottomCamera")
      var showGridCamera: Boolean? = call?.argument<Boolean>("showGridCamera")
      var showAlbum: Boolean? = call?.argument<Boolean>("showAlbum")
      var cute: Boolean? = call?.argument<Boolean>("cute")


      ///文件类型
      var picType = if ("video" == inType) PictureMimeType.ofVideo() else PictureMimeType.ofImage()

      //相册
      var cameraOrAlbum = PictureSelector.create(con)
              .openGallery(picType)
      ///优先相机
      if (firstCamera == true){
        PictureSelector.create(con)
                .openCamera(picType)
      }
      cameraOrAlbum
              .imageEngine(GlideEngine.createGlideEngine()) // 外部传入图片加载引擎，必传项
              .loadCacheResourcesCallback(GlideCacheEngine.createCacheEngine())// 获取图片资源缓存，主要是解决华为10部分机型在拷贝文件过多时会出现卡的问题，这里可以判断只在会出现一直转圈问题机型上使用
              .isWeChatStyle(false) // 是否开启微信图片选择风格
              .isUseCustomCamera(false) // 是否使用自定义相机
              .setLanguage(LanguageConfig.ENGLISH) // 设置语言，默认中文
              .isPageStrategy(false) // 是否开启分页策略 & 每页多少条；默认开启
              .setPictureStyle(getWhiteStyle()) // 动态自定义相册主题
              .isMaxSelectEnabledMask(false) // 选择数到了最大阀值列表是否启用蒙层效果
              .maxSelectNum(multiCount) // 最大图片选择数量
              .minSelectNum(1) // 最小选择数量
              .maxVideoSelectNum(multiCount) // 视频最大选择数量
              .imageSpanCount(4) // 每行显示个数
              .isReturnEmpty(false) // 未选择数据时点击按钮是否可以返回
              .closeAndroidQChangeWH(true) //如果图片有旋转角度则对换宽高,默认为true
              .closeAndroidQChangeVideoWH(!SdkVersionUtils.checkedAndroid_Q()) // 如果视频有旋转角度则对换宽高,默认为false
              .setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED) // 设置相册Activity方向，不设置默认使用系统
              .isOriginalImageControl(true) // 是否显示原图控制按钮，如果设置为true则用户可以自由选择是否使用原图，压缩、裁剪功能将会失效
              .selectionMode(if (isMulti == true) PictureConfig.MULTIPLE else PictureConfig.SINGLE) // 多选 or 单选
              .isSingleDirectReturn(true) // 单选模式下是否直接返回，PictureConfig.SINGLE模式下有效
              .isPreviewImage(true) // 是否可预览图片
              .isPreviewVideo(true) // 是否可预览视频
              .isEnablePreviewAudio(false) // 是否可播放音频
              .isCamera(showGridCamera == true) // 是否显示拍照按钮
              .isEnableCrop(cute == true) // 是否裁剪
              .isCompress(false) // 是否压缩
              .synOrAsy(true) //同步true或异步false 压缩 默认同步
              .hideBottomControls(true) // 是否显示uCrop工具栏，默认不显示
              .isGif(true) // 是否显示gif图片
              .freeStyleCropEnabled(true) // 裁剪框是否可拖拽
              .circleDimmedLayer(false) // 是否圆形裁剪
              .showCropFrame(false) // 是否显示裁剪矩形边框 圆形裁剪时建议设为false
              .showCropGrid(false) // 是否显示裁剪矩形网格 圆形裁剪时建议设为false
              .isOpenClickSound(true) // 是否开启点击声音
              .selectionData(null) // 是否传入已选图片
              .cutOutQuality(90) // 裁剪输出质量 默认100
              .minimumCompressSize(100) // 小于多少kb的图片不压缩.setTask(title)
              ///业务相关
              .setActionId(actionId)
              .setPageTitle(title)
              .setGuidea(guides)
              .showBottomCamera(showBottomCamera == true)
              .showAlbum(showAlbum == true)
              .forResult(MyResultCallback(channel,result))
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
      val paths = ArrayList<Any?>()
      val durs = ArrayList<Any?>()
      for (media in result) {
        var path = if (SdkVersionUtils.checkedAndroid_Q()) media.androidQToPath else media.path
        Log.i("所选文件路径", "原图:$path")
        paths.add(path)
        var dur = media.duration
        Log.i("所选文件时长", "$dur")
        durs.add(dur)
      }
      var back = hashMapOf("paths" to paths, "durs" to durs)
      cha?.invokeMethod("onMessage", back)
      res?.success("你选择了文件")
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

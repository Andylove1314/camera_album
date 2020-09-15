package com.custom.camera_album;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Parcelable;
import android.os.SystemClock;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SimpleItemAnimator;

import com.luck.picture.lib.PictureMediaScannerConnection;
import com.luck.picture.lib.PictureSelectionModel;
import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.R;
import com.luck.picture.lib.adapter.PictureImageGridAdapter;
import com.luck.picture.lib.animators.AlphaInAnimationAdapter;
import com.luck.picture.lib.animators.AnimationType;
import com.luck.picture.lib.animators.SlideInBottomAnimationAdapter;
import com.luck.picture.lib.compress.Luban;
import com.luck.picture.lib.compress.OnCompressListener;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureMimeType;
import com.luck.picture.lib.config.PictureSelectionConfig;
import com.luck.picture.lib.decoration.GridSpacingItemDecoration;
import com.luck.picture.lib.dialog.PhotoItemSelectedDialog;
import com.luck.picture.lib.dialog.PictureCustomDialog;
import com.luck.picture.lib.dialog.PictureLoadingDialog;
import com.luck.picture.lib.entity.LocalMedia;
import com.luck.picture.lib.entity.LocalMediaFolder;
import com.luck.picture.lib.language.LanguageConfig;
import com.luck.picture.lib.listener.OnAlbumItemClickListener;
import com.luck.picture.lib.listener.OnItemClickListener;
import com.luck.picture.lib.listener.OnPhotoSelectChangedListener;
import com.luck.picture.lib.listener.OnQueryDataResultListener;
import com.luck.picture.lib.listener.OnRecyclerViewPreloadMoreListener;
import com.luck.picture.lib.listener.OnResultCallbackListener;
import com.luck.picture.lib.model.LocalMediaLoader;
import com.luck.picture.lib.model.LocalMediaPageLoader;
import com.luck.picture.lib.observable.ImagesObservable;
import com.luck.picture.lib.permissions.PermissionChecker;
import com.luck.picture.lib.style.PictureParameterStyle;
import com.luck.picture.lib.thread.PictureThreadUtils;
import com.luck.picture.lib.tools.AndroidQTransformUtils;
import com.luck.picture.lib.tools.AttrsUtils;
import com.luck.picture.lib.tools.BitmapUtils;
import com.luck.picture.lib.tools.DateUtils;
import com.luck.picture.lib.tools.DoubleUtils;
import com.luck.picture.lib.tools.JumpUtils;
import com.luck.picture.lib.tools.MediaUtils;
import com.luck.picture.lib.tools.PictureFileUtils;
import com.luck.picture.lib.tools.ScreenUtils;
import com.luck.picture.lib.tools.SdkVersionUtils;
import com.luck.picture.lib.tools.StringUtils;
import com.luck.picture.lib.tools.ToastUtils;
import com.luck.picture.lib.tools.ValueOf;
import com.luck.picture.lib.widget.RecyclerPreloadView;
import com.yalantis.ucrop.UCrop;
import com.yalantis.ucrop.model.CutInfo;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class FlutterAlbum extends LinearLayout implements View.OnClickListener, OnAlbumItemClickListener, OnPhotoSelectChangedListener<LocalMedia>, OnItemClickListener,
        OnRecyclerViewPreloadMoreListener {

    ///activity视图
    private boolean numComplete;
    private PictureLoadingDialog mLoadingDialog;
    private View container;
    private ImageView mIvArrow;
    private LinearLayout albumTitleLin;
    private TextView mTvPictureTitle, mTvPictureOk, mTvEmpty,
            mTvPictureImgNum, mTvPicturePreview;
    private RecyclerPreloadView mRecyclerView;
    private RelativeLayout mBottomLayout;
    private PictureImageGridAdapter mAdapter;
    private Animation animation = null;
    private boolean isStartAnimation = false;
    private CheckBox mCbOriginal;
    private int oldCurrentListSize;
    private long intervalClickTime = 0;
    private int mOpenCameraCount;
    //page
    private int mPage = 1;
    //if there more
    private boolean isHasMore = true;

    protected boolean isEnterSetting;

    private int allFolderSize;

    private  Context context;
    /**相册控件*/
    private AlbumView albumView;
    /**通讯专用*/
    private MethodChannel channel;
    private Map<String, Object> data;

    /**相册配置*/
    static public PictureSelectionConfig config;

    private final static String TAG = "FlutterAlbum";

    public FlutterAlbum(Context con,MethodChannel chann, Object param) {
        super(con);
        channel = chann;
        data = (Map<String, Object>) param;
        context = con;
        LayoutInflater.from(context).inflate(R.layout.picture_flutter_album, this);
        ///初始化数据
        initConfig();
        initWidgets();
        initPictureSelectorStyle();
    }

    /**主题*/
    private PictureParameterStyle getWhiteStyle(){
        // 相册主题
        PictureParameterStyle mPictureParameterStyle = new PictureParameterStyle();
        // 是否改变状态栏字体颜色(黑白切换)
        mPictureParameterStyle.isChangeStatusBarFontColor = true;
        // 是否开启右下角已完成(0/9)风格
        mPictureParameterStyle.isOpenCompletedNumStyle = false;
        // 是否开启类似QQ相册带数字选择风格
        mPictureParameterStyle.isOpenCheckNumStyle = false;
        // 相册状态栏背景色
        mPictureParameterStyle.pictureStatusBarColor = Color.parseColor("#FFFFFF");
        // 相册列表标题栏背景色
        mPictureParameterStyle.pictureTitleBarBackgroundColor = Color.parseColor("#FFFFFF");
        // 相册列表标题栏右侧上拉箭头
        mPictureParameterStyle.pictureTitleUpResId = R.drawable.ic_orange_arrow_up;
        // 相册列表标题栏右侧下拉箭头
        mPictureParameterStyle.pictureTitleDownResId = R.drawable.ic_orange_arrow_down;
        // 相册文件夹列表选中圆点
        mPictureParameterStyle.pictureFolderCheckedDotStyle = R.drawable.picture_orange_oval;
        // 相册返回箭头
        mPictureParameterStyle.pictureLeftBackIcon = R.drawable.ic_back_arrow;
        // 标题栏字体颜色
        mPictureParameterStyle.pictureTitleTextColor = ContextCompat.getColor(context, R.color.picture_color_black);
        // 相册右侧取消按钮字体颜色  废弃 改用.pictureRightDefaultTextColor和.pictureRightDefaultTextColor
        mPictureParameterStyle.pictureCancelTextColor = ContextCompat.getColor(context, R.color.picture_color_black);
        // 选择相册目录背景样式
        mPictureParameterStyle.pictureAlbumStyle = R.drawable.picture_new_item_select_bg;
        // 相册列表勾选图片样式
        mPictureParameterStyle.pictureCheckedStyle = R.drawable.picture_checkbox_selector;
        // 相册列表底部背景色
        mPictureParameterStyle.pictureBottomBgColor = ContextCompat.getColor(context, R.color.picture_color_fa);
        // 已选数量圆点背景样式
        mPictureParameterStyle.pictureCheckNumBgStyle = R.drawable.picture_num_oval;
        // 相册列表底下预览文字色值(预览按钮可点击时的色值)
        mPictureParameterStyle.picturePreviewTextColor = ContextCompat.getColor(context, R.color.picture_color_fa632d);
        // 相册列表底下不可预览文字色值(预览按钮不可点击时的色值)
        mPictureParameterStyle.pictureUnPreviewTextColor = ContextCompat.getColor(context, R.color.picture_color_9b);
        // 相册列表已完成色值(已完成 可点击色值)
        mPictureParameterStyle.pictureCompleteTextColor = ContextCompat.getColor(context, R.color.picture_color_fa632d);
        // 相册列表未完成色值(请选择 不可点击色值)
        mPictureParameterStyle.pictureUnCompleteTextColor = ContextCompat.getColor(context, R.color.picture_color_9b);
        // 预览界面底部背景色
        mPictureParameterStyle.picturePreviewBottomBgColor = ContextCompat.getColor(context, R.color.picture_color_white);
        // 原图按钮勾选样式  需设置.isOriginalImageControl(true); 才有效
        mPictureParameterStyle.pictureOriginalControlStyle = R.drawable.picture_original_checkbox;
        // 原图文字颜色 需设置.isOriginalImageControl(true); 才有效
        mPictureParameterStyle.pictureOriginalFontColor = ContextCompat.getColor(context, R.color.app_color_53575e);
        // 外部预览界面删除按钮样式
        mPictureParameterStyle.pictureExternalPreviewDeleteStyle = R.drawable.picture_icon_black_delete;
        // 外部预览界面是否显示删除按钮
        mPictureParameterStyle.pictureExternalPreviewGonePreviewDelete = true;
        return mPictureParameterStyle;
    }
    /**设置*/
    private void initConfig() {

        PictureSelectionModel cameraOrAlbum =  new PictureSelectionModel(PictureSelector.create((Activity) context), ("video".equals(data.get("inType")))?PictureMimeType.ofVideo():PictureMimeType.ofImage());

        cameraOrAlbum
                .imageEngine(GlideEngine.createGlideEngine()) // 外部传入图片加载引擎，必传项
                .isWeChatStyle(false) // 是否开启微信图片选择风格
                .isUseCustomCamera((Boolean) data.get("customCamera")) // 是否使用自定义相机
//                .setLanguage(LanguageConfig.ENGLISH) // 设置语言，默认英文
                .isPageStrategy(false) // 是否开启分页策略 & 每页多少条；默认开启
                .setPictureStyle(getWhiteStyle()) // 动态自定义相册主题
                .isMaxSelectEnabledMask(true) // 选择数到了最大阀值列表是否启用蒙层效果
                .maxSelectNum((Integer) data.get("multiCount")) // 最大图片选择数量
                .minSelectNum(1) // 最小选择数量
                .maxVideoSelectNum((Integer) data.get("multiCount")) // 视频最大选择数量
                .imageSpanCount(4) // 每行显示个数
                .isReturnEmpty(false) // 未选择数据时点击按钮是否可以返回
                .closeAndroidQChangeWH(true) //如果图片有旋转角度则对换宽高,默认为true
                .closeAndroidQChangeVideoWH(!SdkVersionUtils.checkedAndroid_Q()) // 如果视频有旋转角度则对换宽高,默认为false
                .setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED) // 设置相册Activity方向，不设置默认使用系统
                .isOriginalImageControl(true) // 是否显示原图控制按钮，如果设置为true则用户可以自由选择是否使用原图，压缩、裁剪功能将会失效
                .selectionMode((boolean)data.get("isMulti")?PictureConfig.MULTIPLE:PictureConfig.SINGLE) // 多选 or 单选
              .isSingleDirectReturn(!(boolean)data.get("isMulti")) // 单选模式下是否直接返回，PictureConfig.SINGLE模式下有效
                .isPreviewImage(!(boolean)data.get("isMulti")) // 是否可预览图片
                .isPreviewVideo(!(boolean)data.get("isMulti")) // 是否可预览视频
                .isEnablePreviewAudio(false) // 是否可播放音频
                .isCamera((Boolean) data.get("showGridCamera")) // 是否显示拍照按钮
                .isEnableCrop((Boolean) data.get("cute")) // 是否裁剪
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
                .minimumCompressSize(100);// 小于多少kb的图片不压缩.setTask(title)

        config = cameraOrAlbum.selectionConfig;

        config.listener = new WeakReference<>(new OnResultCallbackListener<LocalMedia>() {

            @Override
            public void onResult(List<LocalMedia> result) {
                _backSrcToFlutter(result);
            }

            @Override
            public void onCancel() {

            }
        }).get();
        config.isCallbackMode = true;
    }

    /**
     * 吐数据给flutter
     * * @param result
     */
    private void _backSrcToFlutter(List<LocalMedia> result){
        Log.d(TAG, "onResult: "+result.get(0).toString());
        List paths = new ArrayList<String>();
        List durs = new ArrayList<Long>();
        for (LocalMedia media: result) {
            String path = (SdkVersionUtils.checkedAndroid_Q())? media.getAndroidQToPath() :media.getPath();
            Log.i("所选文件路径", "原图:"+path);
            paths.add(path);
            long dur = media.getDuration()/1000;
            Log.i("所选文件时长", ""+dur);
            durs.add(dur);
        }
        Map back = new HashMap<String, List<Object>>();
        back.put("paths",paths);
        back.put("durs",durs);
        channel.invokeMethod("onMessage", back);
    }

    /**
     * 初始化view
     */
    protected void initWidgets() {
        context.setTheme(config.themeStyleId == 0 ? R.style.picture_default_style : config.themeStyleId);
        container = findViewById(R.id.container);
        mTvPictureTitle = findViewById(R.id.picture_title);
        mTvPictureOk = findViewById(R.id.picture_tv_ok);
        mCbOriginal = findViewById(R.id.cb_original);
        mIvArrow = findViewById(R.id.ivArrow);
        mTvPicturePreview = findViewById(R.id.picture_id_preview);
        mTvPictureImgNum = findViewById(R.id.picture_tvMediaNum);
        mRecyclerView = findViewById(R.id.picture_recycler);
        mBottomLayout = findViewById(R.id.rl_bottom);
        mTvEmpty = findViewById(R.id.tv_empty);
        isNumComplete(numComplete);
        if (!numComplete) {
            animation = AnimationUtils.loadAnimation(context, R.anim.picture_anim_modal_in);
        }
        mTvPicturePreview.setOnClickListener(this);
        mTvPicturePreview.setVisibility(config.chooseMode != PictureMimeType.ofAudio() && config.enablePreview ? View.VISIBLE : View.GONE);
        mBottomLayout.setVisibility((config.selectionMode == PictureConfig.SINGLE
                && config.isSingleDirectReturn)? View.GONE : View.VISIBLE);
        mTvPictureOk.setOnClickListener(this);
        mTvPictureImgNum.setOnClickListener(this);
        String title = config.chooseMode == PictureMimeType.ofAudio() ?
                context.getString(R.string.picture_all_audio) : context.getString(R.string.picture_camera_roll);
        mTvPictureTitle.setText(title);
        mTvPictureTitle.setTag(R.id.view_tag, -1);
        mRecyclerView.addItemDecoration(new GridSpacingItemDecoration(config.imageSpanCount,
                ScreenUtils.dip2px(context, 2), false));
        mRecyclerView.setLayoutManager(new GridLayoutManager(context, config.imageSpanCount));
        if (!config.isPageStrategy) {
            mRecyclerView.setHasFixedSize(true);
        } else {
            mRecyclerView.setReachBottomRow(RecyclerPreloadView.BOTTOM_PRELOAD);
            mRecyclerView.setOnRecyclerViewPreloadListener(this);
        }
        RecyclerView.ItemAnimator itemAnimator = mRecyclerView.getItemAnimator();
        if (itemAnimator != null) {
            ((SimpleItemAnimator) itemAnimator).setSupportsChangeAnimations(false);
            mRecyclerView.setItemAnimator(null);
        }
        loadAllMediaData();
        mTvEmpty.setText(config.chooseMode == PictureMimeType.ofAudio() ?
                context.getString(R.string.picture_audio_empty)
                : context.getString(R.string.picture_empty));
        StringUtils.tempTextFont(mTvEmpty, config.chooseMode);
        mAdapter = new PictureImageGridAdapter(context, config);
        mAdapter.setOnPhotoSelectChangedListener(this);
        mAdapter.setChannel(channel);

        switch (config.animationMode) {
            case AnimationType
                    .ALPHA_IN_ANIMATION:
                mRecyclerView.setAdapter(new AlphaInAnimationAdapter(mAdapter));
                break;
            case AnimationType
                    .SLIDE_IN_BOTTOM_ANIMATION:
                mRecyclerView.setAdapter(new SlideInBottomAnimationAdapter(mAdapter));
                break;
            default:
                mRecyclerView.setAdapter(mAdapter);
                break;
        }
        if (config.isOriginalControl) {
            mCbOriginal.setVisibility(View.VISIBLE);
            mCbOriginal.setChecked(config.isCheckOriginalImage);
            mCbOriginal.setOnCheckedChangeListener((buttonView, isChecked) -> {
                config.isCheckOriginalImage = isChecked;
            });
        }
        albumTitleLin = findViewById(R.id.album_title_button_lin);
        albumTitleLin.setOnClickListener(this);

        albumView = findViewById(R.id.album_view);
        albumView.setConfig(config,this, mIvArrow);

        int size = albumView.getFolderData().size();
        if (size > 0) {
            allFolderSize = albumView.getFolder(0).getImageNum();
        }

    }


    public void initPictureSelectorStyle() {
        if (config.style != null) {
            if (config.style.pictureTitleDownResId != 0) {
                Drawable drawable = ContextCompat.getDrawable(context, config.style.pictureTitleDownResId);
                mIvArrow.setImageDrawable(drawable);
            }
            if (config.style.pictureTitleTextColor != 0) {
                mTvPictureTitle.setTextColor(config.style.pictureTitleTextColor);
            }
            if (config.style.pictureTitleTextSize != 0) {
                mTvPictureTitle.setTextSize(config.style.pictureTitleTextSize);
            }

            if (config.style.pictureUnPreviewTextColor != 0) {
                mTvPicturePreview.setTextColor(config.style.pictureUnPreviewTextColor);
            }
            if (config.style.picturePreviewTextSize != 0) {
                mTvPicturePreview.setTextSize(config.style.picturePreviewTextSize);
            }
            if (config.style.pictureCheckNumBgStyle != 0) {
                mTvPictureImgNum.setBackgroundResource(config.style.pictureCheckNumBgStyle);
            }
            if (config.style.pictureUnCompleteTextColor != 0) {
                mTvPictureOk.setTextColor(config.style.pictureUnCompleteTextColor);
            }
            if (config.style.pictureCompleteTextSize != 0) {
                mTvPictureOk.setTextSize(config.style.pictureCompleteTextSize);
            }
            if (config.style.pictureBottomBgColor != 0) {
                mBottomLayout.setBackgroundColor(config.style.pictureBottomBgColor);
            }
            if (config.style.pictureContainerBackgroundColor != 0) {
                container.setBackgroundColor(config.style.pictureContainerBackgroundColor);
            }
            if (!TextUtils.isEmpty(config.style.pictureUnCompleteText)) {
                mTvPictureOk.setText(config.style.pictureUnCompleteText);
            }
            if (!TextUtils.isEmpty(config.style.pictureUnPreviewText)) {
                mTvPicturePreview.setText(config.style.pictureUnPreviewText);
            }
        } else {
            if (config.downResId != 0) {
                Drawable drawable = ContextCompat.getDrawable(context, config.downResId);
                mIvArrow.setImageDrawable(drawable);
            }
            int pictureBottomBgColor = AttrsUtils.
                    getTypeValueColor(getContext(), R.attr.picture_bottom_bg);
            if (pictureBottomBgColor != 0) {
                mBottomLayout.setBackgroundColor(pictureBottomBgColor);
            }
        }


        if (config.isOriginalControl) {
            if (config.style != null) {
                if (config.style.pictureOriginalControlStyle != 0) {
                    mCbOriginal.setButtonDrawable(config.style.pictureOriginalControlStyle);
                } else {
                    mCbOriginal.setButtonDrawable(ContextCompat.getDrawable(context, R.drawable.picture_original_checkbox));
                }
                if (config.style.pictureOriginalFontColor != 0) {
                    mCbOriginal.setTextColor(config.style.pictureOriginalFontColor);
                } else {
                    mCbOriginal.setTextColor(ContextCompat.getColor(context, R.color.picture_color_53575e));
                }
                if (config.style.pictureOriginalTextSize != 0) {
                    mCbOriginal.setTextSize(config.style.pictureOriginalTextSize);
                }
            } else {
                mCbOriginal.setButtonDrawable(ContextCompat.getDrawable(context, R.drawable.picture_original_checkbox));
                mCbOriginal.setTextColor(ContextCompat.getColor(context, R.color.picture_color_53575e));
            }
        }

    }
    /**
     * none number style
     */
    private void isNumComplete(boolean numComplete) {
        if (numComplete) {
            initCompleteText(0);
        }
    }

    /**
     * loading dialog
     */
    protected void showPleaseDialog() {
        try {
            if (mLoadingDialog == null) {
                mLoadingDialog = new PictureLoadingDialog(context);
            }
            if (mLoadingDialog.isShowing()) {
                mLoadingDialog.dismiss();
            }
            mLoadingDialog.show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    protected void showPermissionsDialog(boolean isCamera, String errorMsg) {

        final PictureCustomDialog dialog =
                new PictureCustomDialog(getContext(), R.layout.picture_wind_base_dialog);
        dialog.setCancelable(false);
        dialog.setCanceledOnTouchOutside(false);
        Button btn_cancel = dialog.findViewById(R.id.btn_cancel);
        Button btn_commit = dialog.findViewById(R.id.btn_commit);
        btn_commit.setText(context.getString(R.string.picture_go_setting));
        TextView tvTitle = dialog.findViewById(R.id.tvTitle);
        TextView tv_content = dialog.findViewById(R.id.tv_content);
        tvTitle.setText(context.getString(R.string.picture_prompt));
        tv_content.setText(errorMsg);
        btn_cancel.setOnClickListener(v -> {
            dialog.dismiss();
        });
        btn_commit.setOnClickListener(v -> {
            dialog.dismiss();
            PermissionChecker.launchAppDetailsSettings(getContext());
            isEnterSetting = true;
        });
        dialog.show();
    }

    /**
     * onResume 回调
     */
    protected void onPermissionResume(){
        if (isEnterSetting) {
            if (PermissionChecker
                    .checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE) &&
                    PermissionChecker
                            .checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                if (mAdapter.isDataEmpty()) {
                    readLocalMedia();
                }
            } else {
                showPermissionsDialog(false, context.getString(R.string.picture_jurisdiction));
            }
            isEnterSetting = false;
        }
    }


    /**
     * get LocalMedia s
     */
    protected void readLocalMedia() {
        showPleaseDialog();
        if (config.isPageStrategy) {
            LocalMediaPageLoader.getInstance(getContext(), config).loadAllMedia(
                    (OnQueryDataResultListener<LocalMediaFolder>) (data, currentPage, isHasMore) -> {
                        this.isHasMore = true;
                        initPageModel(data);
                        synchronousCover();
                    });
        } else {
            PictureThreadUtils.executeByIo(new PictureThreadUtils.SimpleTask<List<LocalMediaFolder>>() {

                @Override
                public List<LocalMediaFolder> doInBackground() {
                    return new LocalMediaLoader(getContext(), config).loadAllMedia();
                }

                @Override
                public void onSuccess(List<LocalMediaFolder> folders) {
                    initStandardModel(folders);
                }
            });
        }
    }


    /**
     * ofAll Page Model Synchronous cover
     */
    private void synchronousCover() {
        if (config.chooseMode == PictureMimeType.ofAll()) {
            PictureThreadUtils.executeByIo(new PictureThreadUtils.SimpleTask<Boolean>() {

                @Override
                public Boolean doInBackground() {
                    int size = albumView.getFolderData().size();
                    for (int i = 0; i < size; i++) {
                        LocalMediaFolder mediaFolder = albumView.getFolder(i);
                        if (mediaFolder == null) {
                            continue;
                        }
                        String firstCover = LocalMediaPageLoader
                                .getInstance(getContext(), config).getFirstCover(mediaFolder.getBucketId());
                        mediaFolder.setFirstImagePath(firstCover);
                    }
                    return true;
                }

                @Override
                public void onSuccess(Boolean result) {
                    // TODO Synchronous Success
                }
            });
        }
    }

    /**
     * Page Model
     *
     * @param folders
     */
    private void initPageModel(List<LocalMediaFolder> folders) {
        if (folders != null) {
            albumView.bindFolder(folders);
            mPage = 1;
            LocalMediaFolder folder = albumView.getFolder(0);
            mTvPictureTitle.setTag(R.id.view_count_tag, folder != null ? folder.getImageNum() : 0);
            mTvPictureTitle.setTag(R.id.view_index_tag, 0);
            long bucketId = folder != null ? folder.getBucketId() : -1;
            mRecyclerView.setEnabledLoadMore(true);
            LocalMediaPageLoader.getInstance(getContext(), config).loadPageMediaData(bucketId, mPage,
                    (OnQueryDataResultListener<LocalMedia>) (data, currentPage, isHasMore) -> {

                        dismissDialog();
                        if (mAdapter != null) {
                            this.isHasMore = true;
                            // IsHasMore being true means that there's still data, but data being 0 might be a filter that's turned on and that doesn't happen to fit on the whole page
                            if (isHasMore && data.size() == 0) {
                                onRecyclerViewPreloadMore();
                                return;
                            }
                            int currentSize = mAdapter.getSize();
                            int resultSize = data.size();
                            oldCurrentListSize = oldCurrentListSize + currentSize;
                            if (resultSize >= currentSize) {
                                // This situation is mainly caused by the use of camera memory, the Activity is recycled
                                if (currentSize > 0 && currentSize < resultSize && oldCurrentListSize != resultSize) {
                                    if (isLocalMediaSame(data.get(0))) {
                                        mAdapter.bindData(data);
                                    } else {
                                        mAdapter.getData().addAll(data);
                                    }
                                } else {
                                    mAdapter.bindData(data);
                                }
                            }
                            boolean isEmpty = mAdapter.isDataEmpty();
                            if (isEmpty) {
                                showDataNull(context.getString(R.string.picture_empty), R.drawable.picture_icon_no_data);
                            } else {
                                hideDataNull();
                            }

                        }
                    });
        } else {
            showDataNull(context.getString(R.string.picture_data_exception), R.drawable.picture_icon_data_error);
            dismissDialog();
        }
    }

    /**
     * isSame
     *
     * @param newMedia
     * @return
     */
    private boolean isLocalMediaSame(LocalMedia newMedia) {
        LocalMedia oldMedia = mAdapter.getItem(0);
        if (oldMedia == null || newMedia == null) {
            return false;
        }
        if (oldMedia.getPath().equals(newMedia.getPath())) {
            return true;
        }
        // if Content:// type,determines whether the suffix id is consistent, mainly to solve the following two types of problems
        // content://media/external/images/media/5844
        // content://media/external/file/5844
        if (PictureMimeType.isContent(newMedia.getPath())
                && PictureMimeType.isContent(oldMedia.getPath())) {
            if (!TextUtils.isEmpty(newMedia.getPath()) && !TextUtils.isEmpty(oldMedia.getPath())) {
                String newId = newMedia.getPath().substring(newMedia.getPath().lastIndexOf("/") + 1);
                String oldId = oldMedia.getPath().substring(oldMedia.getPath().lastIndexOf("/") + 1);
                if (newId.equals(oldId)) {
                    return true;
                }
            }
        }
        return false;
    }
    /**
     * Standard Model
     *
     * @param folders
     */
    private void initStandardModel(List<LocalMediaFolder> folders) {
        if (folders != null) {
            if (folders.size() > 0) {
                albumView.bindFolder(folders);
                LocalMediaFolder folder = folders.get(0);
                folder.setChecked(true);
                mTvPictureTitle.setTag(R.id.view_count_tag, folder.getImageNum());
                List<LocalMedia> result = folder.getData();
                if (mAdapter != null) {
                    int currentSize = mAdapter.getSize();
                    int resultSize = result.size();
                    oldCurrentListSize = oldCurrentListSize + currentSize;
                    if (resultSize >= currentSize) {
                        // This situation is mainly caused by the use of camera memory, the Activity is recycled
                        if (currentSize > 0 && currentSize < resultSize && oldCurrentListSize != resultSize) {
                            mAdapter.getData().addAll(result);
                            LocalMedia media = mAdapter.getData().get(0);
                            folder.setFirstImagePath(media.getPath());
                            folder.getData().add(0, media);
                            folder.setCheckedNum(1);
                            folder.setImageNum(folder.getImageNum() + 1);
                            updateMediaFolder(albumView.getFolderData(), media);
                        } else {
                            mAdapter.bindData(result);
                        }
                    }
                    boolean isEmpty = mAdapter.isDataEmpty();
                    if (isEmpty) {
                        showDataNull(context.getString(R.string.picture_empty), R.drawable.picture_icon_no_data);
                    } else {
                        hideDataNull();
                    }
                }
            } else {
                showDataNull(context.getString(R.string.picture_empty), R.drawable.picture_icon_no_data);
            }
        } else {
            showDataNull(context.getString(R.string.picture_data_exception), R.drawable.picture_icon_data_error);
        }
        dismissDialog();
    }


    /**
     * set Data Null
     *
     * @param msg
     */
    private void showDataNull(String msg, int topErrorResId) {
        if (mTvEmpty.getVisibility() == View.GONE || mTvEmpty.getVisibility() == View.INVISIBLE) {
            mTvEmpty.setCompoundDrawablesRelativeWithIntrinsicBounds(0, topErrorResId, 0, 0);
            mTvEmpty.setText(msg);
            mTvEmpty.setVisibility(View.VISIBLE);
        }
    }

    /**
     * hidden
     */
    private void hideDataNull() {
        if (mTvEmpty.getVisibility() == View.VISIBLE) {
            mTvEmpty.setVisibility(View.GONE);
        }
    }

    /**
     * Update Folder
     *
     * @param imageFolders
     */
    private void updateMediaFolder(List<LocalMediaFolder> imageFolders, LocalMedia media) {
        File imageFile = new File(media.getRealPath());
        File folderFile = imageFile.getParentFile();
        if (folderFile == null) {
            return;
        }
        int size = imageFolders.size();
        for (int i = 0; i < size; i++) {
            LocalMediaFolder folder = imageFolders.get(i);
            String name = folder.getName();
            if (TextUtils.isEmpty(name)) {
                continue;
            }
            if (name.equals(folderFile.getName())) {
                folder.setFirstImagePath(config.cameraPath);
                folder.setImageNum(folder.getImageNum() + 1);
                folder.setCheckedNum(1);
                folder.getData().add(0, media);
                break;
            }
        }
    }

    /**
     * load All Data
     */
    private void loadAllMediaData() {
        if (PermissionChecker
                .checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE) &&
                PermissionChecker
                        .checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
            readLocalMedia();
        } else {
            PermissionChecker.requestPermissions((Activity) context, new String[]{
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE}, PictureConfig.APPLY_STORAGE_PERMISSIONS_CODE);
        }
    }
    /**
     * init Text
     */
    protected void initCompleteText(int startCount) {
        boolean isNotEmptyStyle = config.style != null;
        if (config.selectionMode == PictureConfig.SINGLE) {
            if (startCount <= 0) {
                mTvPictureOk.setText(isNotEmptyStyle && !TextUtils.isEmpty(config.style.pictureUnCompleteText)
                        ? config.style.pictureUnCompleteText : context.getString(R.string.picture_please_select));
            } else {
                boolean isCompleteReplaceNum = isNotEmptyStyle && config.style.isCompleteReplaceNum;
                if (isCompleteReplaceNum && !TextUtils.isEmpty(config.style.pictureCompleteText)) {
                    mTvPictureOk.setText(String.format(config.style.pictureCompleteText, startCount, 1));
                } else {
                    mTvPictureOk.setText(isNotEmptyStyle && !TextUtils.isEmpty(config.style.pictureCompleteText)
                            ? config.style.pictureCompleteText :(context.getString(R.string.picture_done)));
                }
            }

        } else {
            boolean isCompleteReplaceNum = isNotEmptyStyle && config.style.isCompleteReplaceNum;
            if (startCount <= 0) {
                mTvPictureOk.setText(isNotEmptyStyle && !TextUtils.isEmpty(config.style.pictureUnCompleteText)
                        ? config.style.pictureUnCompleteText : (context.getString(R.string.picture_done_front_num,
                        startCount, config.maxSelectNum)));
            } else {
                if (isCompleteReplaceNum && !TextUtils.isEmpty(config.style.pictureCompleteText)) {
                    mTvPictureOk.setText(String.format(config.style.pictureCompleteText, startCount, config.maxSelectNum));
                } else {
                    mTvPictureOk.setText(context.getString(R.string.picture_done_front_num,
                            startCount, config.maxSelectNum));
                }
            }
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.pictureLeftBack) {
            if (albumView != null) {
                albumView.dismiss();
            } else {
                if (config != null && PictureSelectionConfig.listener != null) {
                    PictureSelectionConfig.listener.onCancel();
                }
            }
            return;
        }
        if (id == R.id.album_title_button_lin) {
            if (albumView.isShowing()) {
                albumView.dismiss();
            } else {
                if (!albumView.isEmpty()) {
                    albumView.showAsDropDown();
                    if (!config.isSingleDirectReturn) {
                        List<LocalMedia> selectedImages = mAdapter.getSelectedData();
                        albumView.updateFolderCheckStatus(selectedImages);
                    }
                }
            }
            return;
        }

        if (id == R.id.picture_id_preview) {
            onPreview();
            return;
        }

        if (id == R.id.picture_tv_ok || id == R.id.picture_tvMediaNum) {
            onComplete();
            return;
        }

        if (id == R.id.titleViewBg) {
            if (config.isAutomaticTitleRecyclerTop) {
                int intervalTime = 500;
                if (SystemClock.uptimeMillis() - intervalClickTime < intervalTime) {
                    if (mAdapter.getItemCount() > 0) {
                        mRecyclerView.scrollToPosition(0);
                    }
                } else {
                    intervalClickTime = SystemClock.uptimeMillis();
                }
            }
        }
    }
    /**
     * Complete
     */
    @SuppressLint("StringFormatMatches")
    private void onComplete() {
        Log.i("dddddddd","yes");
        List<LocalMedia> result = mAdapter.getSelectedData();
        int size = result.size();
        LocalMedia image = result.size() > 0 ? result.get(0) : null;
        String mimeType = image != null ? image.getMimeType() : "";
        boolean isHasImage = PictureMimeType.isHasImage(mimeType);
        if (config.isWithVideoImage) {
            int videoSize = 0;
            int imageSize = 0;
            for (int i = 0; i < size; i++) {
                LocalMedia media = result.get(i);
                if (PictureMimeType.isHasVideo(media.getMimeType())) {
                    videoSize++;
                } else {
                    imageSize++;
                }
            }
            if (config.selectionMode == PictureConfig.MULTIPLE) {
                if (config.minSelectNum > 0) {
                    if (imageSize < config.minSelectNum) {
                        showPromptDialog(context.getString(R.string.picture_min_img_num, config.minSelectNum));
                        return;
                    }
                }
                if (config.minVideoSelectNum > 0) {
                    if (videoSize < config.minVideoSelectNum) {
                        showPromptDialog(context.getString(R.string.picture_min_video_num, config.minVideoSelectNum));
                        return;
                    }
                }
            }
        } else {
            if (config.selectionMode == PictureConfig.MULTIPLE) {
                if (PictureMimeType.isHasImage(mimeType) && config.minSelectNum > 0 && size < config.minSelectNum) {
                    String str = context.getString(R.string.picture_min_img_num, config.minSelectNum);
                    showPromptDialog(str);
                    return;
                }
                if (PictureMimeType.isHasVideo(mimeType) && config.minVideoSelectNum > 0 && size < config.minVideoSelectNum) {
                    @SuppressLint("StringFormatMatches") String str = context.getString(R.string.picture_min_video_num, config.minVideoSelectNum);
                    showPromptDialog(str);
                    return;
                }
            }
        }

        if (config.returnEmpty && size == 0) {
            if (config.selectionMode == PictureConfig.MULTIPLE) {
                if (config.minSelectNum > 0 && size < config.minSelectNum) {
                    @SuppressLint("StringFormatMatches") String str = context.getString(R.string.picture_min_img_num, config.minSelectNum);
                    showPromptDialog(str);
                    return;
                }
                if (config.minVideoSelectNum > 0 && size < config.minVideoSelectNum) {
                    @SuppressLint("StringFormatMatches") String str = context.getString(R.string.picture_min_video_num, config.minVideoSelectNum);
                    showPromptDialog(str);
                    return;
                }
            }
            if (PictureSelectionConfig.listener != null) {
                PictureSelectionConfig.listener.onResult(result);

            }
            return;
        }
        if (config.isCheckOriginalImage) {
            onResult(result);
            return;
        }
        if (config.chooseMode == PictureMimeType.ofAll() && config.isWithVideoImage) {
            bothMimeTypeWith(isHasImage, result);
        } else {
            separateMimeTypeWith(isHasImage, result);
        }
    }


    /**
     * They are different types of processing
     *
     * @param isHasImage
     * @param images
     */
    private void bothMimeTypeWith(boolean isHasImage, List<LocalMedia> images) {
        LocalMedia image = images.size() > 0 ? images.get(0) : null;
        if (image == null) {
            return;
        }
        if (config.enableCrop) {
            if (config.selectionMode == PictureConfig.SINGLE && isHasImage) {
                config.originalPath = image.getPath();
                startCrop(config.originalPath, image.getMimeType());
            } else {
                ArrayList<CutInfo> cuts = new ArrayList<>();
                int count = images.size();
                int imageNum = 0;
                for (int i = 0; i < count; i++) {
                    LocalMedia media = images.get(i);
                    if (media == null
                            || TextUtils.isEmpty(media.getPath())) {
                        continue;
                    }
                    if (PictureMimeType.isHasImage(media.getMimeType())) {
                        imageNum++;
                    }
                    CutInfo cutInfo = new CutInfo();
                    cutInfo.setId(media.getId());
                    cutInfo.setPath(media.getPath());
                    cutInfo.setImageWidth(media.getWidth());
                    cutInfo.setImageHeight(media.getHeight());
                    cutInfo.setMimeType(media.getMimeType());
                    cutInfo.setDuration(media.getDuration());
                    cutInfo.setRealPath(media.getRealPath());
                    cuts.add(cutInfo);
                }
                if (imageNum <= 0) {
                    onResult(images);
                } else {
                    startCrop(cuts);
                }
            }
        } else if (config.isCompress) {
            int size = images.size();
            int imageNum = 0;
            for (int i = 0; i < size; i++) {
                LocalMedia media = images.get(i);
                if (PictureMimeType.isHasImage(media.getMimeType())) {
                    imageNum++;
                    break;
                }
            }
            if (imageNum <= 0) {
                onResult(images);
            } else {
                compressImage(images);
            }
        } else {
            onResult(images);
        }
    }


    private int index = 0;
    protected void startCrop(ArrayList<CutInfo> list) {
        if (DoubleUtils.isFastDoubleClick()) {
            return;
        }
        if (list == null || list.size() == 0) {
            ToastUtils.s(context, context.getString(R.string.picture_not_crop_data));
            return;
        }
        UCrop.Options options = basicOptions(list);
        int size = list.size();
        index = 0;
        if (config.chooseMode == PictureMimeType.ofAll() && config.isWithVideoImage) {
            String mimeType = size > 0 ? list.get(index).getMimeType() : "";
            boolean isHasVideo = PictureMimeType.isHasVideo(mimeType);
            if (isHasVideo) {
                for (int i = 0; i < size; i++) {
                    CutInfo cutInfo = list.get(i);
                    if (cutInfo != null && PictureMimeType.isHasImage(cutInfo.getMimeType())) {
                        index = i;
                        break;
                    }
                }
            }
        }

        if (PictureSelectionConfig.cacheResourcesEngine != null) {
            PictureThreadUtils.executeByIo(new PictureThreadUtils.SimpleTask<List<CutInfo>>() {

                @Override
                public List<CutInfo> doInBackground() {
                    for (int i = 0; i < size; i++) {
                        CutInfo cutInfo = list.get(i);
                        String cachePath = PictureSelectionConfig.cacheResourcesEngine.onCachePath(getContext(), cutInfo.getPath());
                        if (!TextUtils.isEmpty(cachePath)) {
                            cutInfo.setAndroidQToPath(cachePath);
                        }
                    }
                    return list;
                }

                @Override
                public void onSuccess(List<CutInfo> list) {
                    if (index < size) {
                        startMultipleCropActivity(list.get(index), size, options);
                    }
                }
            });

        } else {
            if (index < size) {
                startMultipleCropActivity(list.get(index), size, options);
            }
        }
    }


    /**
     * startMultipleCropActivity
     *
     * @param cutInfo
     * @param options
     */
    private void startMultipleCropActivity(CutInfo cutInfo, int count, UCrop.Options options) {
        String path = cutInfo.getPath();
        String mimeType = cutInfo.getMimeType();
        boolean isHttp = PictureMimeType.isHasHttp(path);
        Uri uri;
        if (!TextUtils.isEmpty(cutInfo.getAndroidQToPath())) {
            uri = Uri.fromFile(new File(cutInfo.getAndroidQToPath()));
        } else {
            uri = isHttp || SdkVersionUtils.checkedAndroid_Q() ? Uri.parse(path) : Uri.fromFile(new File(path));
        }
        String suffix = mimeType.replace("image/", ".");
        File file = new File(PictureFileUtils.getDiskCacheDir(context),
                TextUtils.isEmpty(config.renameCropFileName) ? DateUtils.getCreateFileName("IMG_CROP_")
                        + suffix : config.camera || count == 1 ? config.renameCropFileName : StringUtils.rename(config.renameCropFileName));
        UCrop.of(uri, Uri.fromFile(file))
                .withOptions(options)
                .startAnimationMultipleCropActivity((Activity) context, config.windowAnimationStyle != null
                        ? config.windowAnimationStyle.activityCropEnterAnimation : R.anim.picture_anim_enter);
    }

    /**
     * compressImage
     */
    protected void compressImage(final List<LocalMedia> result) {
        showPleaseDialog();
        if (PictureSelectionConfig.cacheResourcesEngine != null) {
            // 在Android 10上通过图片加载引擎的缓存来获得沙盒内的图片
            PictureThreadUtils.executeByIo(new PictureThreadUtils.SimpleTask<List<LocalMedia>>() {

                @Override
                public List<LocalMedia> doInBackground() {
                    int size = result.size();
                    for (int i = 0; i < size; i++) {
                        LocalMedia media = result.get(i);
                        if (media == null) {
                            continue;
                        }
                        if (!PictureMimeType.isHasHttp(media.getPath())) {
                            String cachePath = PictureSelectionConfig.cacheResourcesEngine.onCachePath(getContext(), media.getPath());
                            media.setAndroidQToPath(cachePath);
                        }
                    }
                    return result;
                }

                @Override
                public void onSuccess(List<LocalMedia> result) {
                    compressToLuban(result);
                }
            });
        } else {
            compressToLuban(result);
        }
    }


    /**
     * compress
     *
     * @param result
     */
    private void compressToLuban(List<LocalMedia> result) {
        if (config.synOrAsy) {
            PictureThreadUtils.executeByIo(new PictureThreadUtils.SimpleTask<List<File>>() {

                @Override
                public List<File> doInBackground() throws Exception {
                    return Luban.with(getContext())
                            .loadMediaData(result)
                            .isCamera(config.camera)
                            .setTargetDir(config.compressSavePath)
                            .setCompressQuality(config.compressQuality)
                            .setFocusAlpha(config.focusAlpha)
                            .setNewCompressFileName(config.renameCompressFileName)
                            .ignoreBy(config.minimumCompressSize).get();
                }

                @Override
                public void onSuccess(List<File> files) {
                    if (files != null && files.size() > 0 && files.size() == result.size()) {
                        handleCompressCallBack(result, files);
                    } else {
                        onResult(result);
                    }
                }
            });
        } else {
            Luban.with(context)
                    .loadMediaData(result)
                    .ignoreBy(config.minimumCompressSize)
                    .isCamera(config.camera)
                    .setCompressQuality(config.compressQuality)
                    .setTargetDir(config.compressSavePath)
                    .setFocusAlpha(config.focusAlpha)
                    .setNewCompressFileName(config.renameCompressFileName)
                    .setCompressListener(new OnCompressListener() {
                        @Override
                        public void onStart() {
                        }

                        @Override
                        public void onSuccess(List<LocalMedia> list) {
                            onResult(list);
                        }

                        @Override
                        public void onError(Throwable e) {
                            onResult(result);
                        }
                    }).launch();
        }
    }

    /**
     * handleCompressCallBack
     *
     * @param images
     * @param files
     */
    private void handleCompressCallBack(List<LocalMedia> images, List<File> files) {

        boolean isAndroidQ = SdkVersionUtils.checkedAndroid_Q();
        int size = images.size();
        if (files.size() == size) {
            for (int i = 0, j = size; i < j; i++) {
                File file = files.get(i);
                if (file == null) {
                    continue;
                }
                String path = file.getAbsolutePath();
                LocalMedia image = images.get(i);
                boolean http = PictureMimeType.isHasHttp(path);
                boolean flag = !TextUtils.isEmpty(path) && http;
                boolean isHasVideo = PictureMimeType.isHasVideo(image.getMimeType());
                image.setCompressed(!isHasVideo && !flag);
                image.setCompressPath(isHasVideo || flag ? null : path);
                if (isAndroidQ) {
                    image.setAndroidQToPath(image.getCompressPath());
                }
            }
        }
        onResult(images);
    }
    /**
     * crop
     *
     * @param originalPath
     * @param mimeType
     */
    protected void startCrop(String originalPath, String mimeType) {
        if (DoubleUtils.isFastDoubleClick()) {
            return;
        }
        if (TextUtils.isEmpty(originalPath)) {
            ToastUtils.s(context, context.getString(R.string.picture_not_crop_data));
            return;
        }
        UCrop.Options options = basicOptions();
        if (PictureSelectionConfig.cacheResourcesEngine != null) {
            PictureThreadUtils.executeByIo(new PictureThreadUtils.SimpleTask<String>() {
                @Override
                public String doInBackground() {
                    return PictureSelectionConfig.cacheResourcesEngine.onCachePath(getContext(), originalPath);
                }

                @Override
                public void onSuccess(String result) {
                    startSingleCropActivity(originalPath, result, mimeType, options);
                }
            });
        } else {
            startSingleCropActivity(originalPath, null, mimeType, options);
        }
    }

    /**
     * Single picture clipping callback
     *
     * @param data
     */
    public void singleCropHandleResult(Intent data) {
        if (data == null) {
            return;
        }
        Uri resultUri = UCrop.getOutput(data);
        if (resultUri == null) {
            return;
        }
        List<LocalMedia> result = new ArrayList<>();
        String cutPath = resultUri.getPath();
        if (mAdapter != null) {
            List<LocalMedia> list = data.getParcelableArrayListExtra(PictureConfig.EXTRA_SELECT_LIST);
            if (list != null) {
                mAdapter.bindSelectData(list);
                mAdapter.notifyDataSetChanged();
            }
            List<LocalMedia> mediaList = mAdapter.getSelectedData();
            LocalMedia media = mediaList != null && mediaList.size() > 0 ? mediaList.get(0) : null;
            if (media != null) {
                config.originalPath = media.getPath();
                media.setCutPath(cutPath);
                media.setChooseModel(config.chooseMode);
                boolean isCutPathEmpty = !TextUtils.isEmpty(cutPath);
                if (SdkVersionUtils.checkedAndroid_Q()
                        && PictureMimeType.isContent(media.getPath())) {
                    if (isCutPathEmpty) {
                        media.setSize(new File(cutPath).length());
                    } else {
                        media.setSize(!TextUtils.isEmpty(media.getRealPath()) ? new File(media.getRealPath()).length() : 0);
                    }
                    media.setAndroidQToPath(cutPath);
                } else {
                    media.setSize(isCutPathEmpty ? new File(cutPath).length() : 0);
                }
                media.setCut(isCutPathEmpty);
                result.add(media);
                _backSrcToFlutter(result);
            } else {
                // Preview screen selects the image and crop the callback
                media = list != null && list.size() > 0 ? list.get(0) : null;
                if (media != null) {
                    config.originalPath = media.getPath();
                    media.setCutPath(cutPath);
                    media.setChooseModel(config.chooseMode);
                    boolean isCutPathEmpty = !TextUtils.isEmpty(cutPath);
                    if (SdkVersionUtils.checkedAndroid_Q()
                            && PictureMimeType.isContent(media.getPath())) {
                        if (isCutPathEmpty) {
                            media.setSize(new File(cutPath).length());
                        } else {
                            media.setSize(!TextUtils.isEmpty(media.getRealPath()) ? new File(media.getRealPath()).length() : 0);
                        }
                        media.setAndroidQToPath(cutPath);
                    } else {
                        media.setSize(isCutPathEmpty ? new File(cutPath).length() : 0);
                    }
                    media.setCut(isCutPathEmpty);
                    result.add(media);
                    _backSrcToFlutter(result);
                }
            }
        }
    }


    /**
     * Set the crop style parameter
     *
     * @return
     */
    private UCrop.Options basicOptions() {
        return basicOptions(null);
    }

    /**
     * Set the crop style parameter
     *
     * @return
     */
    private UCrop.Options basicOptions(ArrayList<CutInfo> list) {
        int toolbarColor = 0, statusColor = 0, titleColor = 0;
        boolean isChangeStatusBarFontColor;
        if (config.cropStyle != null) {
            if (config.cropStyle.cropTitleBarBackgroundColor != 0) {
                toolbarColor = config.cropStyle.cropTitleBarBackgroundColor;
            }
            if (config.cropStyle.cropStatusBarColorPrimaryDark != 0) {
                statusColor = config.cropStyle.cropStatusBarColorPrimaryDark;
            }
            if (config.cropStyle.cropTitleColor != 0) {
                titleColor = config.cropStyle.cropTitleColor;
            }
            isChangeStatusBarFontColor = config.cropStyle.isChangeStatusBarFontColor;
        } else {
            if (config.cropTitleBarBackgroundColor != 0) {
                toolbarColor = config.cropTitleBarBackgroundColor;
            } else {
                toolbarColor = AttrsUtils.getTypeValueColor(context, R.attr.picture_crop_toolbar_bg);
            }
            if (config.cropStatusBarColorPrimaryDark != 0) {
                statusColor = config.cropStatusBarColorPrimaryDark;
            } else {
                statusColor = AttrsUtils.getTypeValueColor(context, R.attr.picture_crop_status_color);
            }
            if (config.cropTitleColor != 0) {
                titleColor = config.cropTitleColor;
            } else {
                titleColor = AttrsUtils.getTypeValueColor(context, R.attr.picture_crop_title_color);
            }

            isChangeStatusBarFontColor = config.isChangeStatusBarFontColor;
            if (!isChangeStatusBarFontColor) {
                isChangeStatusBarFontColor = AttrsUtils.getTypeValueBoolean(context, R.attr.picture_statusFontColor);
            }
        }
        UCrop.Options options = config.uCropOptions == null ? new UCrop.Options() : config.uCropOptions;
        options.isOpenWhiteStatusBar(isChangeStatusBarFontColor);
        options.setToolbarColor(toolbarColor);
        options.setStatusBarColor(statusColor);
        options.setToolbarWidgetColor(titleColor);
        options.setCircleDimmedLayer(config.circleDimmedLayer);
        options.setDimmedLayerColor(config.circleDimmedColor);
        options.setDimmedLayerBorderColor(config.circleDimmedBorderColor);
        options.setCircleStrokeWidth(config.circleStrokeWidth);
        options.setShowCropFrame(config.showCropFrame);
        options.setDragFrameEnabled(config.isDragFrame);
        options.setShowCropGrid(config.showCropGrid);
        options.setScaleEnabled(config.scaleEnabled);
        options.setRotateEnabled(config.rotateEnabled);
        options.isMultipleSkipCrop(config.isMultipleSkipCrop);
        options.setHideBottomControls(config.hideBottomControls);
        options.setCompressionQuality(config.cropCompressQuality);
        options.setRenameCropFileName(config.renameCropFileName);
        options.isCamera(config.camera);
        options.setCutListData(list);
        options.isWithVideoImage(config.isWithVideoImage);
        options.setFreeStyleCropEnabled(config.freeStyleCropEnabled);
        options.setCropExitAnimation(config.windowAnimationStyle != null
                ? config.windowAnimationStyle.activityCropExitAnimation : 0);
        options.setNavBarColor(config.cropStyle != null ? config.cropStyle.cropNavBarColor : 0);
        options.withAspectRatio(config.aspect_ratio_x, config.aspect_ratio_y);
        options.isMultipleRecyclerAnimation(config.isMultipleRecyclerAnimation);
        if (config.cropWidth > 0 && config.cropHeight > 0) {
            options.withMaxResultSize(config.cropWidth, config.cropHeight);
        }
        return options;
    }
    /**
     * single crop
     *
     * @param originalPath
     * @param cachePath
     * @param mimeType
     * @param options
     */
    private void startSingleCropActivity(String originalPath, String cachePath, String mimeType, UCrop.Options options) {
        boolean isHttp = PictureMimeType.isHasHttp(originalPath);
        String suffix = mimeType.replace("image/", ".");
        File file = new File(PictureFileUtils.getDiskCacheDir(getContext()),
                TextUtils.isEmpty(config.renameCropFileName) ? DateUtils.getCreateFileName("IMG_CROP_") + suffix : config.renameCropFileName);
        Uri uri;
        if (!TextUtils.isEmpty(cachePath)) {
            uri = Uri.fromFile(new File(cachePath));
        } else {
            uri = isHttp || SdkVersionUtils.checkedAndroid_Q() ? Uri.parse(originalPath) : Uri.fromFile(new File(originalPath));
        }
        UCrop.of(uri, Uri.fromFile(file))
                .withOptions(options)
                .startAnimationActivity((Activity) context, config.windowAnimationStyle != null
                        ? config.windowAnimationStyle.activityCropEnterAnimation : R.anim.picture_anim_enter);
    }

    /**
     * Same type of image or video processing logic
     *
     * @param isHasImage
     * @param images
     */
    private void separateMimeTypeWith(boolean isHasImage, List<LocalMedia> images) {
        LocalMedia image = images.size() > 0 ? images.get(0) : null;
        if (image == null) {
            return;
        }
        if (config.enableCrop && isHasImage) {
            if (config.selectionMode == PictureConfig.SINGLE) {
                config.originalPath = image.getPath();
            } else {
                ArrayList<CutInfo> cuts = new ArrayList<>();
                int count = images.size();
                for (int i = 0; i < count; i++) {
                    LocalMedia media = images.get(i);
                    if (media == null
                            || TextUtils.isEmpty(media.getPath())) {
                        continue;
                    }
                    CutInfo cutInfo = new CutInfo();
                    cutInfo.setId(media.getId());
                    cutInfo.setPath(media.getPath());
                    cutInfo.setImageWidth(media.getWidth());
                    cutInfo.setImageHeight(media.getHeight());
                    cutInfo.setMimeType(media.getMimeType());
                    cutInfo.setDuration(media.getDuration());
                    cutInfo.setRealPath(media.getRealPath());
                    cuts.add(cutInfo);
                }
            }
        }  else if (config.isCompress
                && isHasImage) {
            compressImage(images);
        } else {
            onResult(images);
        }
    }

    /**
     * Dialog
     *
     * @param content
     */
    protected void showPromptDialog(String content) {
        if (!((Activity)context).isFinishing()) {
            PictureCustomDialog dialog = new PictureCustomDialog(context, R.layout.picture_prompt_dialog);
            TextView btnOk = dialog.findViewById(R.id.btnOk);
            TextView tvContent = dialog.findViewById(R.id.tv_content);
            tvContent.setText(content);
            btnOk.setOnClickListener(v -> {
                if (!((Activity)context).isFinishing()) {
                    dialog.dismiss();
                }
            });
            dialog.show();
        }
    }
    /**
     * Preview
     */
    private void onPreview() {
        List<LocalMedia> selectedData = mAdapter.getSelectedData();
        List<LocalMedia> medias = new ArrayList<>();
        int size = selectedData.size();
        for (int i = 0; i < size; i++) {
            LocalMedia media = selectedData.get(i);
            medias.add(media);
        }
        if (PictureSelectionConfig.onCustomImagePreviewCallback != null) {
            PictureSelectionConfig.onCustomImagePreviewCallback.onCustomPreviewCallback(context, selectedData, 0);
            return;
        }
        Bundle bundle = new Bundle();
        bundle.putParcelableArrayList(PictureConfig.EXTRA_PREVIEW_SELECT_LIST, (ArrayList<? extends Parcelable>) medias);
        bundle.putParcelableArrayList(PictureConfig.EXTRA_SELECT_LIST, (ArrayList<? extends Parcelable>) selectedData);
        bundle.putBoolean(PictureConfig.EXTRA_BOTTOM_PREVIEW, true);
        bundle.putBoolean(PictureConfig.EXTRA_CHANGE_ORIGINAL, config.isCheckOriginalImage);
        bundle.putBoolean(PictureConfig.EXTRA_SHOW_CAMERA, mAdapter.isShowCamera());
        bundle.putString(PictureConfig.EXTRA_IS_CURRENT_DIRECTORY, mTvPictureTitle.getText().toString());
        JumpUtils.startPicturePreviewActivity(context, config.isWeChatStyle, bundle,
                config.selectionMode == PictureConfig.SINGLE ? UCrop.REQUEST_CROP : UCrop.REQUEST_MULTI_CROP);

        ((Activity)context).overridePendingTransition(config.windowAnimationStyle != null
                        && config.windowAnimationStyle.activityPreviewEnterAnimation != 0
                        ? config.windowAnimationStyle.activityPreviewEnterAnimation : R.anim.picture_anim_enter,
                R.anim.picture_anim_fade_in);
    }

    /**
     * Before switching directories, set the current directory cache
     */
    private void setLastCacheFolderData() {
        int oldPosition = ValueOf.toInt(mTvPictureTitle.getTag(R.id.view_index_tag));
        LocalMediaFolder lastFolder = albumView.getFolder(oldPosition);
        lastFolder.setData(mAdapter.getData());
        lastFolder.setCurrentDataPage(mPage);
        lastFolder.setHasMore(isHasMore);
    }

    /**
     * Does the current album have a cache
     *
     * @param position
     */
    private boolean isCurrentCacheFolderData(int position) {
        mTvPictureTitle.setTag(R.id.view_index_tag, position);
        LocalMediaFolder currentFolder = albumView.getFolder(position);
        if (currentFolder != null
                && currentFolder.getData() != null
                && currentFolder.getData().size() > 0) {
            mAdapter.bindData(currentFolder.getData());
            mPage = currentFolder.getCurrentDataPage();
            isHasMore = currentFolder.isHasMore();
            mRecyclerView.smoothScrollToPosition(0);

            return true;
        }
        return false;
    }
    @Override
    public void onItemClick(int position, boolean isCameraFolder, long bucketId, String folderName, List<LocalMedia> data) {

        boolean camera = config.isCamera && isCameraFolder;
        mAdapter.setShowCamera(camera);
        mTvPictureTitle.setText(folderName);
        long currentBucketId = ValueOf.toLong(mTvPictureTitle.getTag(R.id.view_tag));
        mTvPictureTitle.setTag(R.id.view_count_tag, albumView.getFolder(position) != null
                ? albumView.getFolder(position).getImageNum() : 0);
        if (config.isPageStrategy) {
            if (currentBucketId != bucketId) {
                setLastCacheFolderData();
                boolean isCurrentCacheFolderData = isCurrentCacheFolderData(position);
                if (!isCurrentCacheFolderData) {
                    mPage = 1;
                    showPleaseDialog();
                    LocalMediaPageLoader.getInstance(getContext(), config).loadPageMediaData(bucketId, mPage,
                            (OnQueryDataResultListener<LocalMedia>) (result, currentPage, isHasMore) -> {
                                this.isHasMore = isHasMore;
                                if (result.size() == 0) {
                                    mAdapter.clear();
                                }
                                mAdapter.bindData(result);
                                mRecyclerView.onScrolled(0, 0);
                                mRecyclerView.smoothScrollToPosition(0);
                                dismissDialog();
                            });
                }
            }
        } else {
            mAdapter.bindData(data);
            mRecyclerView.smoothScrollToPosition(0);
        }
        mTvPictureTitle.setTag(R.id.view_tag, bucketId);
        albumView.dismiss();


    }

    /**
     * dismiss dialog
     */
    protected void dismissDialog() {
        try {
            if (mLoadingDialog != null
                    && mLoadingDialog.isShowing()) {
                mLoadingDialog.dismiss();
            }
        } catch (Exception e) {
            mLoadingDialog = null;
            e.printStackTrace();
        }
    }

    @Override
    public void onTakePhoto() {
        // Check the permissions
        if (PermissionChecker.checkSelfPermission(context, Manifest.permission.CAMERA)) {
            if (PermissionChecker
                    .checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE) &&
                    PermissionChecker
                            .checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                startCamera();
            } else {
                PermissionChecker.requestPermissions((Activity) context, new String[]{
                        Manifest.permission.READ_EXTERNAL_STORAGE,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE}, PictureConfig.APPLY_CAMERA_STORAGE_PERMISSIONS_CODE);
            }
        } else {
            PermissionChecker
                    .requestPermissions((Activity) context,
                            new String[]{Manifest.permission.CAMERA}, PictureConfig.APPLY_CAMERA_PERMISSIONS_CODE);
        }
    }



    /**
     * Open Camera
     */
    public void startCamera() {
        if (!DoubleUtils.isFastDoubleClick()) {

            switch (config.chooseMode) {
                case PictureConfig.TYPE_IMAGE:
                    startOpenCamera();
                    break;
                case PictureConfig.TYPE_VIDEO:
                    startOpenCameraVideo();
                    break;
                default:
                    break;
            }
        }
    }


    /**
     * start to camera、preview、crop
     */
    protected void startOpenCamera() {
        Intent cameraIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if (cameraIntent.resolveActivity(context.getPackageManager()) != null) {
            Uri imageUri = null;
            if (SdkVersionUtils.checkedAndroid_Q()) {
                imageUri = MediaUtils.createImageUri(context.getApplicationContext(), config.suffixType);
                if (imageUri != null) {
                    config.cameraPath = imageUri.toString();
                }

            } else {
                int chooseMode = config.chooseMode == PictureConfig.TYPE_ALL ? PictureConfig.TYPE_IMAGE
                        : config.chooseMode;
                String cameraFileName = "";
                if (!TextUtils.isEmpty(config.cameraFileName)) {
                    boolean isSuffixOfImage = PictureMimeType.isSuffixOfImage(config.cameraFileName);
                    config.cameraFileName = !isSuffixOfImage ? StringUtils.renameSuffix(config.cameraFileName, PictureMimeType.JPEG) : config.cameraFileName;
                    cameraFileName = config.camera ? config.cameraFileName : StringUtils.rename(config.cameraFileName);
                }

                File cameraFile = PictureFileUtils.createCameraFile(context.getApplicationContext(),
                        chooseMode, cameraFileName, config.suffixType, config.outPutCameraPath);
                if (cameraFile != null) {
                    config.cameraPath = cameraFile.getAbsolutePath();
                    imageUri = PictureFileUtils.parUri(context, cameraFile);
                }
            }
            config.cameraMimeType = PictureMimeType.ofImage();
            if (config.isCameraAroundState) {
                cameraIntent.putExtra(PictureConfig.CAMERA_FACING, PictureConfig.CAMERA_BEFORE);
            }
            if (imageUri == null){
                return;
            }
            cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
            ((Activity)context).startActivityForResult(cameraIntent, PictureConfig.REQUEST_CAMERA);
        }
    }


    /**
     * start to camera、video
     */
    protected void startOpenCameraVideo() {
        Intent cameraIntent = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
        if (cameraIntent.resolveActivity(context.getPackageManager()) != null) {
            Uri videoUri = null;
            if (SdkVersionUtils.checkedAndroid_Q()) {
                videoUri = MediaUtils.createVideoUri(context.getApplicationContext(), config.suffixType);
                if (videoUri != null) {
                    config.cameraPath = videoUri.toString();
                }
            } else {
                int chooseMode = config.chooseMode ==
                        PictureConfig.TYPE_ALL ? PictureConfig.TYPE_VIDEO : config.chooseMode;
                String cameraFileName = "";
                if (!TextUtils.isEmpty(config.cameraFileName)) {
                    boolean isSuffixOfImage = PictureMimeType.isSuffixOfImage(config.cameraFileName);
                    config.cameraFileName = isSuffixOfImage ? StringUtils.renameSuffix(config.cameraFileName, PictureMimeType.MP4) : config.cameraFileName;
                    cameraFileName = config.camera ? config.cameraFileName : StringUtils.rename(config.cameraFileName);
                }
                File cameraFile = PictureFileUtils.createCameraFile(context.getApplicationContext(),
                        chooseMode, cameraFileName, config.suffixType, config.outPutCameraPath);
                if (cameraFile != null) {
                    config.cameraPath = cameraFile.getAbsolutePath();
                    videoUri = PictureFileUtils.parUri(context, cameraFile);
                }
            }

            if (videoUri == null){
                return;
            }

            config.cameraMimeType = PictureMimeType.ofVideo();
            cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, videoUri);
            if (config.isCameraAroundState) {
                cameraIntent.putExtra(PictureConfig.CAMERA_FACING, PictureConfig.CAMERA_BEFORE);
            }
            cameraIntent.putExtra(PictureConfig.EXTRA_QUICK_CAPTURE, config.isQuickCapture);
            cameraIntent.putExtra(MediaStore.EXTRA_DURATION_LIMIT, config.recordVideoSecond);
            cameraIntent.putExtra(MediaStore.EXTRA_VIDEO_QUALITY, config.videoQuality);
            ((Activity)context).startActivityForResult(cameraIntent, PictureConfig.REQUEST_CAMERA);
        }
    }

    @Override
    public void onChange(List<LocalMedia> selectData) {
        changeImageNumber(selectData);
    }

    /**
     * change image selector state
     *
     * @param selectData
     */
    protected void changeImageNumber(List<LocalMedia> selectData) {
        boolean enable = selectData.size() != 0;
        if (enable) {
            mTvPictureOk.setEnabled(true);
            mTvPictureOk.setSelected(true);
            mTvPicturePreview.setEnabled(true);
            mTvPicturePreview.setSelected(true);
            if (config.style != null) {
                if (config.style.pictureCompleteTextColor != 0) {
                    mTvPictureOk.setTextColor(config.style.pictureCompleteTextColor);
                }
                if (config.style.picturePreviewTextColor != 0) {
                    mTvPicturePreview.setTextColor(config.style.picturePreviewTextColor);
                }
            }
            if (config.style != null && !TextUtils.isEmpty(config.style.picturePreviewText)) {
                mTvPicturePreview.setText(config.style.picturePreviewText);
            } else {
                mTvPicturePreview.setText(context.getString(R.string.picture_preview_num, selectData.size()));
            }
            if (numComplete) {
                initCompleteText(selectData.size());
            } else {
                if (!isStartAnimation) {
                    mTvPictureImgNum.startAnimation(animation);
                }
                mTvPictureImgNum.setVisibility(View.VISIBLE);
                mTvPictureImgNum.setText(String.valueOf(selectData.size()));
                if (config.style != null && !TextUtils.isEmpty(config.style.pictureCompleteText)) {
                    mTvPictureOk.setText(config.style.pictureCompleteText);
                } else {
                    mTvPictureOk.setText(context.getString(R.string.picture_completed));
                }
                isStartAnimation = false;
            }
        } else {
            mTvPictureOk.setEnabled(config.returnEmpty);
            mTvPictureOk.setSelected(false);
            mTvPicturePreview.setEnabled(false);
            mTvPicturePreview.setSelected(false);
            if (config.style != null) {
                if (config.style.pictureUnCompleteTextColor != 0) {
                    mTvPictureOk.setTextColor(config.style.pictureUnCompleteTextColor);
                }
                if (config.style.pictureUnPreviewTextColor != 0) {
                    mTvPicturePreview.setTextColor(config.style.pictureUnPreviewTextColor);
                }
            }
            if (config.style != null && !TextUtils.isEmpty(config.style.pictureUnPreviewText)) {
                mTvPicturePreview.setText(config.style.pictureUnPreviewText);
            } else {
                mTvPicturePreview.setText(context.getString(R.string.picture_preview));
            }
            if (numComplete) {
                initCompleteText(selectData.size());
            } else {
                mTvPictureImgNum.setVisibility(View.INVISIBLE);
                if (config.style != null && !TextUtils.isEmpty(config.style.pictureUnCompleteText)) {
                    mTvPictureOk.setText(config.style.pictureUnCompleteText);
                } else {
                    mTvPictureOk.setText(context.getString(R.string.picture_please_select));
                }
            }
        }
    }
    @Override
    public void onPictureClick(LocalMedia media, int position) {
        if (config.selectionMode == PictureConfig.SINGLE && config.isSingleDirectReturn) {
            List<LocalMedia> list = new ArrayList<>();
            list.add(media);
            if (config.enableCrop && PictureMimeType.isHasImage(media.getMimeType()) && !config.isCheckOriginalImage) {
                mAdapter.bindSelectData(list);
                startCrop(media.getPath(), media.getMimeType());
            } else {
                onResult(list);
            }
        } else {
            List<LocalMedia> data = mAdapter.getData();
            startPreview(data, position);
        }
    }


    /**
     * preview image and video
     *
     * @param previewData
     * @param position
     */
    public void startPreview(List<LocalMedia> previewData, int position) {
        LocalMedia media = previewData.get(position);
        String mimeType = media.getMimeType();
        Bundle bundle = new Bundle();
        List<LocalMedia> result = new ArrayList<>();
        if (PictureMimeType.isHasVideo(mimeType)) {
            // video
            if (config.selectionMode == PictureConfig.SINGLE && !config.enPreviewVideo) {
                result.add(media);
                onResult(result);
            } else {
                if (PictureSelectionConfig.customVideoPlayCallback != null) {
                    PictureSelectionConfig.customVideoPlayCallback.startPlayVideo(media);
                } else {
                    bundle.putParcelable(PictureConfig.EXTRA_MEDIA_KEY, media);
                    JumpUtils.startPictureVideoPlayActivity(getContext(), bundle, PictureConfig.PREVIEW_VIDEO_CODE);
                }
            }
        } else if (PictureMimeType.isHasAudio(mimeType)) {
            // audio
//            if (config.selectionMode == PictureConfig.SINGLE) {
//                result.add(media);
//                onResult(result);
//            } else {
//                AudioDialog(media.getPath());
//            }
        } else {
            // image
            if (PictureSelectionConfig.onCustomImagePreviewCallback != null) {
                PictureSelectionConfig.onCustomImagePreviewCallback.onCustomPreviewCallback(getContext(), previewData, position);
                return;
            }
            List<LocalMedia> selectedData = mAdapter.getSelectedData();
            ImagesObservable.getInstance().savePreviewMediaData(new ArrayList<>(previewData));
            bundle.putParcelableArrayList(PictureConfig.EXTRA_SELECT_LIST, (ArrayList<? extends Parcelable>) selectedData);
            bundle.putInt(PictureConfig.EXTRA_POSITION, position);
            bundle.putBoolean(PictureConfig.EXTRA_CHANGE_ORIGINAL, config.isCheckOriginalImage);
            bundle.putBoolean(PictureConfig.EXTRA_SHOW_CAMERA, mAdapter.isShowCamera());
            bundle.putLong(PictureConfig.EXTRA_BUCKET_ID, ValueOf.toLong(mTvPictureTitle.getTag(R.id.view_tag)));
            bundle.putInt(PictureConfig.EXTRA_PAGE, mPage);
            bundle.putParcelable(PictureConfig.EXTRA_CONFIG, config);
            bundle.putInt(PictureConfig.EXTRA_DATA_COUNT, ValueOf.toInt(mTvPictureTitle.getTag(R.id.view_count_tag)));
            bundle.putString(PictureConfig.EXTRA_IS_CURRENT_DIRECTORY, mTvPictureTitle.getText().toString());
            JumpUtils.startPicturePreviewActivity(getContext(), config.isWeChatStyle, bundle,
                    config.selectionMode == PictureConfig.SINGLE ? UCrop.REQUEST_CROP : UCrop.REQUEST_MULTI_CROP);
            ((Activity)context).overridePendingTransition(config.windowAnimationStyle != null
                    && config.windowAnimationStyle.activityPreviewEnterAnimation != 0
                    ? config.windowAnimationStyle.activityPreviewEnterAnimation : R.anim.picture_anim_enter, R.anim.picture_anim_fade_in);
        }
    }

    /**
     * return image result
     *
     * @param images
     */
    protected void onResult(List<LocalMedia> images) {
        boolean isAndroidQ = SdkVersionUtils.checkedAndroid_Q();
        if (isAndroidQ && config.isAndroidQTransform) {
            showPleaseDialog();
            onResultToAndroidAsy(images);
        } else {
            dismissDialog();
            if (config.camera
                    && config.selectionMode == PictureConfig.MULTIPLE) {
                images.addAll(images.size() > 0 ? images.size() - 1 : 0, null);
            }
            if (config.isCheckOriginalImage) {
                int size = images.size();
                for (int i = 0; i < size; i++) {
                    LocalMedia media = images.get(i);
                    media.setOriginal(true);
                    media.setOriginalPath(media.getPath());
                }
            }
            if (PictureSelectionConfig.listener != null) {
                PictureSelectionConfig.listener.onResult(images);
            }
        }
    }
    /**
     * Android Q
     *
     * @param images
     */
    private void onResultToAndroidAsy(List<LocalMedia> images) {
        PictureThreadUtils.executeByIo(new PictureThreadUtils.SimpleTask<List<LocalMedia>>() {
            @Override
            public List<LocalMedia> doInBackground() {
                int size = images.size();
                for (int i = 0; i < size; i++) {
                    LocalMedia media = images.get(i);
                    if (media == null || TextUtils.isEmpty(media.getPath())) {
                        continue;
                    }
                    boolean isCopyAndroidQToPath = !media.isCut()
                            && !media.isCompressed()
                            && TextUtils.isEmpty(media.getAndroidQToPath());
                    if (isCopyAndroidQToPath && PictureMimeType.isContent(media.getPath())) {
                        if (!PictureMimeType.isHasHttp(media.getPath())) {
                            String AndroidQToPath = AndroidQTransformUtils.copyPathToAndroidQ(getContext(),
                                    media.getPath(), media.getWidth(), media.getHeight(), media.getMimeType(), config.cameraFileName);
                            media.setAndroidQToPath(AndroidQToPath);
                        }
                    } else if (media.isCut() && media.isCompressed()) {
                        media.setAndroidQToPath(media.getCompressPath());
                    }
                    if (config.isCheckOriginalImage) {
                        media.setOriginal(true);
                        media.setOriginalPath(media.getAndroidQToPath());
                    }
                }
                return images;
            }

            @Override
            public void onSuccess(List<LocalMedia> images) {
                dismissDialog();
                if (images != null) {
                    if (PictureSelectionConfig.listener != null) {
                        PictureSelectionConfig.listener.onResult(images);
                    }
                }
            }
        });
    }
    @Override
    public void onRecyclerViewPreloadMore() {
        loadMoreData();
    }

    /**
     * getPageLimit
     * # If the user clicks to take a photo and returns, the Limit should be adjusted dynamically
     *
     * @return
     */
    private int getPageLimit() {
        int bucketId = ValueOf.toInt(mTvPictureTitle.getTag(R.id.view_tag));
        if (bucketId == -1) {
            int limit = mOpenCameraCount > 0 ? config.pageSize - mOpenCameraCount : config.pageSize;
            mOpenCameraCount = 0;
            return limit;
        }
        return config.pageSize;
    }
    /**
     * load more data
     */
    private void loadMoreData() {
        if (mAdapter != null) {
            if (isHasMore) {
                mPage++;
                long bucketId = ValueOf.toLong(mTvPictureTitle.getTag(R.id.view_tag));
                LocalMediaPageLoader.getInstance(getContext(), config).loadPageMediaData(bucketId, mPage, getPageLimit(),
                        (OnQueryDataResultListener<LocalMedia>) (result, currentPage, isHasMore) -> {
                            this.isHasMore = isHasMore;
                            if (isHasMore) {
                                hideDataNull();
                                int size = result.size();
                                if (size > 0) {
                                    int positionStart = mAdapter.getSize();
                                    mAdapter.getData().addAll(result);
                                    int itemCount = mAdapter.getItemCount();
                                    mAdapter.notifyItemRangeChanged(positionStart, itemCount);
                                } else {
                                    onRecyclerViewPreloadMore();
                                }
                                if (size < PictureConfig.MIN_PAGE_SIZE) {
                                    mRecyclerView.onScrolled(mRecyclerView.getScrollX(), mRecyclerView.getScrollY());
                                }
                            } else {
                                boolean isEmpty = mAdapter.isDataEmpty();
                                if (isEmpty) {
                                    showDataNull(bucketId == -1 ? context.getString(R.string.picture_empty) : context.getString(R.string.picture_data_null), R.drawable.picture_icon_no_data);
                                }
                            }
                        });
            }
        }
    }

    /**
     * Camera Handle
     *
     * @param intent
     */
    protected void dispatchHandleCamera(Intent intent) {
        // If PictureSelectionConfig is not empty, synchronize it
        PictureSelectionConfig selectionConfig = intent != null ? intent.getParcelableExtra(PictureConfig.EXTRA_CONFIG) : null;
        if (selectionConfig != null) {
            config = selectionConfig;
        }
        boolean isAudio = config.chooseMode == PictureMimeType.ofAudio();
        config.cameraPath = config.cameraPath;
        if (TextUtils.isEmpty(config.cameraPath)) {
            return;
        }
        showPleaseDialog();
        PictureThreadUtils.executeByIo(new PictureThreadUtils.SimpleTask<LocalMedia>() {

            @Override
            public LocalMedia doInBackground() {
                LocalMedia media = new LocalMedia();
                String mimeType = isAudio ? PictureMimeType.MIME_TYPE_AUDIO : "";
                int[] newSize = new int[2];
                long duration = 0;
                if (!isAudio) {
                    if (PictureMimeType.isContent(config.cameraPath)) {
                        // content: Processing rules
                        String path = PictureFileUtils.getPath(getContext(), Uri.parse(config.cameraPath));
                        if (!TextUtils.isEmpty(path)) {
                            File cameraFile = new File(path);
                            mimeType = PictureMimeType.getMimeType(config.cameraMimeType);
                            media.setSize(cameraFile.length());
                        }
                        if (PictureMimeType.isHasImage(mimeType)) {
                            newSize = MediaUtils.getImageSizeForUrlToAndroidQ(getContext(), config.cameraPath);
                        } else if (PictureMimeType.isHasVideo(mimeType)) {
                            newSize = MediaUtils.getVideoSizeForUri(getContext(), Uri.parse(config.cameraPath));
                            duration = MediaUtils.extractDuration(getContext(), SdkVersionUtils.checkedAndroid_Q(), config.cameraPath);
                        }
                        int lastIndexOf = config.cameraPath.lastIndexOf("/") + 1;
                        media.setId(lastIndexOf > 0 ? ValueOf.toLong(config.cameraPath.substring(lastIndexOf)) : -1);
                        media.setRealPath(path);
                        // Custom photo has been in the application sandbox into the file
                        String mediaPath = intent != null ? intent.getStringExtra(PictureConfig.EXTRA_MEDIA_PATH) : null;
                        media.setAndroidQToPath(mediaPath);
                    } else {
                        File cameraFile = new File(config.cameraPath);
                        mimeType = PictureMimeType.getMimeType(config.cameraMimeType);
                        media.setSize(cameraFile.length());
                        if (PictureMimeType.isHasImage(mimeType)) {
                            int degree = PictureFileUtils.readPictureDegree(getContext(), config.cameraPath);
                            BitmapUtils.rotateImage(degree, config.cameraPath);
                            newSize = MediaUtils.getImageSizeForUrl(config.cameraPath);
                        } else if (PictureMimeType.isHasVideo(mimeType)) {
                            newSize = MediaUtils.getVideoSizeForUrl(config.cameraPath);
                            duration = MediaUtils.extractDuration(getContext(), SdkVersionUtils.checkedAndroid_Q(), config.cameraPath);
                        }
                        // Taking a photo generates a temporary id
                        media.setId(System.currentTimeMillis());
                    }
                    media.setPath(config.cameraPath);
                    media.setDuration(duration);
                    media.setMimeType(mimeType);
                    media.setWidth(newSize[0]);
                    media.setHeight(newSize[1]);
                    if (SdkVersionUtils.checkedAndroid_Q() && PictureMimeType.isHasVideo(media.getMimeType())) {
                        media.setParentFolderName(Environment.DIRECTORY_MOVIES);
                    } else {
                        media.setParentFolderName(PictureMimeType.CAMERA);
                    }
                    media.setChooseModel(config.chooseMode);
                    long bucketId = MediaUtils.getCameraFirstBucketId(getContext());
                    media.setBucketId(bucketId);
                    // The width and height of the image are reversed if there is rotation information
                    MediaUtils.setOrientationSynchronous(getContext(), media, config.isAndroidQChangeWH, config.isAndroidQChangeVideoWH);
                }
                return media;
            }

            @Override
            public void onSuccess(LocalMedia result) {
                dismissDialog();
                // Refresh the system library
                if (!SdkVersionUtils.checkedAndroid_Q()) {
                    if (config.isFallbackVersion3) {
                        new PictureMediaScannerConnection(getContext(), config.cameraPath);
                    } else {
                        context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(new File(config.cameraPath))));
                    }
                }
                // add data Adapter
                notifyAdapterData(result);
                // Solve some phone using Camera, DCIM will produce repetitive problems
                if (!SdkVersionUtils.checkedAndroid_Q() && PictureMimeType.isHasImage(result.getMimeType())) {
                    int lastImageId = MediaUtils.getDCIMLastImageId(getContext());
                    if (lastImageId != -1) {
                        MediaUtils.removeMedia(getContext(), lastImageId);
                    }
                }
            }
        });

    }


    /**
     * Update Adapter Data
     *
     * @param media
     */
    private void notifyAdapterData(LocalMedia media) {
        if (mAdapter != null) {
            boolean isAddSameImp = isAddSameImp(albumView.getFolder(0) != null ? albumView.getFolder(0).getImageNum() : 0);
            if (!isAddSameImp) {
                mAdapter.getData().add(0, media);
                mOpenCameraCount++;
            }
            if (checkVideoLegitimacy(media)) {
                if (config.selectionMode == PictureConfig.SINGLE) {
                    dispatchHandleSingle(media);
                } else {
                    dispatchHandleMultiple(media);
                }
            }
            mAdapter.notifyItemInserted(config.isCamera ? 1 : 0);
            mAdapter.notifyItemRangeChanged(config.isCamera ? 1 : 0, mAdapter.getSize());
            // Solve the problem that some mobile phones do not refresh the system library timely after using Camera
            if (config.isPageStrategy) {
                manualSaveFolderForPageModel(media);
            } else {
                manualSaveFolder(media);
            }
            mTvEmpty.setVisibility(mAdapter.getSize() > 0 || config.isSingleDirectReturn ? View.GONE : View.VISIBLE);
            // update all count
            if (albumView.getFolder(0) != null) {
                mTvPictureTitle.setTag(R.id.view_count_tag, albumView.getFolder(0).getImageNum());
            }
            allFolderSize = 0;
        }
    }

    /**
     * Manually add the photo to the list of photos and set it to select
     *
     * @param media
     */
    private void manualSaveFolder(LocalMedia media) {
        try {
            boolean isEmpty = albumView.isEmpty();
            int totalNum = albumView.getFolder(0) != null ? albumView.getFolder(0).getImageNum() : 0;
            LocalMediaFolder allFolder;
            if (isEmpty) {
                // All Folder
                createNewFolder(albumView.getFolderData());
                allFolder = albumView.getFolderData().size() > 0 ? albumView.getFolderData().get(0) : null;
                if (allFolder == null) {
                    allFolder = new LocalMediaFolder();
                    albumView.getFolderData().add(0, allFolder);
                }
            } else {
                // All Folder
                allFolder = albumView.getFolderData().get(0);
            }
            allFolder.setFirstImagePath(media.getPath());
            allFolder.setData(mAdapter.getData());
            allFolder.setBucketId(-1);
            allFolder.setImageNum(isAddSameImp(totalNum) ? allFolder.getImageNum() : allFolder.getImageNum() + 1);

            // Camera
            LocalMediaFolder cameraFolder = getImageFolder(media.getPath(), media.getRealPath(), albumView.getFolderData());
            if (cameraFolder != null) {
                cameraFolder.setImageNum(isAddSameImp(totalNum) ? cameraFolder.getImageNum() : cameraFolder.getImageNum() + 1);
                if (!isAddSameImp(totalNum)) {
                    cameraFolder.getData().add(0, media);
                }
                cameraFolder.setBucketId(media.getBucketId());
                cameraFolder.setFirstImagePath(config.cameraPath);
            }
            albumView.bindFolder(albumView.getFolderData());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Insert the image into the camera folder
     *
     * @param path
     * @param imageFolders
     * @return
     */
    protected LocalMediaFolder getImageFolder(String path, String realPath, List<LocalMediaFolder> imageFolders) {
        File imageFile = new File(PictureMimeType.isContent(path) ? realPath : path);
        File folderFile = imageFile.getParentFile();
        for (LocalMediaFolder folder : imageFolders) {
            if (folderFile != null && folder.getName().equals(folderFile.getName())) {
                return folder;
            }
        }
        LocalMediaFolder newFolder = new LocalMediaFolder();
        newFolder.setName(folderFile != null ? folderFile.getName() : "");
        newFolder.setFirstImagePath(path);
        imageFolders.add(newFolder);
        return newFolder;
    }

    /**
     * If you don't have any albums, first create a camera film folder to come out
     *
     * @param folders
     */
    protected void createNewFolder(List<LocalMediaFolder> folders) {
        if (folders.size() == 0) {
            // 没有相册 先创建一个最近相册出来
            LocalMediaFolder newFolder = new LocalMediaFolder();
            String folderName = config.chooseMode == PictureMimeType.ofAudio() ?
                    context.getString(R.string.picture_all_audio) : context.getString(R.string.picture_camera_roll);
            newFolder.setName(folderName);
            newFolder.setFirstImagePath("");
            newFolder.setCameraFolder(true);
            newFolder.setBucketId(-1);
            newFolder.setChecked(true);
            folders.add(newFolder);
        }
    }

    /**
     * Manually add the photo to the list of photos and set it to select-paging mode
     *
     * @param media
     */
    private void manualSaveFolderForPageModel(LocalMedia media) {
        if (media == null) {
            return;
        }
        int count = albumView.getFolderData().size();
        LocalMediaFolder allFolder = count > 0 ? albumView.getFolderData().get(0) : new LocalMediaFolder();
        if (allFolder != null) {
            int totalNum = allFolder.getImageNum();
            allFolder.setFirstImagePath(media.getPath());
            allFolder.setImageNum(isAddSameImp(totalNum) ? allFolder.getImageNum() : allFolder.getImageNum() + 1);
            // Create All folder
            if (count == 0) {
                allFolder.setName(config.chooseMode == PictureMimeType.ofAudio() ?
                        context.getString(R.string.picture_all_audio) : context.getString(R.string.picture_camera_roll));
                allFolder.setOfAllType(config.chooseMode);
                allFolder.setCameraFolder(true);
                allFolder.setChecked(true);
                allFolder.setBucketId(-1);
                albumView.getFolderData().add(0, allFolder);
                // Create Camera
                LocalMediaFolder cameraFolder = new LocalMediaFolder();
                cameraFolder.setName(media.getParentFolderName());
                cameraFolder.setImageNum(isAddSameImp(totalNum) ? cameraFolder.getImageNum() : cameraFolder.getImageNum() + 1);
                cameraFolder.setFirstImagePath(media.getPath());
                cameraFolder.setBucketId(media.getBucketId());
                albumView.getFolderData().add(albumView.getFolderData().size(), cameraFolder);
            } else {
                boolean isCamera = false;
                String newFolder = SdkVersionUtils.checkedAndroid_Q() && PictureMimeType.isHasVideo(media.getMimeType())
                        ? Environment.DIRECTORY_MOVIES : PictureMimeType.CAMERA;
                for (int i = 0; i < count; i++) {
                    LocalMediaFolder cameraFolder = albumView.getFolderData().get(i);
                    if (cameraFolder.getName().startsWith(newFolder)) {
                        media.setBucketId(cameraFolder.getBucketId());
                        cameraFolder.setFirstImagePath(config.cameraPath);
                        cameraFolder.setImageNum(isAddSameImp(totalNum) ? cameraFolder.getImageNum() : cameraFolder.getImageNum() + 1);
                        if (cameraFolder.getData() != null && cameraFolder.getData().size() > 0) {
                            cameraFolder.getData().add(0, media);
                        }
                        isCamera = true;
                        break;
                    }
                }
                if (!isCamera) {
                    // There is no Camera folder locally. Create one
                    LocalMediaFolder cameraFolder = new LocalMediaFolder();
                    cameraFolder.setName(media.getParentFolderName());
                    cameraFolder.setImageNum(isAddSameImp(totalNum) ? cameraFolder.getImageNum() : cameraFolder.getImageNum() + 1);
                    cameraFolder.setFirstImagePath(media.getPath());
                    cameraFolder.setBucketId(media.getBucketId());
                    albumView.getFolderData().add(cameraFolder);
                    sortFolder(albumView.getFolderData());
                }
            }
            albumView.bindFolder(albumView.getFolderData());
        }
    }

    /**
     * sort
     *
     * @param imageFolders
     */
    protected void sortFolder(List<LocalMediaFolder> imageFolders) {
        Collections.sort(imageFolders, (lhs, rhs) -> {
            if (lhs.getData() == null || rhs.getData() == null) {
                return 0;
            }
            int lSize = lhs.getImageNum();
            int rSize = rhs.getImageNum();
            return Integer.compare(rSize, lSize);
        });
    }

    /**
     * After using Camera, MultiSelect mode handles the logic
     *
     * @param media
     */
    @SuppressLint("StringFormatMatches")
    private void dispatchHandleMultiple(LocalMedia media) {
        List<LocalMedia> selectedData = mAdapter.getSelectedData();
        int count = selectedData.size();
        String oldMimeType = count > 0 ? selectedData.get(0).getMimeType() : "";
        boolean mimeTypeSame = PictureMimeType.isMimeTypeSame(oldMimeType, media.getMimeType());
        if (config.isWithVideoImage) {
            int videoSize = 0;
            for (int i = 0; i < count; i++) {
                LocalMedia item = selectedData.get(i);
                if (PictureMimeType.isHasVideo(item.getMimeType())) {
                    videoSize++;
                }
            }
            if (PictureMimeType.isHasVideo(media.getMimeType())) {
                if (config.maxVideoSelectNum <= 0) {
                    showPromptDialog(context.getString(R.string.picture_rule));
                } else {
                    if (selectedData.size() >= config.maxSelectNum) {
                        showPromptDialog(context.getString(R.string.picture_message_max_num, config.maxSelectNum));
                    } else {
                        if (videoSize < config.maxVideoSelectNum) {
                            selectedData.add(0, media);
                            mAdapter.bindSelectData(selectedData);
                        } else {
                            showPromptDialog(StringUtils.getMsg(getContext(), media.getMimeType(),
                                    config.maxVideoSelectNum));
                        }
                    }
                }
            } else {
                if (selectedData.size() < config.maxSelectNum) {
                    selectedData.add(0, media);
                    mAdapter.bindSelectData(selectedData);
                } else {
                    showPromptDialog(StringUtils.getMsg(getContext(), media.getMimeType(),
                            config.maxSelectNum));
                }
            }

        } else {
            if (PictureMimeType.isHasVideo(oldMimeType) && config.maxVideoSelectNum > 0) {
                if (count < config.maxVideoSelectNum) {
                    if (mimeTypeSame || count == 0) {
                        if (selectedData.size() < config.maxVideoSelectNum) {
                            selectedData.add(0, media);
                            mAdapter.bindSelectData(selectedData);
                        }
                    }
                } else {
                    showPromptDialog(StringUtils.getMsg(getContext(), oldMimeType,
                            config.maxVideoSelectNum));
                }
            } else {
                if (count < config.maxSelectNum) {
                    if (mimeTypeSame || count == 0) {
                        selectedData.add(0, media);
                        mAdapter.bindSelectData(selectedData);
                    }
                } else {
                    showPromptDialog(StringUtils.getMsg(getContext(), oldMimeType,
                            config.maxSelectNum));
                }
            }
        }
    }

    /**
     * After using the camera, the radio mode handles the logic
     *
     * @param media
     */
    private void dispatchHandleSingle(LocalMedia media) {
        if (config.isSingleDirectReturn) {
            List<LocalMedia> selectedData = mAdapter.getSelectedData();
            selectedData.add(media);
            mAdapter.bindSelectData(selectedData);
            singleDirectReturnCameraHandleResult(media.getMimeType());
        } else {
            List<LocalMedia> selectedData = mAdapter.getSelectedData();
            String mimeType = selectedData.size() > 0 ? selectedData.get(0).getMimeType() : "";
            boolean mimeTypeSame = PictureMimeType.isMimeTypeSame(mimeType, media.getMimeType());
            if (mimeTypeSame || selectedData.size() == 0) {
                singleRadioMediaImage();
                selectedData.add(media);
                mAdapter.bindSelectData(selectedData);
            }
        }
    }


    /**
     * Just make sure you pick one
     */
    private void singleRadioMediaImage() {
        List<LocalMedia> selectData = mAdapter.getSelectedData();
        if (selectData != null
                && selectData.size() > 0) {
            LocalMedia media = selectData.get(0);
            int position = media.getPosition();
            selectData.clear();
            mAdapter.notifyItemChanged(position);
        }
    }

    /**
     * singleDirectReturn
     *
     * @param mimeType
     */
    private void singleDirectReturnCameraHandleResult(String mimeType) {
        boolean isHasImage = PictureMimeType.isHasImage(mimeType);
        if (config.enableCrop && isHasImage) {
            config.originalPath = config.cameraPath;
            startCrop(config.cameraPath, mimeType);
        } else if (config.isCompress && isHasImage) {
            List<LocalMedia> selectedImages = mAdapter.getSelectedData();
            compressImage(selectedImages);
        } else {
            onResult(mAdapter.getSelectedData());
        }
    }

    /**
     * Verify the validity of the video
     *
     * @param media
     * @return
     */
    private boolean checkVideoLegitimacy(LocalMedia media) {
        boolean isEnterNext = true;
        if (PictureMimeType.isHasVideo(media.getMimeType())) {
            if (config.videoMinSecond > 0 && config.videoMaxSecond > 0) {
                // The user sets the minimum and maximum video length to determine whether the video is within the interval
                if (media.getDuration() < config.videoMinSecond || media.getDuration() > config.videoMaxSecond) {
                    isEnterNext = false;
                    showPromptDialog(context.getString(R.string.picture_choose_limit_seconds, config.videoMinSecond / 1000, config.videoMaxSecond / 1000));
                }
            } else if (config.videoMinSecond > 0) {
                // The user has only set a minimum video length limit
                if (media.getDuration() < config.videoMinSecond) {
                    isEnterNext = false;
                    showPromptDialog(context.getString(R.string.picture_choose_min_seconds, config.videoMinSecond / 1000));
                }
            } else if (config.videoMaxSecond > 0) {
                // Only the maximum length of video is set
                if (media.getDuration() > config.videoMaxSecond) {
                    isEnterNext = false;
                    showPromptDialog(context.getString(R.string.picture_choose_max_seconds, config.videoMaxSecond / 1000));
                }
            }
        }
        return isEnterNext;
    }

    /**
     * Is the quantity consistent
     *
     * @return
     */
    private boolean isAddSameImp(int totalNum) {
        if (totalNum == 0) {
            return false;
        }
        return allFolderSize > 0 && allFolderSize < totalNum;
    }

    @Override
    public void onItemClick(View v, int position) {
        switch (position) {
            case PhotoItemSelectedDialog.IMAGE_CAMERA:
                startOpenCamera();
                break;
            case PhotoItemSelectedDialog.VIDEO_CAMERA:
                startOpenCameraVideo();
                break;
            default:
                break;
    }}
}

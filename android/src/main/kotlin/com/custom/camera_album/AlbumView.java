package com.custom.camera_album;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.luck.picture.lib.R;
import com.luck.picture.lib.adapter.PictureAlbumDirectoryAdapter;
import com.luck.picture.lib.config.PictureSelectionConfig;
import com.luck.picture.lib.entity.LocalMedia;
import com.luck.picture.lib.entity.LocalMediaFolder;
import com.luck.picture.lib.listener.OnAlbumItemClickListener;
import com.luck.picture.lib.tools.AnimUtils;
import com.luck.picture.lib.tools.AttrsUtils;
import com.luck.picture.lib.tools.ScreenUtils;

import java.util.List;

public class AlbumView extends RelativeLayout {

    private Context context;
    private View rootView;
    private RecyclerView mRecyclerView;
    private PictureAlbumDirectoryAdapter adapter;
    private boolean isDismiss = false;
    private ImageView ivArrowView;
    private Drawable drawableUp, drawableDown;
    private int chooseMode;
    private PictureSelectionConfig config;
    private int maxHeight;
    private View rootViewBg;


    public AlbumView(Context context) {
        this(context,null);
    }

    public AlbumView(Context con, AttributeSet attrs) {
        super(con, attrs);
        context = con;
        LayoutInflater.from(context).inflate(R.layout.picture_window_folder, this);
        rootViewBg = findViewById(R.id.rootViewBg);
        mRecyclerView = findViewById(R.id.folder_list);
        mRecyclerView.setLayoutManager(new LinearLayoutManager(context));
        rootView = findViewById(R.id.rootView);
        rootViewBg.setOnClickListener(v -> dismiss());
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            rootView.setOnClickListener(v -> dismiss());
        }
        setVisibility(GONE);

    }

    public AlbumView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public AlbumView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    /**展示相册框*/
    public void showAsDropDown() {
        try {
            setVisibility(VISIBLE);
            ivArrowView.setImageDrawable(drawableUp);
            AnimUtils.rotateArrow(ivArrowView, true);
            rootViewBg.animate()
                    .alpha(1)
                    .setDuration(250)
                    .setStartDelay(50).start();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**关闭相册*/
    public void dismiss() {

        setVisibility(GONE);
        rootViewBg.animate()
                .alpha(0)
                .setDuration(50)
                .start();
        ivArrowView.setImageDrawable(drawableDown);
        AnimUtils.rotateArrow(ivArrowView, false);
        isDismiss = true;
    }

    /**是否正在展示*/
    public boolean isShowing(){
        return this.getVisibility() == VISIBLE;
    }


    /**配置数据*/
    public void setConfig(PictureSelectionConfig config,OnAlbumItemClickListener listener, ImageView iv) {
        this.config = config;
        chooseMode = config.chooseMode;
        ivArrowView = iv;
        adapter = new PictureAlbumDirectoryAdapter(config);
        adapter.setOnAlbumItemClickListener(listener);
        mRecyclerView.setAdapter(adapter);

        if (config.style != null) {
            if (config.style.pictureTitleUpResId != 0) {
                this.drawableUp = ContextCompat.getDrawable(context, config.style.pictureTitleUpResId);
            }
            if (config.style.pictureTitleDownResId != 0) {
                this.drawableDown = ContextCompat.getDrawable(context, config.style.pictureTitleDownResId);
            }
        } else {
            if (config.isWeChatStyle) {
                this.drawableUp = ContextCompat.getDrawable(context, R.drawable.picture_icon_wechat_up);
                this.drawableDown = ContextCompat.getDrawable(context, R.drawable.picture_icon_wechat_down);
            } else {
                if (config.upResId != 0) {
                    this.drawableUp = ContextCompat.getDrawable(context, config.upResId);
                } else {
                    // 兼容老的Theme方式
                    this.drawableUp = AttrsUtils.getTypeValueDrawable(context, R.attr.picture_arrow_up_icon);
                }
                if (config.downResId != 0) {
                    this.drawableDown = ContextCompat.getDrawable(context, config.downResId);
                } else {
                    // 兼容老的Theme方式 picture.arrow_down.icon
                    this.drawableDown = AttrsUtils.getTypeValueDrawable(context, R.attr.picture_arrow_down_icon);
                }
            }
        }
        this.maxHeight = (int) (ScreenUtils.getScreenHeight(context) * 0.6);

    }

    /**
     * 设置选中状态
     */
    public void updateFolderCheckStatus(List<LocalMedia> result) {
        try {
            List<LocalMediaFolder> folders = adapter.getFolderData();
            int size = folders.size();
            int resultSize = result.size();
            for (int i = 0; i < size; i++) {
                LocalMediaFolder folder = folders.get(i);
                folder.setCheckedNum(0);
                for (int j = 0; j < resultSize; j++) {
                    LocalMedia media = result.get(j);
                    if (folder.getName().equals(media.getParentFolderName())
                            || folder.getBucketId() == -1) {
                        folder.setCheckedNum(1);
                        break;
                    }
                }
            }
            adapter.bindFolderData(folders);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void bindFolder(List<LocalMediaFolder> folders) {
        adapter.setChooseMode(chooseMode);
        adapter.bindFolderData(folders);
        ViewGroup.LayoutParams lp = mRecyclerView.getLayoutParams();
        lp.height = folders != null && folders.size() > 8 ? maxHeight
                : ViewGroup.LayoutParams.WRAP_CONTENT;
    }

    public List<LocalMediaFolder> getFolderData() {
        return adapter.getFolderData();
    }

    public boolean isEmpty() {
        return adapter.getFolderData().size() == 0;
    }

    public LocalMediaFolder getFolder(int position) {
        return adapter.getFolderData().size() > 0
                && position < adapter.getFolderData().size() ? adapter.getFolderData().get(position) : null;
    }
}

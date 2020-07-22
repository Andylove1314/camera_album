package com.custom.camera_album.task;

import android.content.Context;
import android.view.View;
import com.luck.picture.lib.R;
import com.luck.picture.lib.config.PictureSelectionConfig;
import com.zhpan.bannerview.BaseBannerAdapter;


/**
 * 自定义布局，图片
 */
public class ImageAdapter extends BaseBannerAdapter<String, ImageHolder> {

    public ImageAdapter(Context context) {
        con = context;
    }

    private Context con;

    @Override
    protected void onBind(ImageHolder holder, String data, int position, int pageSize) {
        PictureSelectionConfig.imageEngine.loadImage(con,data,holder.imageView);
    }

    @Override
    public ImageHolder createViewHolder(View itemView, int viewType) {
        return new ImageHolder(itemView);
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.task_guide_view_item;
    }
}
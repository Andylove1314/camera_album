package com.custom.camera_album.task;

import android.view.View;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.luck.picture.lib.R;
import com.luck.picture.lib.config.PictureSelectionConfig;
import com.zhpan.bannerview.BaseViewHolder;

import java.util.List;

public class ImageHolder extends BaseViewHolder<List<String>> {
    public ImageView imageView;
    public ImageView playicon;

    public ImageHolder(@NonNull View view) {
        super(view);
        this.imageView = view.findViewById(R.id.banner_image);
        this.playicon = view.findViewById(R.id.banner_image_video_play_icon);
    }

    @Override
    public void bindData(List<String> data, int position, int pageSize) {

    }
}
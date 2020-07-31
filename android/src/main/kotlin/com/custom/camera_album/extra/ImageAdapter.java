package com.custom.camera_album.extra;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.view.View;

import com.luck.picture.lib.PictureVideoPlayActivity;
import com.luck.picture.lib.R;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureSelectionConfig;
import com.zhpan.bannerview.BaseBannerAdapter;

import java.util.List;


/**
 * 自定义布局，图片
 */
public class ImageAdapter extends BaseBannerAdapter<List<String>, ImageHolder> {

    public ImageAdapter(Context context) {
        con = context;
    }

    private Context con;

    @Override
    protected void onBind(ImageHolder holder,List<String>  data, int position, int pageSize) {

        PictureSelectionConfig.imageEngine.loadImage(con,data.get(0),holder.imageView);

        try {
            if (data.size()>1 && isVideo(data.get(1))){
                holder.playicon.setVisibility(View.VISIBLE);
                holder.playicon.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        Intent intent = new Intent(con, PictureVideoPlayActivity.class);
                        intent.putExtra(PictureConfig.EXTRA_VIDEO_PATH, data.get(1));
                        intent.putExtra(PictureConfig.EXTRA_PREVIEW_VIDEO, true);
                        con.startActivity(intent);
                    }
                });
                holder.imageView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        Intent intent = new Intent(con, PictureVideoPlayActivity.class);
                        intent.putExtra(PictureConfig.EXTRA_VIDEO_PATH, data.get(1));
                        intent.putExtra(PictureConfig.EXTRA_PREVIEW_VIDEO, true);
                        con.startActivity(intent);
                    }
                });
            }else {
                holder.playicon.setVisibility(View.GONE);
                holder.playicon.setOnClickListener(null);
                holder.imageView.setOnClickListener(null);
            }
        }catch (Exception e){

        }
    }

    @Override
    public ImageHolder createViewHolder(View itemView, int viewType) {
        return new ImageHolder(itemView);
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.task_guide_view_item;
    }

    /**
     * 视频文件判断
     * @return
     */
    boolean isVideo(String url){

        if (TextUtils.isEmpty(url)){
            return false;
        }

        url = url.toLowerCase();

        if (TextUtils.isEmpty(url)){
            return false;
        }

        return url.contains(".mp4") ||
                url.contains(".avi") ||
                url.contains(".flv") ||
                url.contains(".mpg") ||
                url.contains(".rm") ||
                url.contains(".mov") ||
                url.contains(".wav") ||
                url.contains(".asf") ||
                url.contains(".3gp") ||
                url.contains(".mkv") ||
                url.contains(".rmvb");
    }

}
package com.custom.camera_album.task;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import com.luck.picture.lib.R;
import com.luck.picture.lib.config.PictureSelectionConfig;
import com.youth.banner.adapter.BannerAdapter;

import java.util.List;

/**
 * 自定义布局，图片
 */
public class ImageAdapter extends BannerAdapter<String, ImageHolder> {

    public ImageAdapter(Context context, List<String> mDatas) {
        super(mDatas);
        con = context;
    }

    private Context con;

    //更新数据
    public void updateData(List<String> data) {
        //这里的代码自己发挥，比如如下的写法等等
        mDatas.clear();
        mDatas.addAll(data);
        notifyDataSetChanged();
    }


    //创建ViewHolder，可以用viewType这个字段来区分不同的ViewHolder
    @Override
    public ImageHolder onCreateHolder(ViewGroup parent, int viewType) {

        View view = LayoutInflater.from(con).inflate(R.layout.task_guide_view_item, parent, false);

        return new ImageHolder(view);
    }

    @Override
    public void onBindView(ImageHolder holder, String data, int position, int size) {
        PictureSelectionConfig.imageEngine.loadImage(con,data,holder.imageView);
    }

}
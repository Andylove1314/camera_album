package com.custom.camera_album.task;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;

import com.luck.picture.lib.R;
import com.youth.banner.Banner;
import com.youth.banner.indicator.CircleIndicator;

import java.util.ArrayList;
import java.util.List;

/**任务引导*/
public class GuideView extends LinearLayout {

    private Banner taskBanner;
    private LinearLayout guideClose;
    private ImageAdapter adapter;
    private List<String> arr = new ArrayList<>();

    public GuideView(Context context) {
        this(context,null);
    }

    ///刷新数据
    public void setArr(List<String> data) {
        this.arr = data;
        adapter.updateData(arr);
    }

    public GuideView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        LayoutInflater.from(context).inflate(R.layout.task_guide_view_layout, this);
        /// banner
        adapter = new ImageAdapter(context,arr);
        taskBanner = findViewById(R.id.task_guide_banner);
        taskBanner.setAdapter(adapter).setIndicator(new CircleIndicator(context)).setStartPosition(0);

        ///close
        guideClose = findViewById(R.id.task_guide_tip_icon_close);
        guideClose.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                setVisibility(View.GONE);
            }
        });

    }

    public GuideView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public GuideView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }
}

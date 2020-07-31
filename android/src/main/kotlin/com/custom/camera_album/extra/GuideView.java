package com.custom.camera_album.extra;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;
import androidx.viewpager2.widget.ViewPager2;

import com.luck.picture.lib.R;
import com.zhpan.bannerview.BannerViewPager;
import com.zhpan.indicator.enums.IndicatorStyle;

import java.util.List;

/**任务引导*/
public class GuideView extends LinearLayout {

    private BannerViewPager mViewPager;
    private LinearLayout guideClose;
    private ImageAdapter adapter;

    public GuideView(Context context) {
        this(context,null);
    }

    ///刷新数据
    public void setArr(List<List<String>> data) {
        mViewPager
                .setIndicatorStyle(IndicatorStyle.ROUND_RECT)
                .setOrientation(ViewPager2.ORIENTATION_HORIZONTAL)
                .setPageMargin(50)
                .setIndicatorSliderWidth(20)
                .setIndicatorHeight(20)
                .setAdapter(adapter).create(data);
    }

    public GuideView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        LayoutInflater.from(context).inflate(R.layout.task_guide_view_layout, this);
        /// banner
        adapter = new ImageAdapter(context);
        mViewPager = findViewById(R.id.task_guide_banner);

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

package com.calebgomer.roadkill_reporter;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.ImageView;

public class TouchlessImageView extends ImageView {
  public TouchlessImageView(Context context) {
    super(context);
  }

  public TouchlessImageView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public TouchlessImageView(Context context, AttributeSet attrs, int defStyle) {
    super(context, attrs, defStyle);
  }

  @Override
  public boolean onTouchEvent(MotionEvent event) {
    return false;
  }
}

package com.calebgomer.roadkill_reporter;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;

public class RefineLocationMapActivity extends MapActivity {

  public static final int REFINE_LOCATION = 1;
  public static final int LOCATION_REFINE_CONFIRMED = 2;
  public static final int LOCATION_REFINE_CANCELED = 3;

  MapView map;
  MapController mapController;

  ImageView pinImage;

  Button confirmButton;
  Button cancelButton;

  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    requestWindowFeature(Window.FEATURE_NO_TITLE);

    setContentView(R.layout.map);

    map = (MapView) findViewById(R.id.map);
    map.setBuiltInZoomControls(false);
    map.setSatellite(true);

    mapController = map.getController();

    float lat = getIntent().getFloatExtra("lat",0);
    float lon = getIntent().getFloatExtra("lon",0);
    GeoPoint reportLocation = new GeoPoint((int)(lat * 1E6), (int)(lon * 1E6));
    mapController.setCenter(reportLocation);
    mapController.setZoom(map.getMaxZoomLevel());

    pinImage = (ImageView) findViewById(R.id.img_reporter_pin);
    pinImage.setOnClickListener(reporterButtonListener);

    confirmButton = (Button) findViewById(R.id.btn_confirm);
    confirmButton.setOnClickListener(reporterButtonListener);
    cancelButton = (Button) findViewById(R.id.btn_cancel);
    cancelButton.setOnClickListener(reporterButtonListener);
  }

  @Override
  protected boolean isRouteDisplayed() {
    return false;
  }

  View.OnClickListener reporterButtonListener = new View.OnClickListener() {
    @Override
    public void onClick(View view) {
      if (view.equals(confirmButton)) {
        GeoPoint mapCenter = map.getProjection().fromPixels(
            map.getWidth() / 2,
            map.getHeight() / 2);
        float lat = ((float)mapCenter.getLatitudeE6())/ (float)1E6;
        float lon = ((float)mapCenter.getLongitudeE6())/ (float)1E6;

        Intent data = getIntent();
        data.putExtra("lat", lat);
        data.putExtra("lon", lon);

        setResult(LOCATION_REFINE_CONFIRMED, data);
        finish();

      } else if (view.equals(cancelButton)) {
        setResult(LOCATION_REFINE_CANCELED);
        finish();
      }
    }
  };
}
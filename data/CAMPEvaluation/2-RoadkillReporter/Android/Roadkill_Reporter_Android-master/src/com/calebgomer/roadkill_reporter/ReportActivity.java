package com.calebgomer.roadkill_reporter;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.Window;
import android.widget.*;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

public class ReportActivity extends Activity implements LocationListener, View.OnClickListener, AsyncReporter.AsyncCallbackListener {

  private Context mContext;

  private LocationManager locationManager;
  private Location userLocation;
  private boolean located;
  private boolean gpsEnabled;
  private boolean networkEnabled;

  private ImageButton raccoonButton;
  private ProgressBar reportProgress;
  private TextView locationView;

  @Override
  public void onCreate(Bundle savedInstanceState) {

    super.onCreate(savedInstanceState);

    requestWindowFeature(Window.FEATURE_NO_TITLE);

    mContext = this;
    setContentView(R.layout.report);

    final ImageButton iv = (ImageButton) findViewById(R.id.btn_report_raccoon);
    ViewTreeObserver vto = iv.getViewTreeObserver();

    //gets screen dimensions
    final DisplayMetrics metrics = new DisplayMetrics();
    getWindowManager().getDefaultDisplay().getMetrics(metrics);

    //this happens before the layout is visible
    vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
      @Override
      public void onGlobalLayout() {
        int newWidth, newHeight, oldHeight, oldWidth;

        //the new width will fit the screen
        newWidth = metrics.widthPixels;
        newWidth = (int) (((float) newWidth) * 0.95); //don't fill the entire screen, just most of it

        //so we can scale proportionally
        oldHeight = iv.getBackground().getIntrinsicHeight();
        oldWidth = iv.getBackground().getIntrinsicWidth();
        newHeight = (int) Math.floor((oldHeight * newWidth) / oldWidth);
        iv.setLayoutParams(new FrameLayout.LayoutParams(newWidth, newHeight, Gravity.CENTER));

        //so this only happens once
        iv.getViewTreeObserver().removeGlobalOnLayoutListener(this);
      }
    });

    raccoonButton = (ImageButton) findViewById(R.id.btn_report_raccoon);
    raccoonButton.setOnClickListener(this);
    reportProgress = (ProgressBar) findViewById(R.id.pgrs_reporting);

    gpsEnabled = true;
    networkEnabled = true;

    locationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);
    locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 1000, 1, this);
    locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 500, 1, this);

    AsyncReporter.wakeUpServer(this, this);
  }

  public void onStart() {
    super.onStart();
  }

  @Override
  public void onResume() {
    super.onResume();
  }

  @Override
  public void onPause() {
    super.onPause();
  }

  public void onStop() {
    super.onStop();
  }

  @Override
  protected void onDestroy() {
    locationManager.removeUpdates(this);
    mContext = null;
    super.onDestroy();
  }

  public boolean isPaused() {
    return mContext == null;
  }


  /**
   * ***************************
   * Handle button presses
   * ****************************
   */
  @Override
  public void onClick(View view) {

    //confirm reports before sending to the server
    if (view.equals(raccoonButton)) {
      if (located)
        showDialog("Confirm Roadkill", "There's a dead raccoon right here?", true, this);
      else
        showDialog("Location Problem", "We can't find your location. Please make sure you have GPS and Wifi location enabled and try again.", this);
    }
  }

  /**
   * ***************************
   * Report a raccoon to the server
   * ****************************
   */
  private void reportRaccoon() {
    raccoonButton.setEnabled(false);
    reportProgress.setVisibility(View.VISIBLE);
    HashMap<String, String> requestParams = new HashMap<String, String>(7);
    requestParams.put(AsyncReporter.PARAM_LATITUDE, Double.toString(userLocation.getLatitude()));
    requestParams.put(AsyncReporter.PARAM_LONGITUDE, Double.toString(userLocation.getLongitude()));
    requestParams.put(AsyncReporter.PARAM_ACCURACY, Float.toString(userLocation.getAccuracy()));
    requestParams.put(AsyncReporter.PARAM_AGE, Integer.toString(1));
    requestParams.put(AsyncReporter.PARAM_DESCRIPTION, "raccoon");
    requestParams.put(AsyncReporter.PARAM_TESTING, "n");
    AsyncReporter.Payload request = new AsyncReporter.Payload(AsyncReporter.REPORT_RACCOON, requestParams, this, this);
    AsyncReporter.perform(request);
  }

  /**
   * ***************************
   * Handle responses from the server
   * ****************************
   */
  public void asyncDone(AsyncReporter.Payload payload) {

    if (payload.exception == null) {

      JSONObject response = null;

      try {

        response = new JSONObject(payload.result);

        switch (payload.taskType) {

          case AsyncReporter.REPORT_RACCOON:
            String title = response.getString("status");
            String subtitle = "Your report was saved successfully.\nThanks!!";
            showDialog(title, subtitle, this);
            break;

          case AsyncReporter.WAKE_UP_SERVER:
            boolean online = response.getString("status").equals("online");
            boolean newUser = response.getString("user").equals("new");
            if (online) {
              //yay we're online!
              if (newUser) {
                showDialog("Welcome!", "Thank you for helping with our research!\nYour contributions will be greatly appreciated.", this);
              }
            }
            break;

          case AsyncReporter.GET_PAST_REPORTS:
            showDialog("Past Stuff", response.getString("info").toString(), this);
            break;
        }

      } catch (JSONException e) {
        if (networkEnabled) {
          showDialog("Something's not right...", "If you're using a public wifi hotspot please make sure you're logged in and try again.", this);
        }
      } catch (Exception e) {
        showDialog("Woah!", "Something went terribly wrong. Please try that again.", this);
      }
    } else {
      showDialog("Sorry, we're having trouble reporting this animal...", payload.exception.getMessage(), this);
    }
    raccoonButton.setEnabled(true);
    reportProgress.setVisibility(View.GONE);
  }

  public void toast(String message) {
    Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
  }

  public void showDialog(String title, String info, Context context) {
    showDialog(title, info, false, context);
  }

  public void showDialog(String title, String info, boolean yesNoDialog, Context context) {
    AlertDialog.Builder builder;
    builder = new AlertDialog.Builder(context);
    builder.setTitle(title);
    builder.setMessage(info);
    if (yesNoDialog) {
      builder.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int i) {
          dialog.dismiss();
          reportRaccoon();
        }
      });
      builder.setNegativeButton("No", new DialogInterface.OnClickListener() {
        public void onClick(DialogInterface dialog, int i) {
          dialog.dismiss();
        }
      });
    } else {
      builder.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int i) {
          dialog.dismiss();
        }
      });
    }

    AlertDialog dialog = builder.create();
    dialog.show();
  }

  @Override
  public void onLocationChanged(Location location) {
    if (location != null) {
      userLocation = location;
      located = true;
    }
  }

  @Override
  public void onStatusChanged(String s, int i, Bundle bundle) {

  }

  @Override
  public void onProviderEnabled(String s) {
    if (s.equals("gps")) {
      toast("GPS location is enabled, thanks!");
      gpsEnabled = true;
    } else if (s.equals("network")) {
      toast("Wifi location is enabled, thanks!");
      networkEnabled = true;
    }
  }

  @Override
  public void onProviderDisabled(String s) {

    if (s.equals("gps") && gpsEnabled) {
      gpsEnabled = false;
      showDialog(
          "Location Accuracy Problem",
          "You don't have GPS location enabled. Report accuracy will be better if you turn it on!",
          this);
    } else if (s.equals("network") && networkEnabled) {
      networkEnabled = false;
      showDialog(
          "Location Accuracy Problem",
          "You don't have Wifi location enabled. Report accuracy will be better if you turn it on!",
          this);
    }

    if (!gpsEnabled && !networkEnabled) {
      located = false;
    }
  }
}

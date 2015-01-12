package com.calebgomer.roadkill_reporter;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;
import com.calebgomer.roadkill_reporter.data_types.RoadkillReport;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;

public class ViewReportsActivity extends Activity implements AsyncReporter.AsyncCallbackListener {

  private Context mContext;
  private ListView reportListView;
  private RoadkillReportArrayAdapter reportListAdapter;
  private ArrayList<RoadkillReport> reportList;

  private DecimalFormat decFormat = new DecimalFormat("#.#");

  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    requestWindowFeature(Window.FEATURE_NO_TITLE);

    setContentView(R.layout.view_reports);

    mContext = this;

    reportListView = (ListView) findViewById(R.id.report_list);

    reportList = new ArrayList<RoadkillReport>();

    reportListAdapter = new RoadkillReportArrayAdapter(this, reportList);

    reportListView.setAdapter(reportListAdapter);

    reportListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
      @Override
      public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
        Intent mapIntent = new Intent(getApplicationContext(), RefineLocationMapActivity.class);
        mapIntent.putExtra("reportId", reportListAdapter.getItem(i).reportId);
        mapIntent.putExtra("lat", reportListAdapter.getItem(i).latitude);
        mapIntent.putExtra("lon", reportListAdapter.getItem(i).longitude);
        startActivityForResult(mapIntent, RefineLocationMapActivity.REFINE_LOCATION);
      }
    });

    reportListView.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
      @Override
      public boolean onItemLongClick(AdapterView<?> adapterView, View view, int i, long l) {
        showDeleteDialog(reportListAdapter.getItem(i).reportId, mContext);
        return false;
      }
    });
  }

  public void onResume() {
    super.onResume();

    refreshReports();
  }

  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode != RefineLocationMapActivity.REFINE_LOCATION)
      return;

    if (resultCode == RefineLocationMapActivity.LOCATION_REFINE_CONFIRMED) {

      HashMap<String, String> requestParams = new HashMap<String, String>(3);
      requestParams.put(AsyncReporter.PARAM_REPORT_ID, Integer.toString(data.getIntExtra("reportId", -1)));
      requestParams.put(AsyncReporter.PARAM_LATITUDE, Float.toString(data.getFloatExtra("lat", 0)));
      requestParams.put(AsyncReporter.PARAM_LONGITUDE, Float.toString(data.getFloatExtra("lon", 0)));
      AsyncReporter.Payload request = new AsyncReporter.Payload(AsyncReporter.UPDATE_REPORT, requestParams, this, this);
      AsyncReporter.perform(request);

    } else if (resultCode == RefineLocationMapActivity.LOCATION_REFINE_CANCELED) {

    }
  }

  @Override
  public void asyncDone(AsyncReporter.Payload payload) {

    if (payload.exception == null) {
      JSONObject response = null;
      try {
        response = new JSONObject(payload.result);
        switch (payload.taskType) {

          case AsyncReporter.GET_PAST_REPORTS:

            String title = response.getString("status");
            JSONArray reports = response.getJSONObject("info").getJSONArray("rows");
            int numReports = response.getJSONObject("info").getInt("rowCount");
            showReports(reports, numReports);
            break;

          case AsyncReporter.DELETE_REPORT:

            String status = response.getString("status");
            String info = response.getString("info");

            if (status.equals("Deleted")) {
              refreshReports();
            } else if (!info.equals("")) {
              showDialog("Problem Deleting Report", info, this);
            }
            break;
        }
      } catch (JSONException e) {
        showDialog("Bad JSON from server", payload.result, this);
      }
    } else {
      showDialog("Sorry, we're having trouble finding the roadkill...", payload.exception.getMessage(), this);
    }
  }

  private void showReports(JSONArray reports, int numReports) {
    try {

      boolean unrefinedReport = false;

      reportListAdapter.clear();

      for (int i = 0; i < numReports; i++) {

        JSONObject report = reports.getJSONObject(i);
        reportListAdapter.add(new RoadkillReport(report));

        if (!unrefinedReport) {
          boolean loc_updated = Boolean.parseBoolean(report.getString("loc_updated"));
          if (!loc_updated)
            unrefinedReport = true;
        }
      }

      if (unrefinedReport)
        (findViewById(R.id.lyt_refine_report)).setVisibility(View.VISIBLE);
      else
        (findViewById(R.id.lyt_refine_report)).setVisibility(View.GONE);

    } catch (JSONException je) {
      je.printStackTrace();
    }
  }

  private void refreshReports() {
    boolean testing = getIntent().getBooleanExtra("testing", false);

    HashMap<String, String> requestParams = new HashMap<String, String>(7);
    requestParams.put(AsyncReporter.PARAM_ACCURACY, Float.toString(250));
    requestParams.put(AsyncReporter.PARAM_DISTANCE, Float.toString(50000));
    requestParams.put(AsyncReporter.PARAM_TESTING, testing ? "y" : "n");
    AsyncReporter.Payload request = new AsyncReporter.Payload(AsyncReporter.GET_PAST_REPORTS, requestParams, this, this);
    AsyncReporter.perform(request);
  }

  @Override
  protected void onDestroy() {
    mContext = null;
    super.onDestroy();
  }

  public boolean isPaused() {
    return mContext == null;
  }

  public void deleteReport(int reportId) {
    HashMap<String, String> requestParams = new HashMap<String, String>(1);
    requestParams.put(AsyncReporter.PARAM_REPORT_ID, Integer.toString(reportId));
    AsyncReporter.Payload request = new AsyncReporter.Payload(AsyncReporter.DELETE_REPORT, requestParams, this, this);
    AsyncReporter.perform(request);
  }

  public void showDeleteDialog(final int reportId, Context context) {
    AlertDialog.Builder builder;
    builder = new AlertDialog.Builder(context);
    builder.setTitle("Delete This Report?");
//    builder.setMessage(info);
    builder.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
      @Override
      public void onClick(DialogInterface dialog, int i) {
        dialog.dismiss();
        deleteReport(reportId);
      }
    });
    builder.setNegativeButton("No", new DialogInterface.OnClickListener() {
      public void onClick(DialogInterface dialog, int i) {
        dialog.dismiss();
      }
    });
    AlertDialog dialog = builder.create();
    dialog.show();
  }

  public void showDialog(String title, String info, Context context) {
    AlertDialog.Builder builder;
    AlertDialog alertDialog;
    LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
    View layout = inflater.inflate(R.layout.text_dialog, (ViewGroup) findViewById(R.id.layout_root));
    TextView text = (TextView) layout.findViewById(R.id.text_level);
    text.setText(info);
    builder = new AlertDialog.Builder(context);
    builder.setView(layout);
    alertDialog = builder.create();
    alertDialog.setTitle(title);
    alertDialog.show();
  }
}
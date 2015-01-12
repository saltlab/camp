package com.calebgomer.roadkill_reporter.data_types;

import android.util.Log;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.GregorianCalendar;

public class RoadkillReport implements Comparable<RoadkillReport> {
  public int reportId;
  public String animalName;
  public float latitude;
  public float longitude;
  public boolean locationRefined;
  public GregorianCalendar dateReported;

  public RoadkillReport(int reportId, String animalName, float latitude, float longitude, boolean locationRefined, GregorianCalendar dateReported) {
    this.reportId = reportId;
    this.animalName = animalName;
    this.latitude = latitude;
    this.longitude = longitude;
    this.locationRefined = locationRefined;
    this.dateReported = dateReported;
  }

  public RoadkillReport(JSONObject report) {
    try {

      this.reportId = Integer.parseInt(report.getString("report_id"));
      this.animalName = "Raccoon";
      this.latitude = Float.parseFloat(report.getString("lat"));
      this.longitude = Float.parseFloat(report.getString("lon"));

      float accuracy = Float.parseFloat(report.getString("accuracy"));
      boolean locationRefined = Boolean.parseBoolean(report.getString("loc_updated"));
      //if the original accuracy is within 10 meters, the user does not need to refine the location
      Log.d("RR", "accuracy: "+accuracy+" refined: "+locationRefined);
      this.locationRefined = accuracy <= 10 || locationRefined;

      SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
      Date date = formatter.parse(report.getString("time").substring(0, 24));
      this.dateReported = new GregorianCalendar();
      this.dateReported.setTime(date);

    }
    catch (JSONException je) {
      je.printStackTrace();
    }
    catch (ParseException pe) {
      pe.printStackTrace();
    }
  }

  public RoadkillReport() {
    this.reportId = 0;
    this.animalName = "Raccoon";
    this.latitude = 0;
    this.longitude = 0;
    this.locationRefined = false;
    this.dateReported = new GregorianCalendar();
  }

  public int getReportId() {
    return reportId;
  }

  public void setReportId(int reportId) {
    this.reportId = reportId;
  }

  public String getAnimalName() {
    return animalName;
  }

  public void setAnimalName(String animalName) {
    this.animalName = animalName;
  }

  public float getLatitude() {
    return latitude;
  }

  public void setLatitude(float latitude) {
    this.latitude = latitude;
  }

  public float getLongitude() {
    return longitude;
  }

  public void setLongitude(float longitude) {
    this.longitude = longitude;
  }

  public boolean isLocationRefined() {
    return locationRefined;
  }

  public void setLocationRefined(boolean locationRefined) {
    this.locationRefined = locationRefined;
  }

  public GregorianCalendar getDateReported() {
    return dateReported;
  }

  public void setDateReported(GregorianCalendar dateReported) {
    this.dateReported = dateReported;
  }

  public String getAgeText() {
    GregorianCalendar now = new GregorianCalendar();
    long differenceInTime = now.getTime().getTime() - dateReported.getTime().getTime();
    long differenceInDays = differenceInTime / (1000 * 60 * 60 * 24);

    String ageText = "";

    if (differenceInDays == 0) {
      ageText = "Today";
    } else if (differenceInDays == 1) {
      ageText = "Yesterday";
    } else if (differenceInDays <= 7) {
      ageText = (differenceInDays) + " days ago";
    } else if (differenceInDays <= 30) {
      ageText = (differenceInDays/7) + " week"+((differenceInDays/7)>1?"s":"")+" ago";
    } else {
      ageText = (differenceInDays/30) + " month"+((differenceInDays/30)>1?"s":"")+" ago";
    }

    return ageText;
  }

  @Override
  public int compareTo(RoadkillReport roadkillReport) {
    return this.dateReported.compareTo(roadkillReport.dateReported);
  }
}

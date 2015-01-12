package com.calebgomer.roadkill_reporter;

/*
 * Copyright (C) 2009 
 * Jayesh Salvi <jayesh@altcanvas.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * 
 * 
 * 
 * This file has been modified by Caleb Gomer
 */

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.preference.PreferenceManager;
import android.util.Log;
import org.apache.http.*;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.protocol.HTTP;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.HashMap;


public class AsyncReporter extends AsyncTask<AsyncReporter.Payload, Object, AsyncReporter.Payload> {
  public static final String TAG = "AsyncReporter";

  //tasks
  public static final int WAKE_UP_SERVER = 0;
  public static final int REPORT_RACCOON = 1;
  public static final int GET_PAST_REPORTS = 2;
  public static final int UPDATE_REPORT = 3;
  public static final int DELETE_REPORT = 4;

  //parameters
  public static final String PARAM_REPORT_ID = "repordId";
  public static final String PARAM_ACCURACY = "accuracy";
  public static final String PARAM_LATITUDE = "latitude";
  public static final String PARAM_LONGITUDE = "longitude";
  public static final String PARAM_DISTANCE = "distance";
  public static final String PARAM_AGE = "age";
  public static final String PARAM_DESCRIPTION = "description";
  public static final String PARAM_TESTING = "testing";

  //urls
  public static final String WAKE_UP_URL = "http://roadkill-reporter.herokuapp.com/helloworld";
  public static final String NEW_ID_URL = "http://roadkill-reporter.herokuapp.com/newid";
  public static final String REPORT_RACCOON_URL = "http://roadkill-reporter.herokuapp.com/report";
  public static final String REPORT_RACCOON_URL_TEST = "http://192.168.1.102:5000/report";
  public static final String GET_PAST_REPORTS_URL = "http://roadkill-reporter.herokuapp.com/reports/user/%s";
  public static final String GET_PAST_REPORTS_URL_TEST = "http://192.168.1.102:5000/reports/user/%s";
  public static final String UPDATE_REPORT_URL = "http://roadkill-reporter.herokuapp.com/update_loc/%s/%s/%s/%s";//reportNumber, location.latitude, location.longitude,userId
  public static final String UPDATE_REPORT_URL_TEST = "http://192.168.1.102:5000/update_loc/%s/%s/%s/%s";//reportNumber, location.latitude, location.longitude,userId
  public static final String DELETE_REPORT_URL = "http://roadkill-reporter.herokuapp.com/delete/%s/%s";//,reportNumber,userId
  public static final String DELETE_REPORT_URL_TEST = "http://192.168.1.102:5000/delete/%s/%s";//,reportNumber,userId
  /**
   * various other strings
   */
  //expected server response prefix for JSON data
  public static final String ROADKILL_RESPONSE_PREFIX = "RoadkillReporterData:";
  //key for userid shared preference value
  public static final String USERID = "userid";


  //shortcut static method for creating new AsyncReporters and executing a request
  public static void perform(Payload request) {
    new AsyncReporter().execute(request);
  }

  //shortcut static method for waking up the server
  //this improves roadkill report time later on if the server was sleeping
  public static void wakeUpServer(AsyncCallbackListener callback, Context context) {
    Log.v(TAG, "waking server");
    AsyncReporter.Payload request = new AsyncReporter.Payload(AsyncReporter.WAKE_UP_SERVER, null, callback, context);
    AsyncReporter.perform(request);
  }

  /*
  * Runs on GUI thread
  */
  @Override
  protected void onPreExecute() {
    Log.i(TAG, "*******GOING*****");
  }

  /*
  * Runs on GUI thread
  */
  @Override
  public void onPostExecute(AsyncReporter.Payload payload) {
    if (payload.result == null && payload.exception == null)
      payload.exception = new AsyncException("Unknown Error");

    if (payload.callback.isPaused())
      Log.e(TAG, "Activity killed before response could be returned");
    else
      payload.callback.asyncDone(payload);
  }


  /*
  * Runs on background thread
  */
  @Override
  public AsyncReporter.Payload doInBackground(AsyncReporter.Payload... _params) {
    Log.d(TAG, "*******BACKGROUND********");

    AsyncReporter.Payload payload = _params[0];

    //stop now if there is no internet connection
    if (!isOnline(payload.context.getApplicationContext())) {
      payload.exception = new AsyncException("No Internet Connection");
      return payload;
    }

    //skip the rest if we're trying to wake up the server
    if (payload.taskType == WAKE_UP_SERVER) {
      payload.result = wakeServer(payload.context);
      return payload;
    }

    String userid = getUserid(payload.context);
    if (userid == null) {
      payload.exception = new AsyncException("We're having some strange errors, please try that again.");
      return payload;
    }

    payload.result = "";
    HashMap<String, String> params = payload.params;
    String reportId = params.get(PARAM_REPORT_ID);
    String lat = params.get(PARAM_LATITUDE);
    String lon = params.get(PARAM_LONGITUDE);
    String distance = params.get(PARAM_DISTANCE);
    String accuracy = params.get(PARAM_ACCURACY);
    String age = params.get(PARAM_AGE);
    String description = params.get(PARAM_DESCRIPTION);
    String isTesting = params.get(PARAM_TESTING);
    boolean testing = isTesting != null && isTesting.equals("y");

    boolean valid = false;

    switch (payload.taskType) {

      case REPORT_RACCOON:
        valid = lat != null && lon != null && accuracy != null && age != null;

        if (valid)
          payload.result = reportRaccoon(lat, lon, accuracy, age, userid, description, testing);
        else
          payload.exception = new AsyncException("Can't create that report");
        break;

      case GET_PAST_REPORTS:
        payload.result = getPastReports(userid);
        break;

      case UPDATE_REPORT:
        valid = lat != null && lon != null && reportId != null;
        if (valid)
          payload.result = updateReport(reportId, lat, lon, userid);
        else
          payload.exception = new AsyncException("Can't update that report");
        break;

      case DELETE_REPORT:
        valid = userid != null && reportId != null;
        if (valid)
          payload.result = deleteReport(reportId, userid);
        else
          payload.exception = new AsyncException("Can't delete that report");
        break;

      default:
        payload.exception = new AsyncException("[" + payload.taskType + "] is not a valid task ID");
        break;
    }


    return payload;
  }

  public static class Payload {
    public int taskType;
    public AsyncCallbackListener callback;
    public Context context;
    public HashMap<String, String> params;
    public String result;
    public Exception exception;

    public Payload(int taskType, HashMap<String, String> params, AsyncCallbackListener callback, Context context) {
      this.taskType = taskType;
      this.callback = callback;
      this.params = params;
      this.context = context;
    }

    public String errorString() {
      return this.exception.getMessage() + " [ID-" + this.taskType + "-T]";
    }
  }

  public String wakeServer(Context contextForUserid) {
    try {
      JSONObject wakeUpResponse = new JSONObject(get(WAKE_UP_URL));
      String world = wakeUpResponse.getString("hello");
      if (world.equals("world")) {
        //server is awake and functioning!
        if (isNewUser(contextForUserid)) {
          String userid = getUserid(contextForUserid);
          if (userid == null) {
            return "{\"status\":\"online\", \"user\":\"none\"}";
          } else {
            return "{\"status\":\"online\", \"user\":\"new\"}";
          }
        } else {
          return "{\"status\":\"online\", \"user\":\"existing\"}";
        }
      }
    } catch (JSONException e) {
      //woah there buddy
      Log.e(TAG, "Bad JSON while requesting new userid");
    }
    return "{\"status\":\"offline\", \"user\":\"\"}";
  }

  public String getUserid(Context contextForUserid) {
    String userid = PreferenceManager.getDefaultSharedPreferences(contextForUserid).getString(USERID, null);
    if (userid == null) {
      userid = getNewUserid();
      if (userid != null) {
        PreferenceManager.getDefaultSharedPreferences(contextForUserid).edit().putString(USERID, userid).commit();
      }
    }
    return userid;
  }

  public boolean isNewUser(Context contextForUserid) {
    return (null == PreferenceManager.getDefaultSharedPreferences(contextForUserid).getString(USERID, null));
  }

  public String getNewUserid() {
    Log.d(TAG, "requesting new userid");
    String userid = null;
    try {
      JSONObject newIdResponse = new JSONObject(get(NEW_ID_URL));
      String status = newIdResponse.getString("status");
      String uuid = newIdResponse.getString(("uuid"));
      if (status.equals(("UUID")) && uuid != null) {
        userid = uuid;
      }
    } catch (JSONException e) {
      //wow, server glitch. oops.
      Log.e(TAG, "Bad JSON while requesting new userid");
      userid = null;
    }
    return userid;
  }

  public String reportRaccoon(String lat, String lon, String accuracy, String age, String username, String description, boolean testing) {
    String command = "/" + lat + "/" + lon + "/" + accuracy + "/" + age + "/" +
        (username == null ? "" : username) + "/" + (description == null ? "" : description);
    command = (testing ? REPORT_RACCOON_URL_TEST : REPORT_RACCOON_URL) + command;

    Log.d(TAG, command);
    return post(command);
  }

  public String getPastReports(String userid) {
    String command = String.format(GET_PAST_REPORTS_URL, userid);
    Log.d(TAG, command);
    return get(command);
  }

  public String updateReport(String reportId, String lat, String lon, String userid) {
    String command = String.format(UPDATE_REPORT_URL, reportId, lat, lon, userid);
    Log.d(TAG, command);
    return post(command);
  }

  public String deleteReport(String reportId, String userid) {
    String command = String.format(DELETE_REPORT_URL, reportId, userid);
    Log.d(TAG, command);
    return get(command);
  }

  public boolean isOnline(Context mainContext) {
    ConnectivityManager cm = (ConnectivityManager) mainContext.getSystemService(Context.CONNECTIVITY_SERVICE);
    NetworkInfo info = cm.getActiveNetworkInfo();
    return (info != null && info.isConnected());
  }


  private static String post(String command) {
    return getJSON(new HttpPost(command));
  }

  private static String get(String command) {
    return getJSON(new HttpGet(command));
  }

  private static String getJSON(HttpUriRequest request) {

    HttpClient client = new DefaultHttpClient();
//    HttpPost post = new HttpPost(command);
    HttpResponse response;
    try {
      response = client.execute(request);
    } catch (ClientProtocolException e2) {
      e2.printStackTrace();
      return "Connection Failed (Client)";
    } catch (IOException e2) {
      e2.printStackTrace();
      return "Connection Failed (I/O)";
    }
    String response_text = null;
    HttpEntity entity = null;
    try {
      entity = response.getEntity();
      response_text = _getResponseBody(entity);
    } catch (ParseException e) {
      e.printStackTrace();
    } catch (IOException e) {
      if (entity != null) {
        try {
          entity.consumeContent();
        } catch (IOException e1) {
        }
      }
    }
    return valid(response_text);
  }

  private static String _getResponseBody(final HttpEntity entity) throws IOException, ParseException {
    if (entity == null) {
      throw new IllegalArgumentException("HTTP entity may not be null");
    }
    InputStream instream = entity.getContent();
    if (instream == null) {
      return "";
    }
    if (entity.getContentLength() > Integer.MAX_VALUE) {
      throw new IllegalArgumentException("HTTP entity too large to be buffered in memory");
    }
    String charset = getContentCharSet(entity);
    if (charset == null) {
      charset = HTTP.DEFAULT_CONTENT_CHARSET;
    }
    Reader reader = new InputStreamReader(instream, charset);
    StringBuilder buffer = new StringBuilder();
    try {
      char[] tmp = new char[1024];
      int l;
      while ((l = reader.read(tmp)) != -1) {
        buffer.append(tmp, 0, l);
      }
    } finally {
      reader.close();
    }
    return buffer.toString();
  }

  private static String getContentCharSet(final HttpEntity entity) throws ParseException {
    if (entity == null) {
      throw new IllegalArgumentException("HTTP entity may not be null");
    }
    String charset = null;
    if (entity.getContentType() != null) {
      HeaderElement values[] = entity.getContentType().getElements();
      if (values.length > 0) {
        NameValuePair param = values[0].getParameterByName("charset");
        if (param != null) {
          charset = param.getValue();
        }
      }
    }
    return charset;
  }

  /**
   * makes sure the server's response is valid before returning it
   */
  private static String valid(String response) {
    if (response.length() >= 21 && response.substring(0, 21).equals(ROADKILL_RESPONSE_PREFIX)) {
      return response.substring(21);
    } else {
      Log.d(TAG, "response: '" + response + "' *****NOT VALID*****");
      return "error";
    }
  }


  public interface AsyncCallbackListener {
    public void asyncDone(AsyncReporter.Payload response);

    public Context getApplicationContext();

    public boolean isPaused();
  }


  private class AsyncException extends Exception {

    public String msg = null;

    public AsyncException(String msg) {
      super(msg);
      this.msg = msg;
    }

    @Override
    public String toString() {
      return msg;
    }
  }

}

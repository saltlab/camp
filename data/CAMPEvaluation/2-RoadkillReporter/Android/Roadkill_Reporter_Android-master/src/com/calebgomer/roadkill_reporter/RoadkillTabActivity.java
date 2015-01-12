package com.calebgomer.roadkill_reporter;

import android.app.TabActivity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Window;
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;

public class RoadkillTabActivity extends TabActivity {

  TabHost mTabHost;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    requestWindowFeature(Window.FEATURE_NO_TITLE);
    setContentView(R.layout.tabs);

    mTabHost = getTabHost();

    //Add the Report tab
    TabSpec reportSpec = mTabHost.newTabSpec(getString(R.string.report));
    reportSpec.setIndicator(getString(R.string.report));
    Intent reportIntent = new Intent(this, ReportActivity.class);
    reportSpec.setContent(reportIntent);
    mTabHost.addTab(reportSpec);

    //Add the Past Reports tab
    TabSpec pastReportsSpec = mTabHost.newTabSpec(getString(R.string.past_reports));
    pastReportsSpec.setIndicator(getString(R.string.past_reports));
    Intent pastReportsIntent = new Intent(this, ViewReportsActivity.class);
    pastReportsSpec.setContent(pastReportsIntent);
    mTabHost.addTab(pastReportsSpec);

    //Add the About tab
    TabSpec aboutSpec = mTabHost.newTabSpec(getString(R.string.about));
    aboutSpec.setIndicator(getString(R.string.about));
    Intent aboutIntent = new Intent(this, AboutActivity.class);
    aboutSpec.setContent(aboutIntent);
    mTabHost.addTab(aboutSpec);

  }
}
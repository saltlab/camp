package com.calebgomer.roadkill_reporter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import com.calebgomer.roadkill_reporter.data_types.RoadkillReport;

import java.util.ArrayList;

public class RoadkillReportArrayAdapter extends ArrayAdapter<RoadkillReport> {
  private final Context context;
  private final ArrayList<RoadkillReport> values;

  public RoadkillReportArrayAdapter(Context context, ArrayList<RoadkillReport> values) {
    super(context, R.layout.report_table_row, values);
    this.context = context;
    this.values = values;
  }

  @Override
  public View getView(int position, View convertView, ViewGroup parent) {
    LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

    View rowView = inflater.inflate(R.layout.report_table_row, parent, false);
    TextView animalName = (TextView) rowView.findViewById(R.id.txt_animal_name);
    TextView reportAge = (TextView) rowView.findViewById(R.id.txt_report_age);
    ImageView needsRefinement = (ImageView) rowView.findViewById(R.id.img_needs_refinement);

    animalName.setText(values.get(position).animalName);
    reportAge.setText(values.get(position).getAgeText());

    if (values.get(position).locationRefined) {
      needsRefinement.setVisibility(View.GONE);
    }

    return rowView;
  }
}

package com.schlauefuechse.need2pee.model;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;


import com.schlauefuechse.need2pee.R;

import java.util.ArrayList;

import io.realm.Realm;
import io.realm.RealmList;

/**
 * Created by Antonia on 06.05.2016.
 */
public class ListItemAdapter extends ArrayAdapter<Toilet> {

    private ArrayList<Toilet> items;
    private final Context context;

    /** 
     * Constructor for the ListItemAdapter 
     * @param context: the Context to be set 
     * @param items: the ArrayList to be set 
     **/
    public ListItemAdapter(Context context, ArrayList<Toilet> items) {
        super(context, R.layout.row, items);
        this.context = context;
        this.items = items;
    }

    /** 
     * Sets the data that is to be displayed in the list.  
     * @return The View containing the different list items  
     * @param position: the position of the list item 
     * @param convertView 
     * @param parent: the parent element of the list item 
     **/
    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        View view;
        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        view = inflater.inflate(R.layout.row, parent, false);

        TextView nameTV = (TextView) view.findViewById(R.id.toiletName);
        TextView distanceTV = (TextView) view.findViewById(R.id.toiletDistance);

        Toilet toilet = items.get(position);

        String name = toilet.getName();

        if (nameTV != null) {
            nameTV.setText(name);
        }

        if (distanceTV != null && Model.model.distanceNeeded) {
            //Accessing the distance of the toilet
            Integer distance = Model.model.namesDistances.get(toilet);
            if(distance >= 1000) {
                Float distanceKM = (float) distance/1000;
                distanceTV.setText(String.valueOf(Model.model.roundFloat(distanceKM, 1))+ " km");
            } else {
                distanceTV.setText(String.valueOf(distance)+ " m");
            }
        }

        return view;
    }
}
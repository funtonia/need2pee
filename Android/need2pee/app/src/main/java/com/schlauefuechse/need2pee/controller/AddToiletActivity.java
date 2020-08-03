package com.schlauefuechse.need2pee.controller;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.Toast;

import com.schlauefuechse.need2pee.R;
import com.schlauefuechse.need2pee.model.Model;

public class AddToiletActivity extends AppCompatActivity {
    //Button
    private Button saveBtn;

    //EditText
    private EditText nameET;
    private EditText descrET;

    //Switch
    private Switch freeSwitch;
    private Switch barrierFreeSwitch;

    //own Location
    private double longitude;
    private double latitude;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.add_toilets_layout);
        setTitle("Add a toilet at your location");
        Intent intent = getIntent();
        longitude = intent.getExtras().getDouble("longitude");
        latitude = intent.getExtras().getDouble("latitude");

        nameET = (EditText) findViewById(R.id.nameET);
        nameET.addTextChangedListener(new TextWatcher() {

            public void afterTextChanged(Editable s) {
                if(nameET.getText().toString().equals("")){
                    saveBtn.setEnabled(false);
                    Toast.makeText(getApplicationContext(), "Please insert a name", Toast.LENGTH_SHORT).show();
                }
                else if(!Model.model.testUniqueness(nameET.getText().toString(), Model.model.resultsFullList)){
                    saveBtn.setEnabled(false);
                    Toast.makeText(getApplicationContext(), "The name already exists", Toast.LENGTH_SHORT).show();
                } else if(nameET.getText().length() > 19){
                    saveBtn.setEnabled(false);
                    Toast.makeText(getApplicationContext(), "Maximum 20 letters", Toast.LENGTH_SHORT).show();
                } else {
                    saveBtn.setEnabled(true);
                }
            }
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            public void onTextChanged(CharSequence s, int start, int before, int count) {}
        });

        descrET = (EditText) findViewById(R.id.descrET);

        freeSwitch = (Switch) findViewById(R.id.freeSwitch);
        barrierFreeSwitch = (Switch) findViewById(R.id.barrierFreeSwitch);

        saveBtn = (Button) findViewById(R.id.saveBtn);
        saveBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                saveToilet();
            }
        });

        Button cancelBtn = (Button) findViewById(R.id.cancelBtn);
        cancelBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                cancel();
            }
        });
    }

    /**
     * Saves the entered data into a new toilet object and returns to the MainActivity.
     */
    public void saveToilet() {
        String name = nameET.getText().toString();
        String descr = descrET.getText().toString();
        Boolean free = freeSwitch.isChecked();

        Boolean barrierFree = barrierFreeSwitch.isChecked();
        Model.model.saveToilet(name, descr, free, barrierFree, longitude, latitude);
        Intent mainIntent = new Intent(this, MainActivity.class);
        startActivity(mainIntent);
    }

    /**
     * Returns to the MainActivity.
     */
    public void cancel() {
        Intent mainIntent = new Intent(this, MainActivity.class);
        startActivity(mainIntent);
    }
}

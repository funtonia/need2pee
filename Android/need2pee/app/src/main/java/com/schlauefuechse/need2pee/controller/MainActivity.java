package com.schlauefuechse.need2pee.controller;

import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.drawable.BitmapDrawable;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.ActionMode;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.Switch;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;

import android.location.LocationListener;

import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.schlauefuechse.need2pee.model.ListItemAdapter;
import com.schlauefuechse.need2pee.model.Model;
import com.schlauefuechse.need2pee.R;
import com.schlauefuechse.need2pee.model.Toilet;

import java.util.ArrayList;

//TODO: LocationChanged

public class MainActivity extends AppCompatActivity implements
        OnMapReadyCallback, GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {

    private static final String TAG = "need2pee: MainActivity";

    private GoogleMap mGoogleMap;
    private SupportMapFragment mFragment;

    private Boolean permissionGranted;

    private Menu menu;

    private GoogleApiClient client;
    private Location mLastLocation;

    private ListView listView;

    private static final int MY_PERMISSIONS_REQUEST_ACCESS_FINE_LOCATION = 193;

    private Boolean isProviderEnabled;

    //Variables for location
    private Criteria criteria;
    private LocationManager locationManager;
    private String provider;
    private LocationListener locationListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (client == null) {
            client = new GoogleApiClient.Builder(this)
                    .addConnectionCallbacks(this)
                    .addOnConnectionFailedListener(this)
                    .addApi(LocationServices.API)
                    .build();
        }

        //Ask the user for permission at runtime
        ActivityCompat.requestPermissions(this,
                new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                MY_PERMISSIONS_REQUEST_ACCESS_FINE_LOCATION);

        Model.model.loadRealm(getApplicationContext());

        SharedPreferences sharedPref = this.getPreferences(Context.MODE_PRIVATE);
        boolean launchedBefore = sharedPref.getBoolean("launchedBefore", false);
        if (!launchedBefore) {
            Model.model.firstStart(this);
        }

        Model.model.fetchingCoreData(Model.model.free, Model.model.barrierFree);
    }

    @Override
    protected void onStart() throws SecurityException {
        locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        locationListener = new MyLocationListener();
        criteria = new Criteria();
        criteria.setAccuracy(Criteria.ACCURACY_FINE);

        criteria.setCostAllowed(false);
        // get the best provider depending on the criteria
        provider = locationManager.getBestProvider(criteria, false);

        if (permissionGranted != null && client != null) {
            if (!client.isConnected()) {
                //client is not yet connected -> needs to be connected
                Log.d("onStart", "connect client");
                client.connect();
            } else {
                //client is connected
                Log.d("onStart", "client is already connected");
                if (permissionGranted) {
                    //permission is granted -> check whether the location settings have been changed
                    if (isProviderEnabled != locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                        //Locationsettings changed
                        mGoogleMap.clear();
                        mFragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
                        mFragment.getMapAsync(this);
                    }
                }
                isProviderEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
            }

        }
        super.onStart();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case MY_PERMISSIONS_REQUEST_ACCESS_FINE_LOCATION: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    permissionGranted = true;
                    Log.d("permissionGranted", "true");
                } else {
                    permissionGranted = false;
                    Log.d("permissionGranted", "false");
                }
                client.connect();
                return;
            }
        }
    }

    @Override
    public void onMapReady(GoogleMap googleMap) throws SecurityException {

        mGoogleMap = googleMap;
        Model.model.mGoogleMap = googleMap;
        Model.model.setPointAnnotations();
        //Model.model.fetchingCoreData(Model.model.free, Model.model.barrierFree, mGoogleMap);

        CameraPosition cameraPosition;
        cameraPosition = new CameraPosition.Builder()
                .target(new LatLng(48.776879, 9.181475)).zoom(13).build();
        mGoogleMap.animateCamera(CameraUpdateFactory
                .newCameraPosition(cameraPosition));

        if (permissionGranted) {
            //Get the user's location
            mLastLocation = LocationServices.FusedLocationApi.getLastLocation(client);
            if (mLastLocation != null) {
                Log.d("onMapReady", "Permission granted and last location is available");
                //There is location data
                menu.getItem(1).setIcon(R.drawable.add);
                menu.getItem(1).setEnabled(true);
                mGoogleMap.setMyLocationEnabled(true);
                //Model.model.fetchingCoreData(Model.model.free, Model.model.barrierFree, mGoogleMap);
                initialiseListView(true);
                return;
            } else {
                Log.d("onMapReady", "Permission granted, but last location could not be shown.");
                menu.getItem(1).setIcon(R.drawable.add_disabled);
                menu.getItem(1).setEnabled(false);
                mGoogleMap.setMyLocationEnabled(false);
                initialiseListView(false);
                return;
            }
        }

        Model.model.fetchingCoreData(Model.model.free, Model.model.barrierFree);
        Log.d("onMapReady", "Permission not granted. Location could not be shown.");
        initialiseListView(false);
    }

    // Inflates the Toolbar of the MainActivity
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.toolbar, menu);
        this.menu = menu;
        menu.getItem(1).setIcon(R.drawable.add_disabled);
        menu.getItem(1).setEnabled(false);

        return true;
    }

    //Handling clicks on the ActionBarItems
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.action_filter:
                View filterBtnView = findViewById(R.id.action_filter);
                displayPopupWindow(filterBtnView);
                return true;

            case R.id.action_add:
                Intent addToiletIntent = new Intent(this, AddToiletActivity.class);
                addToiletIntent.putExtra("longitude", mLastLocation.getLongitude());
                addToiletIntent.putExtra("latitude", mLastLocation.getLatitude());
                this.startActivity(addToiletIntent);
                return true;

            default:
                return super.onOptionsItemSelected(item);
        }
    }

    /**
     * Display the popup containing the filters
     * @param anchorView: The button on which the filters are called
     */
    private void displayPopupWindow(View anchorView) {

        View layoutPopupWindow = getLayoutInflater().inflate(R.layout.popup_window, null);
        final PopupWindow popup = new PopupWindow(layoutPopupWindow, ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);

        // Closes the popup window when touch outside of it - when looses focus
        popup.setOutsideTouchable(true);
        popup.setFocusable(true);

        popup.setBackgroundDrawable(new BitmapDrawable());

        final Switch freeSwitch = (Switch) layoutPopupWindow.findViewById(R.id.freeFilterSwitch);
        freeSwitch.setChecked(Model.model.free);

        final Switch barrierFreeSwitch = (Switch) layoutPopupWindow.findViewById(R.id.barrierFreeFilterSwitch);
        barrierFreeSwitch.setChecked(Model.model.barrierFree);

        Button applyFilterBtn = (Button) layoutPopupWindow.findViewById(R.id.applyFilterBtn);
        applyFilterBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Model.model.free = freeSwitch.isChecked();
                Model.model.barrierFree = barrierFreeSwitch.isChecked();
                Model.model.fetchingCoreData(Model.model.free, Model.model.barrierFree);
                popup.dismiss();
                //reload the map and the listview without restarting the activity
                mGoogleMap.clear();
                mFragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
                mFragment.getMapAsync(MainActivity.this);
            }
        });
        popup.showAsDropDown(anchorView);
    }

    @Override
    public void onConnected(@Nullable Bundle bundle) throws SecurityException {

        if (permissionGranted) {
            Log.d("onConnected", "permissionGranted");
            mLastLocation = LocationServices.FusedLocationApi.getLastLocation(client);
            locationManager.requestLocationUpdates(provider, 0, 300, locationListener);
            //locationListener.onLocationChanged(mLastLocation);
            if (mLastLocation == null) {
                isProviderEnabled = false;
                Log.d("onConnected", "Last location is null");
                new AlertDialog.Builder(MainActivity.this)
                        .setTitle("Please activate your location.")
                        .setMessage("Click 'ok' to go to your location settings.")
                        .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int which) {
                                Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                                startActivity(intent);
                            }
                        })
                        .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                            }
                        })
                        .show();
            } else {
                isProviderEnabled = true;
                Log.d("onConnected", "Last location is not null");
            }
        } else {
            Log.d("onConnected", "permission not granted");
            Log.d(TAG, "Location could not be shown.");
        }

        mFragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
        mFragment.getMapAsync(this);
    }

    private class MyLocationListener implements LocationListener {

        @Override
        public void onLocationChanged(Location location) {
            if (mLastLocation != null) {
                initialiseListView(true);
            }
            Toast.makeText(getApplicationContext(), "Location changed", Toast.LENGTH_SHORT).show();
        }

        @Override
        public void onStatusChanged(String provider, int status, Bundle extras) {
        }

        @Override
        public void onProviderEnabled(String provider) {
        }

        @Override
        public void onProviderDisabled(String provider) {
        }
    }

    @Override
    public void onConnectionSuspended(int i) {

    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {

    }

    /**
     * Initialises the listView
     * @param isGPSAvailable: Boolean indicating whether the distance to the toilets may be displayed
     */
    public void initialiseListView(Boolean isGPSAvailable) {
        Log.d("initialiseListView", "called");
        listView = (ListView) findViewById(R.id.listView);
        ListItemAdapter adapter = new ListItemAdapter(this, Model.model.toiletsUnsorted);
        listView.setAdapter(adapter);

        if (permissionGranted && isGPSAvailable) {
            Log.d("initialiseListView", "calledTrue");
            Model.model.distanceNeeded = true;
            Model.model.toiletsUnsorted.clear();
            Model.model.getSortedKeys(Model.model.computeDistances(mLastLocation.getLatitude(), mLastLocation.getLongitude()));

            adapter.notifyDataSetChanged();
        } else {
            Log.d("initialiseListView", "calledFalse");
            Model.model.distanceNeeded = false;
            Model.model.toiletsUnsorted.clear();
            Model.model.realmListToArrayList(Model.model.resultsFilteredList);
        }
        adapter.notifyDataSetChanged();

        listView.setItemsCanFocus(true);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position,
                                    long id) {
                Toilet toilet = (Toilet) listView.getItemAtPosition(position);
                Location loc = new Location("");
                loc.setLatitude(toilet.getLatitude());
                loc.setLongitude(toilet.getLongitude());
                Model.model.highlightPointAnnotations(toilet);
                Model.model.showMapMiddle(loc);
            }
        });

        listView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE_MODAL);
        listView.setMultiChoiceModeListener(new AbsListView.MultiChoiceModeListener() {

            ArrayList<Toilet> toiletsToDelete = new ArrayList<>();
            ArrayList<String> positionsSelected = new ArrayList<>();

            int counter;

            @Override
            public void onItemCheckedStateChanged(ActionMode mode, int position,
                                                  long id, boolean checked) {

                Toilet toilet = (Toilet) listView.getItemAtPosition(position);

                final int checkedCount = listView.getCheckedItemCount();
                counter = checkedCount;
                switch (checkedCount) {
                    case 0:
                        mode.setTitle(null);
                        break;
                    default:
                        mode.setTitle("" + checkedCount + " items selected");
                        break;
                }

                if (checked) {
                    toiletsToDelete.add(toilet);
                } else {
                    toiletsToDelete.remove(toilet);
                }
            }

            @Override
            public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
                switch (item.getItemId()) {
                    case R.id.deleteItem:
                        for (Toilet toilet : toiletsToDelete) {
                            Model.model.deleteToilet(toilet.getName(), mGoogleMap);
                        }
                        mGoogleMap.clear();
                        mFragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
                        mFragment.getMapAsync(MainActivity.this);
                        Toast toast = Toast.makeText(getApplicationContext(), "Deleted " + counter + " Toilets", Toast.LENGTH_SHORT);
                        toast.setGravity(Gravity.CENTER_VERTICAL, 0, 0);
                        toast.setText("Deleted " + counter + " Toilets");
                        toast.show();
                        return true;
                    default:
                        return false;
                }
            }

            @Override
            public boolean onCreateActionMode(ActionMode mode, Menu menu) {
                toiletsToDelete.clear();
                positionsSelected.clear();
                MenuInflater inflater = mode.getMenuInflater();
                inflater.inflate(R.menu.context_menu, menu);
                return true;
            }

            @Override
            public void onDestroyActionMode(ActionMode mode) {
            }

            @Override
            public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
                // Here you can perform updates to the CAB due to
                // an invalidate() request
                return false;
            }
        });
    }

    @Override
    protected void onStop() {
        super.onStop();
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }
        locationManager.removeUpdates(locationListener);
    }
}



package com.schlauefuechse.need2pee.model;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.location.Location;
import android.util.Log;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.schlauefuechse.need2pee.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

import io.realm.Realm;
import io.realm.RealmConfiguration;
import io.realm.RealmList;
import io.realm.RealmResults;

public class Model {
    private static final String TAG = "need2pee: Model";

    //Boolean indicating whether a toilet is cost- and/or barrier-free
    public static boolean free = false;
    public static boolean barrierFree = false;

    public boolean distanceNeeded;

    private Context context;

    //Creating a model instance used throughout the code
    public final static Model model = new Model();

    //Variable for the mapView used in the main view
    public GoogleMap mGoogleMap;

    //Array containing the filtered set of toilets
    public RealmList<Toilet> resultsFilteredList;

    //Array containing the full set of toilets
    public RealmList<Toilet> resultsFullList;

    //Array containing the sorted keys
    //public ArrayList<Toilet> sortedKeys;

    //Array containing the unsorted toilets
    public ArrayList<Toilet> toiletsUnsorted = new ArrayList<>();

    //Map containing the names and distances in a non-sorted way
    HashMap<Toilet, Integer> namesDistances;


    // Get a Realm instance for this thread
    private Realm realm;

    private Model() {
        super();
    }

    /**
     * This method is called when the app was never launched before.
     * Calling the method readJSONFromAsset() and setting the boolean true.
     * @param activity: The current activity
     */
    public void firstStart(Activity activity){
        loadJSONFromAsset();
        SharedPreferences sharedPref = activity.getPreferences(Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPref.edit();
        editor.putBoolean("launchedBefore", true);
        editor.commit();
    }

    /**
     * Loading Realm-Database
     *  @param context: The current context
     */
    public void loadRealm(Context context) {
        this.context = context;
        // Create a RealmConfiguration which is to locate Realm file in package's "files" directory.
        RealmConfiguration realmConfig = new RealmConfiguration
                .Builder(context)
                .deleteRealmIfMigrationNeeded()
                .build();
        realm = Realm.getInstance(realmConfig);
    }

    /** 
     * Reading the data from the toilets.json file. This method is only called on the first start.
     **/
    public void loadJSONFromAsset() {
        String json = null;
        try {

            InputStream is = context.getAssets().open("toilets.json");

            int size = is.available();

            byte[] buffer = new byte[size];

            is.read(buffer);

            is.close();

            json = new String(buffer, "UTF-8");

        } catch (IOException ex) {
            ex.printStackTrace();
        }
        addJSONtoCoreData(json);
    }

    /**
     * Adding the data retrieved from the readJSONFromAsset() method to core data.
     * @param json: The string containing the json-data
     */
   public void addJSONtoCoreData(String json) {
       try {
           JSONObject jsonObj = new JSONObject(json);
           JSONArray toilets = jsonObj.getJSONArray("toilets");
           for (int i = 0; i < toilets.length(); i++) {
               JSONObject toilet = toilets.getJSONObject(i);
               //Setting the needed parameters for the saveToilet method from the JSON file
               String name = toilet.getString("name");
               String descr = toilet.getString("descr");
               Boolean barrierFree = toilet.getBoolean("barrierFree");
               Boolean free = toilet.getBoolean("free");
               Double longitude = toilet.getDouble("longitude");
               Double latitude = toilet.getDouble("latitude");
               saveToilet(name, descr, free, barrierFree, longitude, latitude);
           }
       } catch (JSONException e) {
           e.printStackTrace();
       }
   }

    /**
     * Saving toilets to core data.
     * @param name: String of the toilet's name.
     * @param descr: String with the toilet's description.
     * @param free: Boolean indicating whether the toilet is cost-free.
     * @param barrierFree: Boolean indicating whether the toilet is barrier-free.
     * @param longitude: The toilet's longitude.
     * @param latitude: The toilet's latitude.
     */
    public void saveToilet(String name, String descr, Boolean free, Boolean barrierFree, Double longitude, Double latitude) {

        Toilet toilet = new Toilet();

        toilet.setName(name);
        toilet.setDescr(descr);
        toilet.setFree(free);
        toilet.setBarrierFree(barrierFree);
        toilet.setLongitude(longitude);
        toilet.setLatitude(latitude);

        // Persist toilets
        realm.beginTransaction();
        realm.copyToRealm(toilet);
        realm.commitTransaction();
    }

    /**
     * Fetching the core data
     * @return An array with the toilets from core data that match the filter.
     * @param free: Boolean indicating whether the toilet is cost-free.
     * @param barrierFree: Boolean indicating whether the toilet is barrier-free.
     */
    public RealmList<Toilet> fetchingCoreData(Boolean free, Boolean barrierFree) {

            //RealmResults containing the filtered set of toilets
            RealmResults<Toilet> resultsFiltered;

            //RealmResults containing the full set of toilets
            RealmResults<Toilet> resultsFull;

            //Setting the variables free and barrierFree so they can be used to compute the distance
            this.free = free;
            this.barrierFree = barrierFree;

            //Saving all toilets in a RealmResults object
            resultsFull = realm.where(Toilet.class).findAll();
            //Saving all the toilets in a list
            resultsFullList = new RealmList<Toilet>();
            resultsFullList.addAll(resultsFull.subList(0, resultsFull.size()));

            //It's either not free or not barrier-free or neither nor
            if (free && barrierFree) {
                //Both are active
                resultsFiltered = realm.where(Toilet.class).equalTo("free", true).equalTo("barrierFree", true).findAll();

            } else if (free) {
                //Only free active
                //return addFree(resultsFull)
                resultsFiltered = realm.where(Toilet.class).equalTo("free", true).findAll();
            } else if (barrierFree) {
                //Only barrierFree active
                resultsFiltered = realm.where(Toilet.class).equalTo("barrierFree", true).findAll();
            } else{
                resultsFiltered = resultsFull;
            }
            //Saving all the filtered toilets in a list
            resultsFilteredList = new RealmList<Toilet>();
            resultsFilteredList.addAll(resultsFiltered.subList(0, resultsFiltered.size()));

            realmListToArrayList(resultsFilteredList);
            //deleteAllToilets();
            return resultsFilteredList;
        }

    /**
     * Shows the given location in the middle of the map.
     * @param location: The given location.
     */
    public void showMapMiddle(Location location) {
        mGoogleMap.animateCamera(CameraUpdateFactory.newLatLngZoom(
                new LatLng(location.getLatitude(), location.getLongitude()), 13));

        CameraPosition cameraPosition = new CameraPosition.Builder()
                .target(new LatLng(location.getLatitude(), location.getLongitude()))      // Sets the center of the map to location user
                .zoom(16)                   // Sets the zoom
                .build();                   // Creates a CameraPosition from the builder
        mGoogleMap.moveCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
    }

    /**
     * Sets point annotations on the map.
     */
    public void setPointAnnotations() {

        for (Toilet toilet : resultsFilteredList) {
           // Toast.makeText(this, "addedAnnotation", Toast.LENGTH_SHORT).show();
            if(toilet!=null){
            LatLng position = new LatLng(toilet.getLatitude(),toilet.getLongitude());
            MarkerOptions markerOptions = new MarkerOptions();
            markerOptions.position(position);
            markerOptions.title(toilet.getName());
            markerOptions.snippet(toilet.getDescr());
            markerOptions.icon(BitmapDescriptorFactory.fromResource(R.drawable.toilet));
                //
            mGoogleMap.addMarker(markerOptions);}
        }
    }

    /**
     * Sets the highlight of the selected Toilet on the point annotation on the map.
     * @param selectedToilet: The toilet the user selected.
     */
    public void highlightPointAnnotations(Toilet selectedToilet) {

        for (Toilet toilet : resultsFilteredList) {
            // Toast.makeText(this, "addedAnnotation", Toast.LENGTH_SHORT).show();
            if(toilet!=null){
                LatLng position = new LatLng(toilet.getLatitude(),toilet.getLongitude());
                MarkerOptions markerOptions = new MarkerOptions();
                markerOptions.position(position);
                markerOptions.title(toilet.getName());
                markerOptions.snippet(toilet.getDescr());
                markerOptions.icon(BitmapDescriptorFactory.fromResource(R.drawable.toilet));
                //
                Marker m = mGoogleMap.addMarker(markerOptions);
                if(selectedToilet.equals(toilet)){
                    m.showInfoWindow();
                }
            }
        }
    }

    /**
     * Sets the highlight of the selected Toilet on the point annotation on the map.
     * @return The ArrayList containing the unsorted toilets
     * @param resultsFilteredList: The RealmList holding the toilets
     */
    public ArrayList<Toilet> realmListToArrayList(RealmList<Toilet> resultsFilteredList) {
        //toiletsUnsorted = new ArrayList<>();
        for(Toilet toilet : resultsFilteredList) {
            toiletsUnsorted.add(toilet);
        }
        return toiletsUnsorted;
    }


    /**
     * Deletes a toilet the user selects
     * @param toiletName: String of the toilet's name that should be deleted.
     * @param mapView
     */
    public void deleteToilet(String toiletName, GoogleMap mapView) {
        for (final Toilet toilet : resultsFilteredList) {
            //Selecting the toilet matching the given name
            if (toilet.getName().equals(toiletName)) {
                realm.executeTransaction(new Realm.Transaction() {
                    @Override
                    public void execute(Realm realm) {
                        toilet.deleteFromRealm();
                    }
                });
                break;
            }
        }
        //Fetching what is in core data to display it in the table and on the map
        fetchingCoreData(free, barrierFree);
    }

    /**
     * Computes the distance from the user's current location to the toilets
     * @param ownLocationLatitude: Double of the user's current location's latitude.
     * @param ownLocationLongitude: Double of the user's current location's longitude.
     * @return A map with the toilets' names and the corresponding distances to the user's current location
     */
    public HashMap<Toilet, Integer> computeDistances(Double ownLocationLatitude, Double ownLocationLongitude) {
        namesDistances = new HashMap<>();
        float[] results;

        for(Toilet toilet : resultsFilteredList) {
            //The distance from the current position to the toilet is stored in this array
            results = new float[1];

            //Method computing the distance
            Location.distanceBetween(ownLocationLatitude, ownLocationLongitude, toilet.latitude, toilet.longitude, results);
            //The distance is added to the HashMap
            namesDistances.put(toilet, Math.round(results[0]));
        }
        return namesDistances;
    }

    /**
     * Sorts the calculated distances from the user's current location to the toilets ascendingly
     * @param namesDistances: The map containing the toilets' names and the corresponding distanes.
     * @return An array containing the toilets' names sorted after their distances to the user's current location in an ascending way
     */
    public ArrayList<Toilet> getSortedKeys(final HashMap<Toilet, Integer> namesDistances) {
        //toiletsUnsorted = new ArrayList(namesDistances.keySet());

        for(Toilet toilet : namesDistances.keySet()) {
            toiletsUnsorted.add(toilet);
        }


        Collections.sort(toiletsUnsorted, new Comparator<Toilet>() {
            @Override
            public int compare(Toilet toilet1, Toilet toilet2) {
                return namesDistances.get(toilet1).compareTo(namesDistances.get(toilet2));
            }
        });

        return toiletsUnsorted;
    }

    /**
     * Tests whether the name the user inserts already exists among the saved toilets
     * @param name: the name the user inserted
     * @return A boolean indicating whether the name already exists (false) or not
     */
    public Boolean testUniqueness(String name, List<Toilet> resultsFullList){
        for (Toilet toilet: resultsFullList){
            if (toilet.getName().equals(name)) {
                return false;
            }
        }
        return true;
    }

    /**
     * Rounds the given float on the given decimal places.
     * @param d Float to be rounded.
     * @param decimalPlace Integer of the decimal places.
     * @return A float value being rounded.
     */
    public float roundFloat(float d, int decimalPlace) {
        BigDecimal bd = new BigDecimal(Float.toString(d));
        bd = bd.setScale(decimalPlace, BigDecimal.ROUND_HALF_UP);
        return bd.floatValue();
    }
}
package com.schlauefuechse.need2pee;

import android.app.Application;
import android.support.test.runner.AndroidJUnit4;
import android.test.ApplicationTestCase;

import com.schlauefuechse.need2pee.model.Model;
import com.schlauefuechse.need2pee.model.Toilet;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import static org.junit.Assert.*;

import io.realm.Realm;
import io.realm.RealmConfiguration;
import io.realm.RealmList;
import io.realm.RealmResults;

@RunWith(AndroidJUnit4.class)
public class ApplicationTestRealm extends ApplicationTestCase<Application> {
    public ApplicationTestRealm() {
        super(Application.class);
    }

    @Rule
    RealmConfiguration realmConfig;
    Realm realm;
    //Array containing the filtered set of toilets (free)
    public RealmList<Toilet> resultsFilteredListFree;
    //Array containing the filtered set of toilets (barrierfree, free)
    public RealmList<Toilet> resultsFilteredListBarrierFreeFree;
    //Array containing the filtered set of toilets (barrierfree)
    public RealmList<Toilet> resultsFilteredListBarrierFree;
    //Array containing the full set of toilets
    public RealmList<Toilet> resultsFullList;

    @Before
    public void setUp() throws Exception {
        realmConfig = new RealmConfiguration
                .Builder(getContext())
                .deleteRealmIfMigrationNeeded()
                .build();
        realm = Realm.getInstance(realmConfig);
        realm.beginTransaction();
        realm.deleteAll();
        realm.commitTransaction();
        Model.model.loadRealm(getContext());
        Model.model.loadJSONFromAsset();

        //RealmResults containing the filtered set of toilets (free & barrierfree)
        RealmResults<Toilet> resultsFilteredBarrierFreeFree;

        //RealmResults containing the filtered set of toilets (barrierfree)
        RealmResults<Toilet> resultsFilteredBarrierFree;

        //RealmResults containing the filtered set of toilets (free)
        RealmResults<Toilet> resultsFilteredFree;

        //RealmResults containing the full set of toilets
        RealmResults<Toilet> resultsFull;

        //Saving all toilets in a RealmResults object
        resultsFull = realm.where(Toilet.class).findAll();
        //Saving all the toilets in a the resultsFullList
        resultsFullList = new RealmList<Toilet>();
        resultsFullList.addAll(resultsFull.subList(0, resultsFull.size()));

        //Saving free & barrierfree toilets in a RealmResults object
        resultsFilteredBarrierFreeFree = realm.where(Toilet.class).equalTo("free", true).equalTo("barrierFree", true).findAll();
        //Saving free & barrierfree toilets in a the resultsFilteredListBarrierFreeFree
        resultsFilteredListBarrierFreeFree = new RealmList<Toilet>();
        resultsFilteredListBarrierFreeFree.addAll(resultsFilteredBarrierFreeFree.subList(0, resultsFilteredBarrierFreeFree.size()));

        //Saving free toilets in a RealmResults object
        resultsFilteredFree = realm.where(Toilet.class).equalTo("free", true).findAll();
        //Saving free toilets in a the resultsFilteredListFree
        resultsFilteredListFree = new RealmList<Toilet>();
        resultsFilteredListFree.addAll(resultsFilteredFree.subList(0, resultsFilteredFree.size()));

        //Saving barrierfree toilets in a RealmResults object
        resultsFilteredBarrierFree = realm.where(Toilet.class).equalTo("barrierFree", true).findAll();
        //Saving barrierfree toilets in a the resultsFilteredListBarrierFree
        resultsFilteredListBarrierFree = new RealmList<Toilet>();
        resultsFilteredListBarrierFree.addAll(resultsFilteredBarrierFree.subList(0, resultsFilteredBarrierFree.size()));
    }

    //Tests the functions loadRealm() and readJSONFromAsset() as well as the correct storage of the Toilets
    @Test
    public void testFilterResultsFull(){
        Assert.assertEquals(16, resultsFullList.size());
        Assert.assertEquals("Schlossplatz, U-Bahn", resultsFullList.get(0).getName());
        Assert.assertEquals("Arnulf-Klett-Passage", resultsFullList.get(1).getName());
        Assert.assertEquals("Staatsgalerie/Planetarium", resultsFullList.get(2).getName());
        Assert.assertEquals("Charlottenplatz 10", resultsFullList.get(3).getName());
        Assert.assertEquals("Am Neckartor", resultsFullList.get(4).getName());
        Assert.assertEquals("Paulinenstraße 13/1", resultsFullList.get(5).getName());
        Assert.assertEquals("Rotebühlplatz(LBBW)", resultsFullList.get(6).getName());
        Assert.assertEquals("Kernerplatz", resultsFullList.get(7).getName());
        Assert.assertEquals("Königstraße 5", resultsFullList.get(8).getName());
        Assert.assertEquals("Alte Kanzlei", resultsFullList.get(9).getName());
        Assert.assertEquals("Kronprinzstraße", resultsFullList.get(10).getName());
        Assert.assertEquals("Holzstr./Dorotheenstr.", resultsFullList.get(11).getName());
        Assert.assertEquals("Hirschstr./Nadlerstr.", resultsFullList.get(12).getName());
        Assert.assertEquals("Rotebühlplatz", resultsFullList.get(13).getName());
        Assert.assertEquals("Wilhelmsplatz", resultsFullList.get(14).getName());
        Assert.assertEquals("Paulinenbrücke", resultsFullList.get(15).getName());
    }

    //Tests the functions loadRealm() and readJSONFromAsset() as well as the correct storage of the Toilets
    @Test
    public void testFilterResultsFilteredBarrierFreeFree(){
        Assert.assertEquals(2, resultsFilteredListBarrierFreeFree.size());
        Assert.assertEquals("Am Neckartor", resultsFilteredListBarrierFreeFree.get(0).getName());
        Assert.assertEquals("Rotebühlplatz(LBBW)", resultsFilteredListBarrierFreeFree.get(1).getName());
    }

    //Tests the functions loadRealm() and readJSONFromAsset() as well as the correct storage of the Toilets
    @Test
    public void testFilterResultsFilteredFree(){
        Assert.assertEquals(3, resultsFilteredListFree.size());
        Assert.assertEquals("Am Neckartor", resultsFilteredListFree.get(0).getName());
        Assert.assertEquals("Paulinenstraße 13/1", resultsFilteredListFree.get(1).getName());
        Assert.assertEquals("Rotebühlplatz(LBBW)", resultsFilteredListFree.get(2).getName());
    }

    //Tests the functions loadRealm() and readJSONFromAsset() as well as the correct storage of the Toilets
    @Test
    public void testFilterResultsFilteredBarrierFree(){
        Assert.assertEquals(6, resultsFilteredListBarrierFree.size());
        Assert.assertEquals("Schlossplatz, U-Bahn", resultsFilteredListBarrierFree.get(0).getName());
        Assert.assertEquals("Arnulf-Klett-Passage", resultsFilteredListBarrierFree.get(1).getName());
        Assert.assertEquals("Staatsgalerie/Planetarium", resultsFilteredListBarrierFree.get(2).getName());
        Assert.assertEquals("Charlottenplatz 10", resultsFilteredListBarrierFree.get(3).getName());
        Assert.assertEquals("Am Neckartor", resultsFilteredListBarrierFree.get(4).getName());
        Assert.assertEquals("Rotebühlplatz(LBBW)", resultsFilteredListBarrierFree.get(5).getName());
    }
}

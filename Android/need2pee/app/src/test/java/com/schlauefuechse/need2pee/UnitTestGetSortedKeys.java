package com.schlauefuechse.need2pee;

import com.schlauefuechse.need2pee.model.Model;
import com.schlauefuechse.need2pee.model.Toilet;

import junit.framework.Assert;
import junit.framework.TestCase;

import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.HashMap;

public class UnitTestGetSortedKeys extends TestCase{


    public HashMap<Toilet, Float> namesDistances;
    public ArrayList<Toilet> sortedKeysExpected;
    public Boolean freeTest = Model.model.free;
    public Boolean barrierFreeTest = Model.model.barrierFree;

    @Before
    public void setUp(){
        namesDistances = new HashMap<>();
        Toilet toilet1 = new Toilet();
        toilet1.setName("toilet1");
        namesDistances.put(toilet1, 3.4f);
        Toilet toilet2 = new Toilet();
        toilet2.setName("toilet2");
        namesDistances.put(toilet2, 3.1f);
        Toilet toilet3 = new Toilet();
        toilet3.setName("toilet3");
        namesDistances.put(toilet3, 3.5f);
        Toilet toilet4 = new Toilet();
        toilet4.setName("toilet4");
        namesDistances.put(toilet4, 3.2f);
        Toilet toilet5 = new Toilet();
        toilet5.setName("toilet5");
        namesDistances.put(toilet5, 3.3f);

        sortedKeysExpected = new ArrayList();
        sortedKeysExpected.add(toilet2);
        sortedKeysExpected.add(toilet4);
        sortedKeysExpected.add(toilet5);
        sortedKeysExpected.add(toilet1);
        sortedKeysExpected.add(toilet3);
    }

    //Tests the function getSortedKeys()
    @Test
    public void testCorrectSortedKeys(){
        assertEquals(sortedKeysExpected, Model.model.getSortedKeys(namesDistances));
    }
}



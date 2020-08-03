package com.schlauefuechse.need2pee;

import org.junit.Before;
import org.junit.Test;
import junit.framework.TestCase;
import static org.junit.Assert.*;
import com.schlauefuechse.need2pee.model.Model;
import com.schlauefuechse.need2pee.model.Toilet;

import java.util.ArrayList;

public class UnitTestUniqueToiletName extends TestCase{

    public ArrayList<Toilet> testList = new ArrayList();

    @Before
    public void setUp(){
        Toilet toilet1 = new Toilet();
        toilet1.setName("Charlottenplatz 10");
        Toilet toilet2 = new Toilet();
        toilet2.setName("Schlossplatz, U-Bahn");
        Toilet toilet3 = new Toilet();
        toilet3.setName("TestTestTestssss");
        Toilet toilet4 = new Toilet();
        toilet4.setName("Paulinenbrücke");
        Toilet toilet5 = new Toilet();
        toilet5.setName("         ");
        testList.clear();
        testList.add(toilet1);
        testList.add(toilet2);
        testList.add(toilet3);
        testList.add(toilet4);
        testList.add(toilet5);
    }

    //Tests the testUniqueness() function
    @Test
    public void testUniqunessTrue(){
        assertTrue(Model.model.testUniqueness("xxxxxxxx", testList));
        assertTrue(Model.model.testUniqueness("xyzDieseToilette", testList));
        assertTrue(Model.model.testUniqueness("blayyyyyy", testList));
        assertTrue(Model.model.testUniqueness("Wilhelmsplatz     ", testList));
    }

    //Tests the testUniqueness() function
    @Test
    public void testUniqunessFalse(){
        assertFalse(Model.model.testUniqueness("Charlottenplatz 10", testList));
        assertFalse(Model.model.testUniqueness("Schlossplatz, U-Bahn", testList));
        assertFalse(Model.model.testUniqueness("Paulinenbrücke", testList));
    }
}
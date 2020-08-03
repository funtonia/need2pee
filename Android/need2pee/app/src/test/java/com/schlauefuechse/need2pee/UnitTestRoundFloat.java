package com.schlauefuechse.need2pee;

import com.schlauefuechse.need2pee.model.Model;

import junit.framework.TestCase;
import org.junit.Test;

public class UnitTestRoundFloat extends TestCase{

    //Tests the rounding up of the roundFloat() function
    @Test
    public void testRoundUp(){
        assertEquals("5.35", Float.toString(Model.model.roundFloat(5.34555f, 2)));
        assertEquals("445.67676", Float.toString(Model.model.roundFloat(445.676765666f, 5)));
        assertEquals("1.1114", Float.toString(Model.model.roundFloat(1.11135f, 4)));
    }

    //Tests the rounding down of the roundFloat() function
    @Test
    public void testRoundDown(){
        assertEquals("5.34", Float.toString(Model.model.roundFloat(5.34455f, 2)));
        assertEquals("122.2222", Float.toString(Model.model.roundFloat(122.2222222222f, 4)));
        assertEquals("888.888", Float.toString(Model.model.roundFloat(888.8884f, 3)));
    }

    //Tests the rounding down of the roundFloat() function
    @Test
    public void testRoundLessDecimalPlaces(){
        assertEquals("5.0", Float.toString(Model.model.roundFloat(5, 2)));
        assertEquals("123122.22", Float.toString(Model.model.roundFloat(123122.22f, 4)));
    }
}
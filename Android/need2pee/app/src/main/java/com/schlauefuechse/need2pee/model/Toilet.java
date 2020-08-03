package com.schlauefuechse.need2pee.model;

import io.realm.RealmObject;
import io.realm.annotations.Required;

public class Toilet extends RealmObject {
    @Required // Name cannot be null
            String name;
    private String descr;
    private Boolean barrierFree;
    private Boolean free;
    Double longitude;
    Double latitude;

    public Toilet() {
        super();
    }

    public Toilet(String name, Double distance) {
        super();
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    String getDescr() {
        return descr;
    }

    void setDescr(String descr) {
        this.descr = descr;
    }

    public Boolean getBarrierFree() {
        return barrierFree;
    }

    void setBarrierFree(Boolean barrierFree) {
        this.barrierFree = barrierFree;
    }

    public Boolean getFree() {
        return free;
    }

    public void setFree(Boolean free) {
        this.free = free;
    }

    public Double getLongitude() {
        return longitude;
    }

    void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Double getLatitude() {
        return latitude;
    }

    void setLatitude(Double latitude) {
        this.latitude = latitude;
    }
}
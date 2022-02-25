package com.whiteguru.capacitor.plugin.videoeditor;

public class TrimSettings {
    private long startsAt = 0;
    private long endsAt = 0;

    public TrimSettings() {
    }

    public TrimSettings(long startsAt, long endsAt) {
        if (startsAt < 0) {
            throw new IllegalArgumentException("Parameter startsAt cannot be negative");
        }

        if (endsAt < 0) {
            throw new IllegalArgumentException("Parameter endsAt cannot be negative");
        }

        this.startsAt = startsAt;
        this.endsAt = endsAt;
    }

    /**
     * Get startsAt in miliSeconds
     * @return startsAt in miliSeconds
     */
    public long getStartsAt() {
        return startsAt;
    }

    public void setStartsAt(long startsAt) {
        if (startsAt < 0) {
            throw new IllegalArgumentException("Parameter startsAt cannot be negative");
        }

        this.startsAt = startsAt;
    }

    /**
     * Get endsAt in miliSeconds
     * @return endsAt in miliSeconds
     */
    public long getEndsAt() {
        return endsAt;
    }

    public void setEndsAt(long endsAt) {
        if (endsAt < 0) {
            throw new IllegalArgumentException("Parameter endsAt cannot be negative");
        }

        this.endsAt = endsAt;
    }
}

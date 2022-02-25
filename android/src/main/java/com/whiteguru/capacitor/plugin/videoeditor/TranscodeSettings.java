package com.whiteguru.capacitor.plugin.videoeditor;

public class TranscodeSettings {

    private int height = 0;
    private int width = 0;
    private boolean keepAspectRatio = true;

    public TranscodeSettings() {
    }

    public TranscodeSettings(int height, int width, boolean keepAspectRatio) {
        if (height < 0) {
            throw new IllegalArgumentException("Parameter height cannot be negative");
        }

        if (width < 0) {
            throw new IllegalArgumentException("Parameter width cannot be negative");
        }

        this.height = height;
        this.width = width;
        this.keepAspectRatio = keepAspectRatio;
    }

    public int getHeight() {
        return height;
    }

    public void setHeight(int height) {
        if (height < 0) {
            throw new IllegalArgumentException("Parameter height cannot be negative");
        }

        this.height = height;
    }

    public int getWidth() {
        return width;
    }

    public void setWidth(int width) {
        if (width < 0) {
            throw new IllegalArgumentException("Parameter width cannot be negative");
        }

        this.width = width;
    }

    public boolean isKeepAspectRatio() {
        return keepAspectRatio;
    }

    public void setKeepAspectRatio(boolean keepAspectRatio) {
        this.keepAspectRatio = keepAspectRatio;
    }
}

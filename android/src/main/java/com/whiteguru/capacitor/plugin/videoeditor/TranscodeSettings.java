package com.whiteguru.capacitor.plugin.videoeditor;

public class TranscodeSettings {
    private int height = 0;
    private int width = 0;
    private boolean keepAspectRatio = true;
    private String codec = "";


    public TranscodeSettings() {
    }

    public TranscodeSettings(int height, int width, boolean keepAspectRatio, String codec) {
        if (height < 0) {
            throw new IllegalArgumentException("Parameter height cannot be negative");
        }

        if (width < 0) {
            throw new IllegalArgumentException("Parameter width cannot be negative");
        }

        this.height = height;
        this.width = width;
        this.keepAspectRatio = keepAspectRatio;
        this.codec = codec;
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

    public String getCodec() {
        return codec;
    }

    public void setCodec(String codec) {
        this.codec = codec;
    }
}

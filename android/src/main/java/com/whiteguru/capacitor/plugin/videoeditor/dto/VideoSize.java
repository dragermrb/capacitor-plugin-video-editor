package com.whiteguru.capacitor.plugin.videoeditor.dto;

public class VideoSize {
    public int width;
    public int height;

    public VideoSize(int width, int height) {
        this.width = width;
        this.height = height;
    }

    @Override
    public String toString() {
        return "VideoSize{" +
                "width=" + width +
                ", height=" + height +
                '}';
    }
}

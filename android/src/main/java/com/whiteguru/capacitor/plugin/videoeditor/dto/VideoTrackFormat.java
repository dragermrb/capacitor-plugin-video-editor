package com.whiteguru.capacitor.plugin.videoeditor.dto;

import androidx.annotation.NonNull;

public class VideoTrackFormat extends MediaTrackFormat {
    public int width;
    public int height;
    public int bitrate;
    public int frameRate;
    public int keyFrameInterval;
    public long duration;
    public int rotation;

    public VideoTrackFormat(int index, @NonNull String mimeType) {
        super(index, mimeType);
    }

    public VideoTrackFormat(@NonNull VideoTrackFormat videoTrackFormat) {
        super(videoTrackFormat);
        this.width = videoTrackFormat.width;
        this.height = videoTrackFormat.height;
        this.bitrate = videoTrackFormat.bitrate;
        this.frameRate = videoTrackFormat.frameRate;
        this.keyFrameInterval = videoTrackFormat.keyFrameInterval;
        this.duration = videoTrackFormat.duration;
        this.rotation = videoTrackFormat.rotation;
    }
}

package com.whiteguru.capacitor.plugin.videoeditor.dto;

import androidx.annotation.NonNull;

public class MediaTrackFormat {

    public int index;
    public String mimeType;

    MediaTrackFormat(int index, @NonNull String mimeType) {
        this.index = index;
        this.mimeType = mimeType;
    }

    MediaTrackFormat(@NonNull MediaTrackFormat mediaTrackFormat) {
        this.index = mediaTrackFormat.index;
        this.mimeType = mediaTrackFormat.mimeType;
    }
}

package com.whiteguru.capacitor.plugin.videoeditor.dto;

import androidx.annotation.NonNull;

public class AudioTrackFormat extends MediaTrackFormat {

    public int channelCount;
    public int samplingRate;
    public int bitrate;
    public long duration;

    public AudioTrackFormat(int index, @NonNull String mimeType) {
        super(index, mimeType);
    }

    public AudioTrackFormat(@NonNull AudioTrackFormat audioTrackFormat) {
        super(audioTrackFormat);
        this.channelCount = audioTrackFormat.channelCount;
        this.samplingRate = audioTrackFormat.samplingRate;
        this.bitrate = audioTrackFormat.bitrate;
        this.duration = audioTrackFormat.duration;
    }
}

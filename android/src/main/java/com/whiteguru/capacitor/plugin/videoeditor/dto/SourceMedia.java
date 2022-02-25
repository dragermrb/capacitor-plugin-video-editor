package com.whiteguru.capacitor.plugin.videoeditor.dto;

import static com.whiteguru.capacitor.plugin.videoeditor.MediaFormatUtils.getInt;
import static com.whiteguru.capacitor.plugin.videoeditor.MediaFormatUtils.getLong;

import android.content.Context;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.media.MediaMetadataRetriever;
import android.net.Uri;

import androidx.annotation.NonNull;

import com.linkedin.android.litr.utils.MediaFormatUtils;
import com.linkedin.android.litr.utils.TranscoderUtils;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class SourceMedia {

    public Uri uri;
    public long size;
    public float durationMs; // in miliSeconds

    public List<MediaTrackFormat> tracks = new ArrayList<>();

    public SourceMedia(Context context, @NonNull Uri uri) throws IOException {
        this.loadUri(context, uri);
    }

    @NonNull
    public void loadUri(Context context, @NonNull Uri uri) throws IOException {
        this.uri = uri;
        this.size = TranscoderUtils.getSize(context, uri);
        this.durationMs = getMediaDuration(context, uri) / 1000f;

        try {
            MediaExtractor mediaExtractor = new MediaExtractor();
            mediaExtractor.setDataSource(context, uri, null);
            this.tracks = new ArrayList<>(mediaExtractor.getTrackCount());

            for (int track = 0; track < mediaExtractor.getTrackCount(); track++) {
                MediaFormat mediaFormat = mediaExtractor.getTrackFormat(track);
                String mimeType = mediaFormat.getString(MediaFormat.KEY_MIME);
                if (mimeType == null) {
                    continue;
                }

                if (mimeType.startsWith("video")) {
                    VideoTrackFormat videoTrack = new VideoTrackFormat(track, mimeType);
                    videoTrack.width = getInt(mediaFormat, MediaFormat.KEY_WIDTH);
                    videoTrack.height = getInt(mediaFormat, MediaFormat.KEY_HEIGHT);
                    videoTrack.duration = getLong(mediaFormat, MediaFormat.KEY_DURATION);
                    videoTrack.frameRate = MediaFormatUtils.getFrameRate(mediaFormat, -1).intValue();
                    videoTrack.keyFrameInterval = MediaFormatUtils.getIFrameInterval(mediaFormat, -1).intValue();
                    videoTrack.rotation = getInt(mediaFormat, MediaFormat.KEY_ROTATION, 0);
                    videoTrack.bitrate = getInt(mediaFormat, MediaFormat.KEY_BIT_RATE);
                    this.tracks.add(videoTrack);
                } else if (mimeType.startsWith("audio")) {
                    AudioTrackFormat audioTrack = new AudioTrackFormat(track, mimeType);
                    audioTrack.channelCount = getInt(mediaFormat, MediaFormat.KEY_CHANNEL_COUNT);
                    audioTrack.samplingRate = getInt(mediaFormat, MediaFormat.KEY_SAMPLE_RATE);
                    audioTrack.duration = getLong(mediaFormat, MediaFormat.KEY_DURATION);
                    audioTrack.bitrate = getInt(mediaFormat, MediaFormat.KEY_BIT_RATE);
                    this.tracks.add(audioTrack);
                } else {
                    this.tracks.add(new GenericTrackFormat(track, mimeType));
                }
            }
        } catch (IOException ex) {
            throw new IOException("Failed to extract sourceMedia");
        }
    }

    public List<VideoTrackFormat> getVideoTracks(){
        List<VideoTrackFormat> videoTracks = new ArrayList<>();

        for (MediaTrackFormat track : tracks) {
            if (track instanceof VideoTrackFormat) {
                videoTracks.add((VideoTrackFormat) track);
            }
        }

        return videoTracks;
    }

    /**
     * Returns media duration in microSeconds
     * @param context Activity context
     * @param uri Media uri
     * @return media duration in microSeconds
     */
    private long getMediaDuration(Context context, @NonNull Uri uri) {
        MediaMetadataRetriever mediaMetadataRetriever = new MediaMetadataRetriever();
        mediaMetadataRetriever.setDataSource(context, uri);
        String durationStr = mediaMetadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
        return Long.parseLong(durationStr) * 1000;
    }
}

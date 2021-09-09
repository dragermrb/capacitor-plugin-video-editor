package com.whiteguru.capacitor.plugin.videoeditor;

import android.graphics.Bitmap;
import android.media.MediaMetadataRetriever;

import com.otaliastudios.transcoder.Transcoder;
import com.otaliastudios.transcoder.TranscoderListener;
import com.otaliastudios.transcoder.source.ClipDataSource;
import com.otaliastudios.transcoder.source.DataSource;
import com.otaliastudios.transcoder.source.FilePathDataSource;
import com.otaliastudios.transcoder.strategy.DefaultAudioStrategy;
import com.otaliastudios.transcoder.strategy.DefaultVideoStrategy;
import com.otaliastudios.transcoder.validator.WriteVideoValidator;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class VideoEditor {
    public void edit(File srcFile, File outFile, TrimSettings trimSettings, TranscodeSettings transcodeSettings, TranscoderListener listenerListener) throws IOException {
        DataSource source = new FilePathDataSource(srcFile.getAbsolutePath());
        source.initialize();
        long durationUs = source.getDurationUs();

        if (durationUs == 0) {
            throw new IllegalArgumentException("Input video with 0 duration");
        }

        long startsAtUs = trimSettings.getStartsAt() * 1000 * 1000;
        long endsAtUs = trimSettings.getEndsAt() == 0 ? durationUs : Math.min(durationUs, trimSettings.getEndsAt() * 1000 * 1000);

        DataSource clip = new ClipDataSource(
                source,
                startsAtUs,
                endsAtUs
        );

        DefaultAudioStrategy audioStrategy = DefaultAudioStrategy.builder()
                .channels(DefaultAudioStrategy.CHANNELS_AS_INPUT)
                .sampleRate(DefaultAudioStrategy.SAMPLE_RATE_AS_INPUT)
                .bitRate(DefaultAudioStrategy.BITRATE_UNKNOWN)
                .build();

        DefaultVideoStrategy videoStrategy;
        if (transcodeSettings.isKeepAspectRatio()) {
            int mostSize = transcodeSettings.getWidth() == 0 && transcodeSettings.getHeight() == 0
                    ? 1280
                    : Math.max(transcodeSettings.getWidth(), transcodeSettings.getHeight());

            videoStrategy = DefaultVideoStrategy.atMost(mostSize).build();
        } else {
            if (transcodeSettings.getWidth() > 0 && transcodeSettings.getHeight() > 0) {
                videoStrategy = DefaultVideoStrategy.exact(
                        transcodeSettings.getWidth(),
                        transcodeSettings.getHeight()
                ).build();
            } else {
                videoStrategy = DefaultVideoStrategy.exact(1280, 720).build();
            }
        }

        Transcoder.into(outFile.getAbsolutePath())
                .addDataSource(clip)
                .setAudioTrackStrategy(audioStrategy)
                .setVideoTrackStrategy(videoStrategy)
                .setValidator(new WriteVideoValidator())
                .setListener(listenerListener).transcode();
    }

    public void thumbnail(File srcFile, File outFile, int at, int width, int height) throws IOException {

        int quality = 80;

        MediaMetadataRetriever mmr = new MediaMetadataRetriever();
        mmr.setDataSource(srcFile.getAbsolutePath());

        Bitmap bitmap = mmr.getFrameAtTime(at * 1000 * 1000);

        if (width > 0 || height > 0) {
            int videoWidth = bitmap.getWidth();
            int videoHeight = bitmap.getHeight();
            double aspectRatio = (double) videoWidth / (double) videoHeight;

            int scaleWidth = Double.valueOf(height * aspectRatio).intValue();
            int scaleHeight = Double.valueOf(scaleWidth / aspectRatio).intValue();

            final Bitmap resizedBitmap = Bitmap.createScaledBitmap(bitmap, scaleWidth, scaleHeight, false);
            bitmap.recycle();
            bitmap = resizedBitmap;
        }

        OutputStream outStream = new FileOutputStream(outFile);
        bitmap.compress(Bitmap.CompressFormat.JPEG, quality, outStream);
    }
}

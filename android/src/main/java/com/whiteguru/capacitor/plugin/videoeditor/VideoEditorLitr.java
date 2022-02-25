package com.whiteguru.capacitor.plugin.videoeditor;

import android.content.Context;
import android.graphics.Bitmap;
import android.media.MediaCodecInfo;
import android.media.MediaFormat;
import android.media.MediaMetadataRetriever;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.getcapacitor.Logger;
import com.linkedin.android.litr.MediaTransformer;
import com.linkedin.android.litr.TransformationListener;
import com.linkedin.android.litr.TransformationOptions;
import com.linkedin.android.litr.analytics.TrackTransformationInfo;
import com.linkedin.android.litr.io.MediaRange;
import com.whiteguru.capacitor.plugin.videoeditor.dto.SourceMedia;
import com.whiteguru.capacitor.plugin.videoeditor.dto.VideoSize;
import com.whiteguru.capacitor.plugin.videoeditor.dto.VideoTrackFormat;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.List;
import java.util.UUID;

public class VideoEditorLitr {
    static final int DEFAULT_VIDEO_FRAMERATE = 30;
    static final int DEFAULT_VIDEO_KEY_FRAME_INTERVAL = 5;
    static final int DEFAULT_AUDIO_BITRATE = 128000;
    static final int DEFAULT_AUDIO_CHANNEL_COUNT = 2;
    static final int DEFAULT_AUDIO_SAMPLE_RATE = 44100;
    static final String DEFAULT_AUDIO_MIME = "audio/mp4a-latm";

    // For AVC this should be a reasonable default.
    // https://stackoverflow.com/a/5220554/4288782
    public static long estimateVideoBitRate(int width, int height, int frameRate) {
        return (long) (0.07F * 2 * width * height * frameRate);
    }

    public void edit(Context context, File srcFile, File outFile, TrimSettings trimSettings, TranscodeSettings transcodeSettings, TransformationListener videoTransformationListener) throws IOException {
        MediaTransformer mediaTransformer = new MediaTransformer(context);

        String requestId = UUID.randomUUID().toString();
        Uri sourceVideoUri = Uri.fromFile(srcFile);
        String targetVideoFilePath = outFile.getPath();
        SourceMedia sourceMedia = new SourceMedia(context, sourceVideoUri);

        // Resolution
        List<VideoTrackFormat> videoTracks = sourceMedia.getVideoTracks();
        if (videoTracks.size() == 0) {
            throw new IOException("Video track not found");
        }
        VideoSize targetVideoSize = calculateTargetVideoSize(videoTracks.get(0), transcodeSettings);

        Logger.debug("Source video size: " + (new VideoSize(videoTracks.get(0).width, videoTracks.get(0).height)));
        Logger.debug("Target video size: " + targetVideoSize);

        // Trim
        long startsAtUs = trimSettings.getStartsAt() * 1000;
        long endsAtUs = trimSettings.getEndsAt() == 0 ? Long.MAX_VALUE : trimSettings.getEndsAt() * 1000;

        TransformationOptions transformationOptions = new TransformationOptions.Builder()
                .setGranularity(MediaTransformer.GRANULARITY_DEFAULT)
                .setSourceMediaRange(new MediaRange(startsAtUs, endsAtUs))
                .build();

        // Video codec config
        MediaFormat targetVideoFormat = new MediaFormat();
        targetVideoFormat.setString(MediaFormat.KEY_MIME, "video/avc");
        targetVideoFormat.setInteger(MediaFormat.KEY_WIDTH, targetVideoSize.width);
        targetVideoFormat.setInteger(MediaFormat.KEY_HEIGHT, targetVideoSize.height);
        targetVideoFormat.setInteger(MediaFormat.KEY_FRAME_RATE, DEFAULT_VIDEO_FRAMERATE);
        targetVideoFormat.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, DEFAULT_VIDEO_KEY_FRAME_INTERVAL);
        targetVideoFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface);
        targetVideoFormat.setInteger(MediaFormat.KEY_BIT_RATE, (int) estimateVideoBitRate(
                targetVideoSize.width,
                targetVideoSize.height,
                DEFAULT_VIDEO_FRAMERATE
        ));

        // Audio codec config
        MediaFormat targetAudioFormat = new MediaFormat();
        targetAudioFormat.setString(MediaFormat.KEY_MIME, DEFAULT_AUDIO_MIME);
        targetAudioFormat.setInteger(MediaFormat.KEY_CHANNEL_COUNT, DEFAULT_AUDIO_CHANNEL_COUNT);
        targetAudioFormat.setInteger(MediaFormat.KEY_SAMPLE_RATE, DEFAULT_AUDIO_SAMPLE_RATE);
        targetAudioFormat.setInteger(MediaFormat.KEY_BIT_RATE, DEFAULT_AUDIO_BITRATE);

        TransformationListener listener = new TransformationListener() {
            @Override
            public void onStarted(@NonNull String id) {
                videoTransformationListener.onStarted(id);
            }

            @Override
            public void onProgress(@NonNull String id, float progress) {
                videoTransformationListener.onProgress(id, progress);
            }

            @Override
            public void onCompleted(@NonNull String id, @Nullable List<TrackTransformationInfo> trackTransformationInfos) {
                videoTransformationListener.onCompleted(id, trackTransformationInfos);

                mediaTransformer.release();
            }

            @Override
            public void onCancelled(@NonNull String id, @Nullable List<TrackTransformationInfo> trackTransformationInfos) {
                videoTransformationListener.onCancelled(id, trackTransformationInfos);

                mediaTransformer.release();
            }

            @Override
            public void onError(@NonNull String id, @Nullable Throwable cause, @Nullable List<TrackTransformationInfo> trackTransformationInfos) {
                videoTransformationListener.onError(id, cause, trackTransformationInfos);

                mediaTransformer.release();
            }
        };

        mediaTransformer.transform(
                requestId,
                sourceVideoUri,
                targetVideoFilePath,
                targetVideoFormat,
                targetAudioFormat,
                listener,
                transformationOptions
        );
    }

    public void thumbnail(Context context, Uri srcUri, File outFile, int at, int width, int height) throws IOException {

        int quality = 80;

        MediaMetadataRetriever mmr = new MediaMetadataRetriever();
        mmr.setDataSource(context, srcUri);

        Bitmap bitmap = mmr.getFrameAtTime((long) at * 1000 * 1000);

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

    private VideoSize calculateTargetVideoSize(VideoTrackFormat videoTrackFormat, TranscodeSettings transcodeSettings) {
        if (transcodeSettings.isKeepAspectRatio()) {
            int mostSize = transcodeSettings.getWidth() == 0 && transcodeSettings.getHeight() == 0
                    ? 1280
                    : Math.max(transcodeSettings.getWidth(), transcodeSettings.getHeight());

            return calculateVideoSizeAtMost(videoTrackFormat, mostSize);
        } else {
            if (transcodeSettings.getWidth() > 0 && transcodeSettings.getHeight() > 0) {
                return new VideoSize(
                        transcodeSettings.getWidth(),
                        transcodeSettings.getHeight()
                );
            } else {
                return calculateVideoSizeAtMost(videoTrackFormat, 720);
            }
        }
    }

    private VideoSize calculateVideoSizeAtMost(VideoTrackFormat videoTrackFormat, int mostSize) {
        int sourceMajor = Math.max(videoTrackFormat.width, videoTrackFormat.height);

        if (sourceMajor <= mostSize) {
            // No resize needed
            return new VideoSize(videoTrackFormat.width, videoTrackFormat.height);
        }

        int outWidth;
        int outHeight;
        if (videoTrackFormat.width >= videoTrackFormat.height) {
            // Landscape
            float inputRatio = (float) videoTrackFormat.height / videoTrackFormat.width;

            outWidth = mostSize;
            outHeight = (int) ((float) mostSize * inputRatio);
        } else {
            // Portrait
            float inputRatio = (float) videoTrackFormat.width / videoTrackFormat.height;

            outHeight = mostSize;
            outWidth = (int) ((float) mostSize * inputRatio);
        }

        if (outWidth % 2 != 0) {
            outWidth--;
        }
        if (outHeight % 2 != 0) {
            outHeight--;
        }

        return new VideoSize(outWidth, outHeight);
    }
}

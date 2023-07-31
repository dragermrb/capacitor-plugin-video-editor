package com.whiteguru.capacitor.plugin.videoeditor;

import android.Manifest;
import android.content.Context;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.getcapacitor.JSObject;
import com.getcapacitor.Logger;
import com.getcapacitor.PermissionState;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;

import android.util.Log;

import com.linkedin.android.litr.analytics.TrackTransformationInfo;
import com.linkedin.android.litr.TransformationListener;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.List;

@CapacitorPlugin(
        name = "VideoEditor",
        permissions = {
                @Permission(
                        strings = {Manifest.permission.READ_EXTERNAL_STORAGE},
                        alias = VideoEditorPlugin.STORAGE
                ),
                @Permission(
                        strings = {Manifest.permission.READ_MEDIA_VIDEO},
                        alias = VideoEditorPlugin.MEDIA_VIDEO
                )

        }
)
public class VideoEditorPlugin extends Plugin {

    // Permission alias constants
    static final String STORAGE = "storage";
    static final String MEDIA_VIDEO = "media_video";

    // Message constants
    private static final String PERMISSION_DENIED_ERROR_STORAGE = "User denied access to storage";

    @PluginMethod
    public void edit(PluginCall call) {
        editLitr(call);
    }

    public void editLitr(PluginCall call) {
        String path = call.getString("path");
        JSObject trim = call.getObject("trim", new JSObject());
        JSObject transcode = call.getObject("transcode", new JSObject());

        if (path == null) {
            call.reject("Input file path is required");
            return;
        }

        if (checkStoragePermissions(call)) {
            Uri inputUri = Uri.parse(path);
            File inputFile = new File(inputUri.getPath());

            if (!inputFile.canRead()) {
                call.reject("Cannot read input file: " + inputFile.getAbsolutePath());
                return;
            }

            String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.ENGLISH).format(new Date());
            String fileName = "VID_" + timeStamp + "_";
            File storageDir = getContext().getCacheDir();

            execute(
                    () -> {
                        try {
                            File outputFile = File.createTempFile(fileName, ".mp4", storageDir);

                            VideoEditorLitr implementation = new VideoEditorLitr();

                            TrimSettings trimSettings = new TrimSettings(trim.getInteger("startsAt", 0), trim.getInteger("endsAt", 0));

                            TranscodeSettings transcodeSettings = new TranscodeSettings(
                                    transcode.getInteger("height", 0),
                                    transcode.getInteger("width", 0),
                                    transcode.getBoolean("keepAspectRatio", true)
                            );

                            TransformationListener videoTransformationListener = new TransformationListener() {
                                @Override
                                public void onStarted(@NonNull String id) {
                                    Logger.debug("Transcode started");
                                }

                                @Override
                                public void onProgress(@NonNull String id, float progress) {
                                    Logger.debug("Transcode running " + progress);

                                    JSObject ret = new JSObject();
                                    ret.put("progress", progress);

                                    notifyListeners("transcodeProgress", ret);
                                }

                                @Override
                                public void onCompleted(@NonNull String id, @Nullable List<TrackTransformationInfo> trackTransformationInfos) {
                                    Logger.debug("Transcode completed");

                                    JSObject ret = new JSObject();
                                    ret.put("file", createMediaFile(outputFile));
                                    call.resolve(ret);
                                }

                                @Override
                                public void onCancelled(@NonNull String id, @Nullable List<TrackTransformationInfo> trackTransformationInfos) {
                                    Logger.debug("Transcode cancelled");

                                    call.reject("Transcode canceled");
                                }

                                @Override
                                public void onError(@NonNull String id, @Nullable Throwable cause, @Nullable List<TrackTransformationInfo> trackTransformationInfos) {
                                    Logger.debug("Transcode error: " + (cause != null ? cause.getMessage() : ""));

                                    call.reject("Transcode failed: " + (cause != null ? cause.getMessage() : ""));
                                }
                            };

                            implementation.edit(getContext(), inputFile, outputFile, trimSettings, transcodeSettings, videoTransformationListener);
                        } catch (Exception e) {
                            call.reject(e.getMessage());
                        }
                    }
            );
        }
    }

    @PluginMethod
    public void thumbnail(PluginCall call) {
        String path = call.getString("path");
        int atMs = call.getInt("at", 0);
        int width = call.getInt("width", 0);
        int height = call.getInt("height", 0);

        if (path == null) {
            call.reject("Input file path is required");
            return;
        }

        if (checkStoragePermissions(call)) {
            Uri inputUri = Uri.parse(path);

            String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.ENGLISH).format(new Date());
            String fileName = "TH_" + timeStamp + "_";
            File storageDir = getContext().getCacheDir();

            File outputFile = null;

            try {
                outputFile = File.createTempFile(fileName, ".jpg", storageDir);

                VideoEditorLitr implementation = new VideoEditorLitr();

                implementation.thumbnail(this.getContext(), inputUri, outputFile, atMs, width, height);
            } catch (Exception e) {
                call.reject(e.getMessage());
                return;
            }

            JSObject ret = new JSObject();
            ret.put("file", createMediaFile(outputFile));
            call.resolve(ret);
        }
    }

    private boolean checkStoragePermissions(PluginCall call) {
        if (getPermissionState(STORAGE) != PermissionState.GRANTED) {
            requestPermissionForAlias(STORAGE, call, "storagePermissionsCallback");
            return false;
        }
        return true;
    }

    /**
     * Completes the plugin call after a storage permission request
     *
     * @param call the plugin call
     */
    @PermissionCallback
    private void storagePermissionsCallback(PluginCall call) {
        Log.d("TAG", "Swag and then the getPermissionState(STORAGE) result: " + getPermissionState(STORAGE));
        if (getPermissionState(STORAGE) != PermissionState.GRANTED) {
            Logger.debug(getLogTag(), "User denied photos permission: " + getPermissionState(STORAGE).toString());
            call.reject(PERMISSION_DENIED_ERROR_STORAGE);
            return;
        }

        switch (call.getMethodName()) {
            case "edit":
                edit(call);
                break;
            case "thumbnail":
                thumbnail(call);
                break;
        }
    }

    /**
     * Creates a JSObject that represents a File from the Uri
     *
     * @param file the File of the audio/image/video
     * @return a JSObject that represents a File
     */
    private JSObject createMediaFile(File file) {
        Context context = getBridge().getActivity().getApplicationContext();
        Uri uri = Uri.fromFile(file);
        String mimeType = context.getContentResolver().getType(uri);

        JSObject ret = new JSObject();

        ret.put("name", file.getName());
        ret.put("path", uri);
        ret.put("type", mimeType);
        ret.put("size", file.length());

        return ret;
    }
}

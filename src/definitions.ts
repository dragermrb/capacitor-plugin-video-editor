import type { PluginListenerHandle } from '@capacitor/core';

export interface VideoEditorPlugin {
  edit(options: EditOptions): Promise<MediaFileResult>;
  thumbnail(options: ThumbnailOptions): Promise<MediaFileResult>;
  addListener(
    eventName: 'transcodeProgress',
    listenerFunc: (info: ProgressInfo) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
}

export interface EditOptions {
  path: string;
  trim?: TrimOptions;
  transcode?: TranscodeOptions;
}

export interface TrimOptions {
  /**
   * StartsAt in milliseconds
   */
  startsAt?: number;
  /**
   * EndsAt in milliseconds
   */
  endsAt?: number;
}

export interface TranscodeOptions {
  height?: number;
  width?: number;
  /**
   * Keep Aspect Ratio, default `true`
   */
  keepAspectRatio?: boolean;
  /**
   * Frames per second, default `30`
   */
  fps?: number;
}

export interface ThumbnailOptions {
  path: string;
  /**
   * The time position where the frame will be retrieved in milliseconds.
   */
  at?: number;
  width?: number;
  height?: number;
}

export interface MediaFileResult {
  file: MediaFile;
}

export interface MediaFile {
  /**
   * The name of the file, without path information.
   */
  name: string;
  /**
   * The full path of the file, including the name.
   */
  path: string;
  /**
   * The file's mime type
   */
  type: string;

  /**
   * The size of the file, in bytes.
   */
  size: number;
}

export interface ProgressInfo {
  progress: number;
}

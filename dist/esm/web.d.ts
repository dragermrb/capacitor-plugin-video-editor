import { WebPlugin } from '@capacitor/core';
import type { EditOptions, MediaFileResult, ThumbnailOptions, VideoEditorPlugin } from './definitions';
export declare class VideoEditorWeb extends WebPlugin implements VideoEditorPlugin {
    edit(options: EditOptions): Promise<MediaFileResult>;
    thumbnail(options: ThumbnailOptions): Promise<MediaFileResult>;
}

import { WebPlugin } from '@capacitor/core';

import type {
  EditOptions,
  MediaFileResult,
  ThumbnailOptions,
  VideoEditorPlugin,
} from './definitions';

export class VideoEditorWeb extends WebPlugin implements VideoEditorPlugin {
  edit(options: EditOptions): Promise<MediaFileResult> {
    console.log('edit', options);

    throw this.unimplemented('Not implemented on web.');
  }

  thumbnail(options: ThumbnailOptions): Promise<MediaFileResult> {
    console.log('thumbnail', options);

    throw this.unimplemented('Not implemented on web.');
  }
}

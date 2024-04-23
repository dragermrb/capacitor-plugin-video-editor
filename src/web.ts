import { WebPlugin } from '@capacitor/core';
import type { PluginListenerHandle } from '@capacitor/core/types/definitions';

import type {
  EditOptions,
  MediaFileResult,
  ProgressInfo,
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

  addListener(
    eventName: 'transcodeProgress',
    _listenerFunc: (info: ProgressInfo) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle {
    console.log('addListener', eventName);

    throw this.unimplemented('Not implemented on web.');
  }
}

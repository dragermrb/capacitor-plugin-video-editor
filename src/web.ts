import { WebPlugin } from '@capacitor/core';

import type { VideoEditorPlugin } from './definitions';

export class VideoEditorWeb extends WebPlugin implements VideoEditorPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}

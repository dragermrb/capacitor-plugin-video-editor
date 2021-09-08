import { registerPlugin } from '@capacitor/core';

import type { VideoEditorPlugin } from './definitions';

const VideoEditor = registerPlugin<VideoEditorPlugin>('VideoEditor', {
  web: () => import('./web').then(m => new m.VideoEditorWeb()),
});

export * from './definitions';
export { VideoEditor };

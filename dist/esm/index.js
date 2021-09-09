import { registerPlugin } from '@capacitor/core';
const VideoEditor = registerPlugin('VideoEditor', {
    web: () => import('./web').then(m => new m.VideoEditorWeb()),
});
export * from './definitions';
export { VideoEditor };
//# sourceMappingURL=index.js.map
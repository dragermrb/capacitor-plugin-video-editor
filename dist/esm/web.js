import { WebPlugin } from '@capacitor/core';
export class VideoEditorWeb extends WebPlugin {
    edit(options) {
        console.log('edit', options);
        throw this.unimplemented('Not implemented on web.');
    }
    thumbnail(options) {
        console.log('thumbnail', options);
        throw this.unimplemented('Not implemented on web.');
    }
}
//# sourceMappingURL=web.js.map
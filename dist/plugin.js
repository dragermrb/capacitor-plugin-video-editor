var capacitorVideoEditor = (function (exports, core) {
    'use strict';

    const VideoEditor = core.registerPlugin('VideoEditor', {
        web: () => Promise.resolve().then(function () { return web; }).then(m => new m.VideoEditorWeb()),
    });

    class VideoEditorWeb extends core.WebPlugin {
        edit(options) {
            console.log('edit', options);
            throw this.unimplemented('Not implemented on web.');
        }
        thumbnail(options) {
            console.log('thumbnail', options);
            throw this.unimplemented('Not implemented on web.');
        }
    }

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        VideoEditorWeb: VideoEditorWeb
    });

    exports.VideoEditor = VideoEditor;

    Object.defineProperty(exports, '__esModule', { value: true });

    return exports;

}({}, capacitorExports));
//# sourceMappingURL=plugin.js.map

# capacitor-plugin-video-editor

Capacitor plugin to edit videos

## Install (Capacitor 6.x)

```bash
npm install @whiteguru/capacitor-plugin-video-editor
npx cap sync
```

### or for Capacitor 5.x

```bash
npm install @whiteguru/capacitor-plugin-video-editor@^5.0.6
npx cap sync
```

### or for Capacitor 4.x

```bash
npm install @whiteguru/capacitor-plugin-video-editor@^4.0.4
npx cap sync
```

### or for Capacitor 3.x

```bash
npm install @whiteguru/capacitor-plugin-video-editor@^3.0.1
npx cap sync
```

## Android

This API requires the following permissions be added to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
```

You can also specify those permissions only for the Android versions where they will be requested:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
```

The storage permissions are for reading video files.

Read about [Setting Permissions](https://capacitorjs.com/docs/android/configuration#setting-permissions) in the [Android Guide](https://capacitorjs.com/docs/android) for more information on setting Android permissions.

## Example

```typescript
import {
  VideoEditor,
  MediaFileResult,
} from '@whiteguru/capacitor-plugin-video-editor';

const sourceVideoPath =
  'file:///var/mobile/Containers/Data/...../sourceVideo.mp4';

// Transcode with progress
const progressListener = await VideoEditor.addListener(
  'transcodeProgress',
  info => console.log('info', info),
);

VideoEditor.edit({
  path: sourceVideoPath,
  transcode: {
    width: 720,
    height: 480,
    keepAspectRatio: true,
    fps: 30,
  },
  trim: {
    startsAt: 3 * 1000, // from 00:03
    endsAt: 10 * 1000, // to 00:10
  },
}).then(
  (mediaFileResult: MediaFileResult) => {
    progressListener.remove();

    console.log('mediaPath', mediaFileResult.file.path);
  },
  error => {
    console.error('error', error);
  },
);

// Thumbnail
VideoEditor.thumbnail({
  path: sourceVideoPath,
  width: 150,
  height: 150,
  at: 4 * 1000, // at 00:04
}).then(
  (thumbMediaFileResult: MediaFileResult) => {
    console.log('thumbPath', thumbMediaFileResult.file.path);
  },
  error => {
    console.error('error', error);
  },
);
```

## API

<docgen-index>

* [`edit(...)`](#edit)
* [`thumbnail(...)`](#thumbnail)
* [`addListener('transcodeProgress', ...)`](#addlistenertranscodeprogress)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### edit(...)

```typescript
edit(options: EditOptions) => Promise<MediaFileResult>
```

| Param         | Type                                                |
| ------------- | --------------------------------------------------- |
| **`options`** | <code><a href="#editoptions">EditOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#mediafileresult">MediaFileResult</a>&gt;</code>

--------------------


### thumbnail(...)

```typescript
thumbnail(options: ThumbnailOptions) => Promise<MediaFileResult>
```

| Param         | Type                                                          |
| ------------- | ------------------------------------------------------------- |
| **`options`** | <code><a href="#thumbnailoptions">ThumbnailOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#mediafileresult">MediaFileResult</a>&gt;</code>

--------------------


### addListener('transcodeProgress', ...)

```typescript
addListener(eventName: 'transcodeProgress', listenerFunc: (info: ProgressInfo) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

| Param              | Type                                                                     |
| ------------------ | ------------------------------------------------------------------------ |
| **`eventName`**    | <code>'transcodeProgress'</code>                                         |
| **`listenerFunc`** | <code>(info: <a href="#progressinfo">ProgressInfo</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### Interfaces


#### MediaFileResult

| Prop       | Type                                            |
| ---------- | ----------------------------------------------- |
| **`file`** | <code><a href="#mediafile">MediaFile</a></code> |


#### MediaFile

| Prop       | Type                | Description                                     |
| ---------- | ------------------- | ----------------------------------------------- |
| **`name`** | <code>string</code> | The name of the file, without path information. |
| **`path`** | <code>string</code> | The full path of the file, including the name.  |
| **`type`** | <code>string</code> | The file's mime type                            |
| **`size`** | <code>number</code> | The size of the file, in bytes.                 |


#### EditOptions

| Prop            | Type                                                          |
| --------------- | ------------------------------------------------------------- |
| **`path`**      | <code>string</code>                                           |
| **`trim`**      | <code><a href="#trimoptions">TrimOptions</a></code>           |
| **`transcode`** | <code><a href="#transcodeoptions">TranscodeOptions</a></code> |


#### TrimOptions

| Prop           | Type                | Description              |
| -------------- | ------------------- | ------------------------ |
| **`startsAt`** | <code>number</code> | StartsAt in milliseconds |
| **`endsAt`**   | <code>number</code> | EndsAt in milliseconds   |


#### TranscodeOptions

| Prop                  | Type                 | Description                       |
| --------------------- | -------------------- | --------------------------------- |
| **`height`**          | <code>number</code>  |                                   |
| **`width`**           | <code>number</code>  |                                   |
| **`keepAspectRatio`** | <code>boolean</code> | Keep Aspect Ratio, default `true` |
| **`fps`**             | <code>number</code>  | Frames per second, default `30`   |


#### ThumbnailOptions

| Prop         | Type                | Description                                                          |
| ------------ | ------------------- | -------------------------------------------------------------------- |
| **`path`**   | <code>string</code> |                                                                      |
| **`at`**     | <code>number</code> | The time position where the frame will be retrieved in milliseconds. |
| **`width`**  | <code>number</code> |                                                                      |
| **`height`** | <code>number</code> |                                                                      |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### ProgressInfo

| Prop           | Type                |
| -------------- | ------------------- |
| **`progress`** | <code>number</code> |

</docgen-api>

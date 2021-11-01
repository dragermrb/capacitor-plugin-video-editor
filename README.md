# capacitor-plugin-video-editor

Capacitor plugin to edit videos

## Install

```bash
npm install @whiteguru/capacitor-plugin-video-editor
npx cap sync
```

## API

<docgen-index>

* [`edit(...)`](#edit)
* [`thumbnail(...)`](#thumbnail)
* [`addListener(...)`](#addlistener)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### edit(...)

```typescript
edit(options: EditOptions) => any
```

| Param         | Type                                                |
| ------------- | --------------------------------------------------- |
| **`options`** | <code><a href="#editoptions">EditOptions</a></code> |

**Returns:** <code>any</code>

--------------------


### thumbnail(...)

```typescript
thumbnail(options: ThumbnailOptions) => any
```

| Param         | Type                                                          |
| ------------- | ------------------------------------------------------------- |
| **`options`** | <code><a href="#thumbnailoptions">ThumbnailOptions</a></code> |

**Returns:** <code>any</code>

--------------------


### addListener(...)

```typescript
addListener(eventName: 'transcodeProgress', listenerFunc: (info: ProgressInfo) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

| Param              | Type                                                                     |
| ------------------ | ------------------------------------------------------------------------ |
| **`eventName`**    | <code>"transcodeProgress"</code>                                         |
| **`listenerFunc`** | <code>(info: <a href="#progressinfo">ProgressInfo</a>) =&gt; void</code> |

**Returns:** <code>any</code>

--------------------


### Interfaces


#### EditOptions

| Prop            | Type                                                                         |
| --------------- | ---------------------------------------------------------------------------- |
| **`path`**      | <code>string</code>                                                          |
| **`trim`**      | <code>{ startsAt?: number; endsAt?: number; }</code>                         |
| **`transcode`** | <code>{ height?: number; width?: number; keepAspectRatio?: boolean; }</code> |


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


#### ThumbnailOptions

| Prop         | Type                |
| ------------ | ------------------- |
| **`path`**   | <code>string</code> |
| **`at`**     | <code>number</code> |
| **`width`**  | <code>number</code> |
| **`height`** | <code>number</code> |


#### ProgressInfo

| Prop           | Type                |
| -------------- | ------------------- |
| **`progress`** | <code>number</code> |


#### PluginListenerHandle

| Prop         | Type                      |
| ------------ | ------------------------- |
| **`remove`** | <code>() =&gt; any</code> |

</docgen-api>

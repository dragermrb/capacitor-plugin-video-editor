import Foundation
import Capacitor
import MobileCoreServices

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(VideoEditorPlugin)
public class VideoEditorPlugin: CAPPlugin {
    private let implementation = VideoEditor()
    
    @objc func edit(_ call: CAPPluginCall) {
        let path = call.getString("path")?.replacingOccurrences(of: "file://", with: "");
        let trim = call.getObject("trim") ?? JSObject();
        let transcode = call.getObject("transcode") ?? JSObject();
        
        if (path == nil) {
            call.reject("Input file path is required");
            return;
        }
        
        do {
            let trimSettings = try TrimSettings(
                startsAt: (trim["startsAt"] ?? 0) as! CLong,
                endsAt: (trim["endsAt"] ?? 0) as! CLong
            );
            
            let transcodeSettings = try TranscodeSettings(
                height: (transcode["height"] ?? 0) as! Int,
                width: (transcode["width"] ?? 0) as! Int,
                keepAspectRatio: (transcode["keepAspectRatio"] ?? true) as! Bool
            );
            
            let outFile = self.getDestVideoUrl();
            
            DispatchQueue.main.async {
                self.implementation.edit(
                    srcFile: URL(fileURLWithPath: path!),
                    outFile: outFile,
                    trimSettings: trimSettings,
                    transcodeSettings: transcodeSettings,
                    completionHandler: { url in
                        call.resolve([
                            "file": self.createMediaFile(url: url),
                        ])
                    },
                    progressHandler: { [weak self] progress in
                        // User progress
                        self!.notifyListeners("transcodeProgress", data: ["progress": progress])
                    },
                    errorHandler: { error in
                        call.reject(error)
                    }
                );
            }
        } catch {
            call.reject("Invalid parameters")
        }
    }
    
    @objc func thumbnail(_ call: CAPPluginCall) {
        let path = call.getString("path");
        let atMs = call.getInt("at") ?? 0;
        let width = call.getInt("width") ?? 0;
        let height = call.getInt("height") ??  0;
        
        if (path == nil) {
            call.reject("Input file path is required");
            return;
        }
        
        let outFile = self.getDestImageUrl();
        
        do {
            try self.implementation.thumbnail(
                srcFile: URL(fileURLWithPath: path!),
                outFile: outFile,
                atMs: atMs,
                width: width,
                height: height
            );
            
            call.resolve([
                "file": self.createMediaFile(url: outFile),
            ]);
        } catch {
            call.reject("Invalid parameters")
        }
    }
    
    func getDestVideoUrl() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension("mp4")
    }
    
    func getDestImageUrl() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension("jpg")
    }
    
    func createMediaFile(url: URL) -> JSObject {
        let mimeType = self.getMimeType(url: url)
        var fileSize = 0
        
        do {
            let resources = try url.resourceValues(forKeys: [.fileSizeKey])
            fileSize = resources.fileSize!;
        } catch {
            //
        }
        
        var file = JSObject()
        
        file["name"] = url.lastPathComponent
        file["path"] = url.absoluteString
        file["type"] = mimeType
        file["size"] = fileSize
        
        return file;
    }
    
    func getMimeType(url: URL) -> String {
        let pathExtension = url.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}

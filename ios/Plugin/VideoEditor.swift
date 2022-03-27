import Foundation
import AVFoundation
import UIKit

@objc public class VideoEditor: NSObject {
    var exportSession: AVAssetExportSession!
    var exportProgressBarTimer = Timer()
    
    @objc public func edit(
        srcFile: URL,
        outFile: URL,
        trimSettings: TrimSettings,
        transcodeSettings: TranscodeSettings,
        completionHandler: @escaping (URL) -> (),
        progressHandler: @escaping (Float) -> (),
        errorHandler: @escaping (String) -> ()
    ) {
        let avAsset = AVURLAsset(url: srcFile, options: nil)
        let videoTrack = avAsset.tracks(withMediaType: AVMediaType.video).first!
        let mediaSize = videoTrack.naturalSize
        
        // Resolution
        let targetVideoSize:CGSize = calculateTargetVideoSize(sourceVideoSize: mediaSize, transcodeSettings: transcodeSettings);
        
        // Trim
        let start = CMTimeMake(value: Int64(trimSettings.getStartsAt()), timescale: 1000)
        let end = trimSettings.getEndsAt() > 0
            ? CMTimeMake(value: Int64(trimSettings.getEndsAt()), timescale: 1000)
            : avAsset.duration
        let duration = min((end - start), (avAsset.duration - start))
        let range = CMTimeRangeMake(start: start, duration: duration)
        
        // Exporter
        let exporter = SimpleSessionExporter(withAsset: avAsset)
        exporter.outputFileType = AVFileType.mp4
        exporter.outputURL = outFile
        exporter.timeRange = range
        
        exporter.videoOutputConfiguration = [
            AVVideoWidthKey: NSNumber(integerLiteral: Int(targetVideoSize.width)),
            AVVideoHeightKey: NSNumber(integerLiteral: Int(targetVideoSize.height)),
        ]
        
        exporter.export(
            completionHandler: { status in
                switch status {
                case .completed:
                    completionHandler(exporter.outputURL!)
                    break
                case .failed:
                    errorHandler("Failed to transcode")
                    break
                default:
                    errorHandler("Unknow export status: \(status)")
                }
            }
        )
    }
    
    @objc public func thumbnail(
        srcFile: URL,
        outFile: URL,
        at: Int,
        width: Int,
        height: Int
    ) throws {
        let asset = AVURLAsset(url: srcFile, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        let cgImage = try imgGenerator.copyCGImage(
            at: min(
                asset.duration,
                CMTimeMake(value: Int64(at), timescale: 1)
            ),
            actualTime: nil
        )
        let thumbnail = cropToBounds(
            image: UIImage(cgImage: cgImage),
            width: Double(width),
            height: Double(height)
        )
        
        if let data = thumbnail.jpegData(compressionQuality: 0.8) {
            try data.write(to: outFile)
        }
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    func getOrientationForTrack(avAsset: AVAsset) -> String {
        let videoTrack = avAsset.tracks(withMediaType: AVMediaType.video).first!
        let size = videoTrack.naturalSize
        let txf = videoTrack.preferredTransform
        
        if (size.width == txf.tx && size.height == txf.ty) {
            return "landscape";
        } else if (txf.tx == 0 && txf.ty == 0) {
            return "landscape";
        } else if (txf.tx == 0 && txf.ty == size.width) {
            return "portrait";
        }
        
        return "portrait";
    }
    
    func calculateTargetVideoSize(sourceVideoSize: CGSize, transcodeSettings: TranscodeSettings) -> CGSize {
        if (transcodeSettings.isKeepAspectRatio()) {
            let mostSize = transcodeSettings.getWidth() == 0 && transcodeSettings.getHeight() == 0
            ? 1280
            : max(transcodeSettings.getWidth(), transcodeSettings.getHeight());
            
            return calculateVideoSizeAtMost(sourceVideoSize: sourceVideoSize, mostSize: mostSize);
        } else {
            if (transcodeSettings.getWidth() > 0 && transcodeSettings.getHeight() > 0) {
                return CGSize(
                    width: transcodeSettings.getWidth(),
                    height: transcodeSettings.getHeight()
                );
            } else {
                return calculateVideoSizeAtMost(sourceVideoSize: sourceVideoSize, mostSize: 720);
            }
        }
    }
    
    func calculateVideoSizeAtMost(sourceVideoSize: CGSize, mostSize: Int) -> CGSize{
        let sourceMajor = Int(max(sourceVideoSize.width, sourceVideoSize.height));
        
        if (sourceMajor <= mostSize) {
            // No resize needed
            return CGSize(
                width: sourceVideoSize.width,
                height: sourceVideoSize.height
            );
        }
        
        var outWidth: Int;
        var outHeight: Int;
        if (sourceVideoSize.width >= sourceVideoSize.height) {
            // Landscape
            let inputRatio:Float = Float(sourceVideoSize.height) / Float(sourceVideoSize.width);
            
            outWidth = mostSize;
            outHeight = Int(Float(mostSize) * inputRatio);
        } else {
            // Portrait
            let inputRatio: Float = Float(sourceVideoSize.width) / Float(sourceVideoSize.width);
            
            outHeight = mostSize;
            outWidth = Int(Float(mostSize) * inputRatio);
        }
        
        if (outWidth % 2 != 0) {
            outWidth -= 1;
        }
        if (outHeight % 2 != 0) {
            outHeight -= 1;
        }
        
        return CGSize(
            width: outWidth,
            height: outHeight
        );
    }
}

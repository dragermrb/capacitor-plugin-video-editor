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
        let start = CMTimeMakeWithSeconds(Float64(trimSettings.getStartsAt()), preferredTimescale: 1)
        let end = trimSettings.getEndsAt() > 0
            ? CMTimeMakeWithSeconds(Float64(trimSettings.getEndsAt()), preferredTimescale: 1)
            : avAsset.duration
        let duration = min((end - start), (avAsset.duration - start))
        let range = CMTimeRangeMake(start: start, duration: duration)
        
        let videoTrack = avAsset.tracks(withMediaType: AVMediaType.video).first!
        let mediaSize = videoTrack.naturalSize
        
        var videoWidth = videoTrack.naturalSize.width
        var videoHeight = videoTrack.naturalSize.height
        
        // Desired size
        let outWidth = transcodeSettings.getWidth() != 0 ? CGFloat(transcodeSettings.getWidth()) : videoWidth
        let outHeight = transcodeSettings.getHeight() != 0 ? CGFloat(transcodeSettings.getHeight()) : videoHeight
        
        // Final size
        var newWidth = outWidth
        var newHeight = outHeight
        
        var aspectRatio = videoWidth / videoHeight;
        
        // for some portrait videos ios gives the wrong width and height, this fixes that
        let videoOrientation = self.getOrientationForTrack(avAsset: avAsset)
        if (videoOrientation == "portrait") {
            if (videoWidth > videoHeight) {
                videoWidth = mediaSize.height;
                videoHeight = mediaSize.width;
                aspectRatio = videoWidth / videoHeight;
            }
        }
        
        newWidth = (outWidth != 0 && outHeight != 0) ? outHeight * aspectRatio : videoWidth;
        newHeight = (outWidth != 0 && outHeight != 0) ? newWidth / aspectRatio : videoHeight;
        
        // Exporter
        let exporter = SimpleSessionExporter(withAsset: avAsset)
        exporter.outputFileType = AVFileType.mp4
        exporter.outputURL = outFile
        exporter.timeRange = range
        
        exporter.videoOutputConfiguration = [
            AVVideoWidthKey: NSNumber(integerLiteral: Int(newWidth)),
            AVVideoHeightKey: NSNumber(integerLiteral: Int(newHeight)),
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
}

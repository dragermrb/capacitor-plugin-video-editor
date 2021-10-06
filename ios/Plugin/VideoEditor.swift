import Foundation
import AVFoundation

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
        let start = CMTimeMakeWithSeconds(Float64(trimSettings.getStartsAt()), preferredTimescale: 0)
        let end = CMTimeMakeWithSeconds(Float64(trimSettings.getEndsAt()), preferredTimescale: 0)
        let duration = min((end - start), (avAsset.duration - start))
        let range = CMTimeRangeMake(start: start, duration: duration)
        
        exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
        
        // TODO: Video/Audio config
        
        exportSession!.outputURL = outFile
        exportSession!.outputFileType = AVFileType.mp4
        exportSession!.shouldOptimizeForNetworkUse = true
        exportSession.timeRange = range
        
        exportProgressBarTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            // Get Progress
            let progress = Float((self.exportSession?.progress)!);
            
            if (progress < 0.99) {
                progressHandler(progress)
            }
        }
        
        exportSession!.exportAsynchronously(
            completionHandler: { () -> Void in
                self.exportProgressBarTimer.invalidate(); // remove/invalidate timer
                
                switch self.exportSession!.status {
                case .failed:
                    errorHandler(self.exportSession?.error?.localizedDescription ?? "")
                    break;
                case .cancelled:
                    errorHandler("Export canceled")
                    break;
                case .exporting:
                    progressHandler(self.exportSession!.progress)
                    break;
                case .completed:
                    if let url = self.exportSession.outputURL {
                        completionHandler(url)
                    }
                    break;
                default:
                    break
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
}

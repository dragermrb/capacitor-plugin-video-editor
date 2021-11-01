//
//  SimpleSessionExporter.swift
//  CapacitorPluginVideoEditor
//
//  Created by Manuel Rodríguez on 28/10/21.
//

import Foundation
import AVFoundation


// MARK: - SimpleSessionExporter

/// SimpleSessionExporter, export and transcode media in Swift
open class SimpleSessionExporter: NSObject {
    
    public var asset: AVAsset?
    public var outputURL: URL?
    public var outputFileType: AVFileType? = AVFileType.mp4
    public var timeRange: CMTimeRange
    public var optimizeForNetworkUse: Bool = false
    public var videoOutputConfiguration: [String : Any]?
    
    /// Initializes a session with an asset to export.
    ///
    /// - Parameter asset: The asset to export.
    public convenience init(withAsset asset: AVAsset) {
        self.init()
        self.asset = asset
    }
    
    public override init() {
        self.timeRange = CMTimeRange(start: CMTime.zero, end: CMTime.positiveInfinity)
        super.init()
    }
    
    deinit {
        self.asset = nil
    }
}

// MARK: - export

extension SimpleSessionExporter {
    
    /// Completion handler type for when an export finishes.
    public typealias CompletionHandler = (_ status: AVAssetExportSession.Status) -> Void
    
    /// Initiates an export session.
    ///
    /// - Parameter completionHandler: Handler called when an export session completes.
    /// - Throws: Failure indication thrown when an error has occurred during export.
    public func export(completionHandler: @escaping CompletionHandler) {
        guard let asset = self.asset,
              let outputURL = self.outputURL,
              let outputFileType = self.outputFileType else {
                  print("SimpleSessionExporter, an asset and output URL are required for encoding")
                  completionHandler(.failed)
                  return
              }
        
        let composition = AVMutableComposition()
        
        guard
            let compositionTrack = composition.addMutableTrack(
                withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
            let assetTrack = asset.tracks(withMediaType: .video).first
        else {
            print("Something is wrong with the asset.")
            completionHandler(.failed)
            return
        }
        
        // Time Range
        do {
            let timeRange = self.timeRange
            try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
            
            if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compositionAudioTrack.insertTimeRange(
                    timeRange,
                    of: audioAssetTrack,
                    at: .zero)
            }
        } catch {
            print(error)
            completionHandler(.failed)
            return
        }
        
        // Video size
        compositionTrack.preferredTransform = assetTrack.preferredTransform
        
        let videoWidth = self.videoOutputConfiguration![AVVideoWidthKey] as? NSNumber
        let videoHeight = self.videoOutputConfiguration![AVVideoHeightKey] as? NSNumber
        
        // validated to be non-nil byt this point
        let width = videoWidth!.intValue
        let height = videoHeight!.intValue
        
        let videoSize = CGSize(width: width, height: height)
        //var naturalSize = assetTrack.naturalSize
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(
            start: .zero,
            duration: composition.duration)
        videoComposition.instructions = [instruction]
        let layerInstruction = compositionLayerInstruction(for: compositionTrack, assetTrack: assetTrack)
        instruction.layerInstructions = [layerInstruction]
        
        // Export
        guard let export = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetMediumQuality)
        else {
            print("Cannot create export session.")
            completionHandler(.failed)
            return
        }
        
        export.videoComposition = videoComposition
        export.outputFileType = outputFileType
        export.outputURL = outputURL
        
        export.exportAsynchronously {
            DispatchQueue.main.async {
                switch export.status {
                case .completed:
                    completionHandler(.completed)
                default:
                    print("Something went wrong during export.")
                    print(export.error ?? "unknown error")
                    completionHandler(.failed)
                    break
                }
            }
        }
    }
    
    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let transform = assetTrack.preferredTransform
        
        instruction.setTransform(transform, at: .zero)
        
        return instruction
    }
    
}

// MARK: - AVAsset extension

extension AVAsset {
    
    /// Initiates a SimpleSessionExport on the asset
    ///
    /// - Parameters:
    ///   - outputFileType: type of resulting file to create
    ///   - outputURL: location of resulting file
    ///   - videoOutputConfiguration: video output configuration
    ///   - completionHandler: completion handler
    public func simple_export(outputFileType: AVFileType? = AVFileType.mp4,
                              outputURL: URL,
                              videoOutputConfiguration: [String : Any],
                              completionHandler: @escaping SimpleSessionExporter.CompletionHandler) {
        let exporter = SimpleSessionExporter(withAsset: self)
        exporter.outputFileType = outputFileType
        exporter.outputURL = outputURL
        exporter.videoOutputConfiguration = videoOutputConfiguration
        exporter.export(completionHandler: completionHandler)
    }
}
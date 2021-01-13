//
//  Extensions.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/22/20.
//

import UIKit
import Foundation
import AVFoundation

extension UIView {
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    public var top: CGFloat {
        return frame.origin.y
    }
    public var bottom: CGFloat {
        return top + height
    }
    public var left: CGFloat {
        return frame.origin.x
    }
    public var right: CGFloat {
        return left + width
    }
}

extension String {
    func safeDatabaseKey() -> String {
        return replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
    }
}

// MARK: TimeInterval
extension TimeInterval {

    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        let seconds = time % 60
        var minutes = (time / 60) % 60
        minutes += Int(time / 3600) * 60  // to account for the hours as minutes
        
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
}

// MARK: AVAsset
extension AVAsset {

    // Provide a URL for where you wish to write
    // the audio file if successful
    func writeAudioTrack(to url: URL,
                         success: @escaping () -> (),
                         failure: @escaping (Error) -> ()) {
        do {
            let asset = try audioAsset()
            asset.write(to: url, success: success, failure: failure)
        } catch {
            failure(error)
        }
    }

    private func write(to url: URL,
                       success: @escaping () -> (),
                       failure: @escaping (Error) -> ()) {
        // Create an export session that will output an
        // audio track (M4A file)
        guard let exportSession = AVAssetExportSession(asset: self,
                                                       presetName: AVAssetExportPresetAppleM4A) else {
                                                        // This is just a generic error
                                                        let error = NSError(domain: "domain",
                                                                            code: 0,
                                                                            userInfo: nil)
                                                        failure(error)

                                                        return
        }

        exportSession.outputFileType = .m4a
        exportSession.outputURL = url

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                success()
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                let error = NSError(domain: "domain", code: 0, userInfo: nil)
                failure(error)
            @unknown default:
                let error = NSError(domain: "domain", code: 0, userInfo: nil)
                failure(error)
            }
        }
    }

    private func audioAsset() throws -> AVAsset {
        // Create a new container to hold the audio track
        let composition = AVMutableComposition()
        // Create an array of audio tracks in the given asset
        // Typically, there is only one
        let audioTracks = tracks(withMediaType: .audio)

        // Iterate through the audio tracks while
        // Adding them to a new AVAsset
        for track in audioTracks {
            let compositionTrack = composition.addMutableTrack(withMediaType: .audio,
                                                               preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                // Add the current audio track at the beginning of
                // the asset for the duration of the source AVAsset
                try compositionTrack?.insertTimeRange(track.timeRange,
                                                      of: track,
                                                      at: track.timeRange.start)
            } catch {
                throw error
            }
        }
        return composition
    }
    
}

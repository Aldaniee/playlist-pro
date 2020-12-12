import Foundation
import SwiftUI
import SpotifyWebAPI

extension PlaylistItem {
    
    /// Returns `true` if this playlist item is probably the same as
    /// `other` by comparing the name and artist/show name.
    func isProbablyTheSameAs(_ other: Self) -> Bool {
        
        if let uri = self.uri, let otherURI = other.uri {
            return uri == otherURI
        }
        
        switch (self, other) {
            case (.track(let track), .track(let otherTrack)):
                // if the name of the tracks and the name of the artists
                // are the same, then the tracks are probably the same
                return track.name == otherTrack.name &&
                        track.artists?.first?.name ==
                        otherTrack.artists?.first?.name
                
            case (.episode(let episode), .episode(let otherEpisode)):
                // if the name of the episodes and the names of the
                // shows they appear on are the same, then the episodes
                // are probably the same.
                return episode.name == otherEpisode.name &&
                        episode.show?.name == otherEpisode.show?.name
            default:
                return false
        }
        
    }
    
}

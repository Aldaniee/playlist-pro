//
//  Constants.swift
//  playlist-pro
//
//  Created by Aidan Lee on 10/29/20.
//

import Foundation
import UIKit

public struct Constants {
    struct YT {
        static let API_KEY = "***REMOVED***"
        static let PLAYLIST_ID = "UUnxQ8o9RpqxGF2oLHcCn9VQ"
        static let PLAYLIST_URL = "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(Constants.YT.PLAYLIST_ID)&key=\(Constants.YT.API_KEY)"
        static let VIDEOCELL_ID = "VideoCell"
        static let EMBED_URL = "https://www.youtube.com/embed/"
        static let MAX_RESULTS = 5
    
        static let SEARCHLIST_URL_PT1 = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=\(Constants.YT.MAX_RESULTS)&order=relevance&q="
        static let SEARCHLIST_URL_PT2 = "&type=video&key=\(Constants.YT.API_KEY)"
    }
    struct SPOTIFY {
        static let CLIENT_ID = "***REMOVED***"
        static let SECRET_ID = "***REMOVED***"
        static let REDIRECT_URL = "https://www.google.com"//"playlist-pro://login-callback"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
    }
    struct UI {
        static let cornerRadius: CGFloat = 11.0
        
        static let orange = UIColor(
            red: 244/255, green: 111/255, blue: 52/255, alpha: 1.00
        )
        
        static let spotifyGreen = UIColor(
            red: 97/255, green: 232/255, blue: 123/255, alpha: 1.00
        )
        static let darkPink = UIColor(
            red: 255/255, green: 41/255, blue: 107/255, alpha: 1.00
        )
        static let lightPink = UIColor(
            red: 231/255, green: 125/255, blue: 235/255, alpha: 1.00
        )
        static let darkGray = UIColor(
            red: 118/255, green: 118/255, blue: 118/255, alpha: 1.00
        )
        static let blackGray = UIColor(
            red: 47/255, green: 47/255, blue: 47/255, alpha: 1.00
        )
        static let lightGray = UIColor(
            red: 222/255, green: 222/255, blue: 222/255, alpha: 1.00
        )
        static let hardlyGray = UIColor(
            red: 248/255, green: 248/255, blue: 248/255, alpha: 1.00
        )
        static let orangePinkPair = [orange.cgColor, lightPink.cgColor]
    }
}

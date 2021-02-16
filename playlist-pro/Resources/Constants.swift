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
        static let REDIRECT_URL = "playlist-pro://login-callback"
    }
    struct UI {
        static let cornerRadius: CGFloat = 8.0
                
        static let backgroundWhite = UIColor(red: 0.99, green: 0.99, blue: 0.98, alpha: 1.0)
        static let placeholderGray = UIColor(red: 0.765, green: 0.765, blue: 0.765, alpha: 1.0)
        static let trackGray = UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 1.0)
        static let gray = UIColor.lightGray
        static let orange = UIColor(red: 0.984, green: 0.588, blue: 0.188, alpha: 1.0)
        static let green = UIColor(red:0.000, green:0.802, blue:0.041, alpha:1.00)
        static let darkGreen = UIColor(red:0.000, green:0.602, blue:0.041, alpha:1.00)
        
    }
}

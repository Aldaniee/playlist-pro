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
        static let API_KEY = "AIzaSyC9vmg-omwrtWtrO46ClfqqX4p5tzNqQ_Q"
        static let PLAYLIST_ID = "UUnxQ8o9RpqxGF2oLHcCn9VQ"
        static let PLAYLIST_URL = "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(Constants.YT.PLAYLIST_ID)&key=\(Constants.YT.API_KEY)"
        static let VIDEOCELL_ID = "VideoCell"
        static let EMBED_URL = "https://www.youtube.com/embed/"
        static let MAX_RESULTS = 5
    
        static let SEARCHLIST_URL_PT1 = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=\(Constants.YT.MAX_RESULTS)&order=relevance&q="
        static let SEARCHLIST_URL_PT2 = "&type=video&key=\(Constants.YT.API_KEY)"
    }
    struct SPOTIFY {
        static let CLIENT_ID = "15eb8b3ef017469a9db02a7bbfcc2457"
        static let SECRET_ID = "9896ab3a7e8f454b82ef7d2fd43344a0"
        static let REDIRECT_URL = "playlist-pro://login-callback"
    }
}

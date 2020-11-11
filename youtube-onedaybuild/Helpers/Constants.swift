//
//  Constants.swift
//  youtube-onedaybuild
//
//  Created by Aidan Lee on 10/29/20.
//

import Foundation

struct Constants {
    static let API_KEY = "AIzaSyC9vmg-omwrtWtrO46ClfqqX4p5tzNqQ_Q"
    static let PLAYLIST_ID = "UUnxQ8o9RpqxGF2oLHcCn9VQ"
    static let API_PLAYBACK_URL = "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(Constants.PLAYLIST_ID)&key=\(Constants.API_KEY)"
    static let VIDEOCELL_ID = "VideoCell"
    static let YT_EMBED_URL = "https://www.youtube.com/embed/"
    static let MAX_RESULTS = 10
    //static let API_SEARCH_URL =  "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=\(SearchEngine.MAX_RESULTS)&order=relevance&q=\(text)&type=video&key=\(SearchEngine.API_KEY)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
}

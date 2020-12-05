//
//  Constants.swift
//  youtube-onedaybuild
//
//  Created by Aidan Lee on 10/29/20.
//

import Foundation

struct Constants {
    static let YT_API_KEY = "***REMOVED***"
    static let YT_PLAYLIST_ID = "UUnxQ8o9RpqxGF2oLHcCn9VQ"
    static let API_PLAYLIST_URL = "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(Constants.YT_PLAYLIST_ID)&key=\(Constants.YT_API_KEY)"
    static let VIDEOCELL_ID = "VideoCell"
    static let YT_EMBED_URL = "https://www.youtube.com/embed/"
    static let MAX_RESULTS = 5

    static let API_SEARCHLIST_URL_PT1 = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=\(Constants.MAX_RESULTS)&order=relevance&q="
    static let API_SEARCHLIST_URL_PT2 = "&type=video&key=\(Constants.YT_API_KEY)"
    
    
    static let SPOTIFY_PLAYLIST_TRACKLIST_PT1 = "https://api.spotify.com/v1/playlists/"
    static let SPOTIFY_PLAYLIST_TRACKLIST_PT2 = "/tracks?market=US&fields=items(track(name%2Chref))"
    static let SPOTIFY_CLIENT_ID = "***REMOVED***"
    static let SPOTIFY_SECRET_ID = "***REMOVED***"
    static let SPOTIFY_REDIRECT_URL = "playlist-pro://login-callback"
}

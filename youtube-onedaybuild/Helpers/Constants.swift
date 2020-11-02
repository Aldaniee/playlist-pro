//
//  Constants.swift
//  youtube-onedaybuild
//
//  Created by Aidan Lee on 10/29/20.
//

import Foundation

struct Constants {
    static var API_KEY = "AIzaSyC9vmg-omwrtWtrO46ClfqqX4p5tzNqQ_Q"
    static var PLAYLIST_ID = "UUnxQ8o9RpqxGF2oLHcCn9VQ"
    static var API_URL = "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(Constants.PLAYLIST_ID)&key=\(Constants.API_KEY)"
    
    static var VIDEOCELL_ID = "VideoCell"
}

//
//  Playlist.swift
//  playlist-pro
//
//  Created by Aidan Lee on 1/29/21.
//
//  Object to store a playlist (or collection of songs) within the app

import Foundation

struct Playlist {
    
    
    /*
     * songList: Songs are stored in an NSMutableArray and are defined as a Dictionary<String, Any>
     * title: Unique title of the playlist
     */
    var title : String
    var songList = NSMutableArray()
    
    
}

//
//  Playlist.swift
//  playlist-pro
//
//  Created by Aidan Lee on 1/29/21.
//
//  Object to store a playlist (or collection of songs) within the app

import Foundation

class Playlist {
    
    
    /*
     * songList: Songs are stored in an NSMutableArray and are defined as a Dictionary<String, Any>
     * title: Title of the playlist
     */
    private var songList: NSMutableArray!
    var title : String!
    
    init(songList: NSMutableArray, title: String) {
        self.songList = songList
        self.title = title
    }
    func getSongList() -> NSMutableArray {
        return songList
    }
    func setSongList(songList: NSMutableArray) {
        self.songList = songList
    }
    func add(song: Dictionary<String, Any>) {
        songList.add(song)
    }
    func get(at: Int) -> Dictionary<String, Any> {
        return songList.object(at: at) as! Dictionary<String, Any>
    }
    func count() -> Int {
        return songList.count
    }
    func remove(song: Dictionary<String, Any>) {
        return songList.remove(song)
    }
    func replace(index: Int, song: Dictionary<String, Any>) {
        songList.replaceObject(at: index, with: song)
    }
}

//
//  Playlist.swift
//  playlist-pro
//
//  Created by Aidan Lee on 1/29/21.
//

import Foundation

class Playlist {
    
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

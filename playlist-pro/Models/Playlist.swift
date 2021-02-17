//
//  Playlist.swift
//  playlist-pro
//
//  Created by Aidan Lee on 1/29/21.
//

import Foundation

class Playlist {
    
    private var songList: NSMutableArray!
    
    init() {
        songList = NSMutableArray(array: UserDefaults.standard.value(forKey: "LibraryArray") as? NSArray ?? NSArray())
    }
    
    func refreshPlaylist() {
        songList = NSMutableArray(array: UserDefaults.standard.value(forKey: "LibraryArray") as? NSArray ?? NSArray())
    }
    
    func getSongList() -> NSMutableArray {
        return songList
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

//
//  Playlist.swift
//  playlist-pro
//
//  Created by Aidan Lee on 1/29/21.
//
//  Object to store a playlist (or collection of songs) within the app

import Foundation
import UIKit
import CodableFirebase

/*
struct FirebasePlaylist {
    var title : String
    var songList = NSArray()
    var description = ""
    
    init(playlist: Playlist) {
        self.title = playlist.title
        self.songList = encodeSongArray(playlist.songList)
        self.description = playlist.description
    }
}
*/
struct Playlist {
    var title : String
    var songList = [Song]()
    var description = ""
    //var image : UIImage?
    /*init(playlist: FirebasePlaylist) {
        title = playlist.title
        songList = decodeSongArray(playlist.songList)
        description = playlist.description
    }*/
    init(title: String) {
        self.title = title
    }
    init(title: String, songList: [Song]) {
        self.title = title
        self.songList = songList
    }
    init(title: String, songList: [Song], description: String) {
        self.title = title
        self.songList = songList
        self.description = description
    }
}

//struct StoragePlaylist {
//    var title : String
//    var encodedSongArray : NSArray
//    var description : String?
//    //var imageURL : URL
//}
extension Playlist: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            title = try values.decode(String.self, forKey: .title)
        }
        catch {
            title = ""
        }
        do {
            description = try values.decode(String.self, forKey: .description)
        }
        catch {
            description = ""
        }
        do {
            songList = try values.decode([Song].self, forKey: .songList)
        }
        catch {
            songList = [Song]()
        }
        //image = try values.decode([Song].self, forKey: .songList)


    }
}
extension Playlist: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.description, forKey: .description)
        try container.encode(self.songList, forKey: .songList)
        try container.encode(self.title, forKey: .title)
    }
}

enum CodingKeys: String, CodingKey {
    case title
    case songList
    case description
    case image
}

//private func encodeSongArray(_ songArray: [Song]) -> NSArray {
//    let encodedSongArray = NSMutableArray()
//    for song in songArray {
//        if let encodedSong = try? FirestoreEncoder().encode(song) {
//            encodedSongArray.add(encodedSong)
//        }
//        else {
//            print("Encoding Error")
//            return NSArray()
//        }
//    }
//    return NSArray(array: encodedSongArray)
//}
//private func decodeSongArray(_ encodedSongArray: NSArray) -> [Song]{
//    var songArray = [Song]()
//    for encodedSong in encodedSongArray {
//        if let decodedSong = try? FirestoreDecoder().decode(Song.self, from: encodedSong as! [String : Any]) {
//            songArray.append(decodedSong)
//        }
//        else {
//            print("Decoding Error")
//            return [Song]()
//        }
//    }
//    return songArray
//}

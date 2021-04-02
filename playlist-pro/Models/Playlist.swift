//
//  Playlist.swift
//  playlist-pro
//
//  Created by Aidan Lee on 1/29/21.
//
//  Object to store a playlist (or collection of songs) within the app

import Foundation
import UIKit
struct Playlist {
    var title : String
    var songList = [Song]()
    var description = ""
    //var image : UIImage?
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

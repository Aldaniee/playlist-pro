//
//  Song.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/19/21.
//

import UIKit

struct Song : Codable, Equatable{
    let id: String
    let link: String
    let fileExtension: String
    let title: String
    let artists: [String]
    let album: String?
    let releaseYear: String?
    var duration: String
    var startTime: String = "0:00"
    var endTime: String

    let lyrics: String?
    let tags: [String]?
    
    init(id: String, link: String, fileExtension: String, title: String, artists: [String], duration: String) {
        self.init(id: id, link: link, fileExtension: fileExtension, title: title, artists: artists, album: nil, releaseYear: nil, duration: duration, lyrics: nil, tags: nil)
    }
    init(id: String, link: String, fileExtension: String, title: String, artists: [String], album: String?, releaseYear: String?, duration: String, lyrics: String?, tags: [String]?) {
        self.id = id
        self.link = link
        self.fileExtension = fileExtension
        self.title = title
        self.artists = artists
        self.album = album
        self.releaseYear = releaseYear
        self.duration = duration
        self.lyrics = lyrics
        self.tags = tags
        self.endTime = duration
    }
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id
    }
    // SongIDs are of the format yt_ + videoID + generateIDFromTimeStamp()
    // generateIDFromTimeStamp() is different everytime it is run
    func getVideoId() -> String {
        var songId = self.id
        if songId.contains("yt_") {
            songId = songId.substring(fromIndex: 3)
            songId = songId.substring(toIndex: 11)
        }
        return id
    }
    
}

typealias SongDict = Dictionary<String, Any>

public struct SongValues {
    static let id = "id"
    static let link = "link"
    static let fileExtension = "fileExtension"
    static let title = "title"
    static let artists = "artists"
    static let album = "album"
    static let releaseYear = "releaseYear"
    static let duration = "duration"
    static let lyrics = "lyrics"
    static let tags = "tags"
}

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
    var title: String
    var songList = [Song]()
    var description = ""
    private var image: UIImage?
    /*init(playlist: FirebasePlaylist) {
        title = playlist.title
        songList = decodeSongArray(playlist.songList)
        description = playlist.description
    }*/
    init(playlist: Playlist) {
        self.title = playlist.title
        self.songList = playlist.songList
        self.description = playlist.description
        self.image = playlist.image

    }
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
    func calcDuration() -> Int {
        var sum = TimeInterval(0)
        let inFormatter = DateFormatter()
        inFormatter.locale = Locale(identifier: "en_US_POSIX")
        inFormatter.dateFormat = "mm:ss"

        for song in self.songList {

            let duration = convertToTimeInterval(time: song.duration)
            sum = sum + duration
            print(sum)
        }
        print(sum.stringFromTimeInterval())

        return (Int(sum) / 60 ) % 60
    }
    func convertToTimeInterval(time: String) -> TimeInterval {
        guard time != "" else {
            return 0
        }

        var interval:Double = 0

        let parts = time.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }

        return interval
    }
    func getImage() -> UIImage? {
        if image == nil && self.songList.count > 0 {
            let firstSong = self.songList[0]
            let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(firstSong.id).jpg"))
            if let imgData = imageData {
                return UIImage(data: imgData)
            }
            return nil
        }
        else {
            return image
        }
        
    }
    mutating func setImage(image: UIImage?) {
        self.image = image
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
        do {
            let imageString = try values.decode(String.self, forKey: .image)
            image = convertBase64StringToImage(imageBase64String: imageString)
        }
        catch {
            image = nil
        }

    }
    func convertImageToBase64String(img: UIImage?) -> String {
        return img?.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    func convertBase64StringToImage(imageBase64String: String) -> UIImage? {
        let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image ?? nil
    }
    func songInPlaylist(song: Song) -> Bool {
        for temp in songList {
            if song == temp {
                return true
            }
        }
        return false
    }
    mutating func refreshSongIdsFromLibrary() {
        for i in 0..<songList.count {
            songList[i].refreshSongIDFromLibrary()
        }
    }
}
extension Playlist: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.description, forKey: .description)
        try container.encode(self.songList, forKey: .songList)
        try container.encode(convertImageToBase64String(img: self.image), forKey: .image)
    }
}

enum CodingKeys: String, CodingKey {
    case title
    case songList
    case description
    case image
}

//
//  YoutubeSearchManager.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/19/21.
//

import Foundation
import UIKit
import XCDYouTubeKit

class YoutubeManager {
    static let shared = YoutubeManager()
    
    var searchVC = SearchViewController()
    
    func search(searchText text: String, completion: @escaping ([Video]?)-> ()) {
            
        // Create a URL object
        guard let searchText = getSearchURL(withText: text) else {
            print("ERROR: URL text encoding for: \(text)")
            return
        }
        print("Searching with text: \(searchText)")
        
        guard let url = URL(string: searchText) else {
            print("ERROR: URL text incompatible: \(searchText)")
            return
        }
        
        // Start the task
        sendRequest(url: url) { response in
            if let response = response {
                if response.items != nil {
                    completion(response.items!)
                }
                else {
                    print("ERROR: Response does not have items container (containing videos)")
                }
            } else {
                print("ERROR: No response found")
            }
        }
        completion(nil)
    }
    
    func sendRequest(url: URL, completion: @escaping (Response?) -> ()) {
        // Get a data task (a single call to the API)
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // check if there were any errors
            if error != nil {
                print(error!)
                return
            }
            
            do {
                // Parse the data into video objects
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(Response.self, from: data!)
                completion(response)
                //dump(response)
            }
            catch {
                completion(nil)
                print(error)
            }
        }.resume()
    }
    
    private func getSearchURL(withText text : String) -> String? {
        let searchableText = text.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let allowedCharacters = NSCharacterSet.urlFragmentAllowed

        guard let encodedSearchString  = searchableText.addingPercentEncoding(withAllowedCharacters: allowedCharacters)  else {
            return nil
        }
        return Constants.YT.SEARCHLIST_URL_PT1 + encodedSearchString + Constants.YT.SEARCHLIST_URL_PT2
    }
    /// Downloads a youtube video's audio and it's thumbnail and adds a Song object to the library as well as returns it
    func downloadYouTubeVideoAddToLibrary(inVideo: Video, completion: ((Bool) -> Void)? = nil) {
        do {
            let videoID = inVideo.videoId
            let title = try inVideo.title.strippingHTML() ?? inVideo.title
            let artistName = try inVideo.artist.strippingHTML() ?? inVideo.artist
            let artistArray = NSMutableArray(object: artistName)
            self.downloadYouTubeVideoAddToLibrary(videoID: videoID, title: title, artistArray: artistArray) { (success) in
                completion?(success)
            }
        }
        catch {
            print("ERROR: strippingHTML error")
        }
    }
    /// Downloads a youtube video's audio and it's thumbnail and adds a Song object to the library as well as returns it
    func downloadYouTubeVideoAddToLibrary(videoID: String, title: String, artistArray: NSMutableArray, completion: ((Bool) -> Void)? = nil) {
        print("Loading url: https://www.youtube.com/embed/\(videoID)")
        /**
         *  Error when no suitable video stream is available. This can occur due to various reason such as:
         *  * The video is not playable because of legal reasons or when the video is private.
         *  * The given video identifier string is invalid.
         *  * The video was removed as a violation of YouTube's policy or when the video did not exist.
         */
        //XCDYouTubeErrorNoStreamAvailable      = -2,
        XCDYouTubeClient.default().getVideoWithIdentifier(videoID) { (video, error) in
            guard video != nil else {
                print(error?.localizedDescription as Any)
                return
            }
            let dispatchGroup = DispatchGroup()  // To keep track of the async download group

            if !LibraryManager.shared.videoAlreadyDownloaded(videoID: videoID) {
                let sID = "yt_" + videoID + self.generateIDFromTimeStamp()
                print("sID:\(sID)")
                let songURL = video!.streamURL!
                let thumbnailURL = video!.thumbnailURLs![video!.thumbnailURLs!.count - 1]
                
                dispatchGroup.enter()
                print("Starting song download")
                var didSucceed = false
                if self.downloadVideoConvertToAudio(songUrl: songURL, sID: sID, fileExtension: "mp4") {
                    print("Song download succeeded")
                    didSucceed = true
                }
                else {
                    print("Song download error")
                }
                dispatchGroup.leave()
                
                dispatchGroup.enter()
                print("Starting thumbnail download")
                if self.downloadThumbnail(thumbnailUrl: thumbnailURL, filename: sID) {
                    print("Thumbnail download succeeded")
                    didSucceed = didSucceed && true
                }
                else {
                    print("Thumbnail download error")
                }
                dispatchGroup.leave()                // All Downloads Complete
                
                /* SOMETHING TO TRY (replacing with block below)
                dispatchGroup.enter()
                if didSucceed {
                    print("Successfully downloaded song: \(title)")
                    let song = self.buildSongForLibrary(sID: sID, videoID: videoID, songUrl: songURL, newExtension: "m4a", songTitle: title, artists: artistArray)
                    LibraryManager.shared.addSongToLibraryArray(song: song)
                    completion?(true)
                }
                else {
                    print("Error downloading the song")
                    _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).jpg")
                }
                dispatchGroup.leave()                // All Downloads Complete
*/
                dispatchGroup.notify(queue: DispatchQueue.main) {  // All async download in the group completed
                    if didSucceed {
                        print("Successfully downloaded song: \(title)")
                        let song = self.buildSongForLibrary(sID: sID, videoID: videoID, songUrl: songURL, newExtension: "m4a", songTitle: title, artists: artistArray)
                        LibraryManager.shared.addSongToLibraryArray(song: song)
                        completion?(true)
                    }
                    else {
                        print("Error downloading the song")
                        _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).jpg")
                    }
                }
            }
            else {
                print("Song already downloaded, skipping download")
            }
        }
    }
    
    func downloadVideoFromSearchList(videos: [Video], completion: @escaping (Song) -> ()) {
        let video = videos[0]
        YoutubeManager.shared.downloadYouTubeVideoAddToLibrary(inVideo: video) { (success) in
            if let song = LibraryManager.shared.getSongfrom(videoID: video.videoId) {
                completion(song)
                return
            }
            else {
                // If the previous video fails, download the next available searched video
                self.downloadVideoFromSearchList(videos: [Video]() + videos[1...], completion: completion)
            }
        }
    }
    
    private func downloadThumbnail(thumbnailUrl: URL?, filename: String) -> Bool {
        var didSucceed = true
        // Download Thumbnail
        if let imageUrl = thumbnailUrl {
            LocalFilesManager.downloadFile(from: imageUrl, filename: filename, extension: "jpg", completion: { error in
                if error != nil {
                    print("Error downloading thumbnail: " + error!.localizedDescription)
                    didSucceed = false
                }
            })
        }
        return didSucceed
    }
    private func downloadVideoConvertToAudio(songUrl: URL, sID: String, fileExtension: String) -> Bool {
        var didSucceed = true
        LocalFilesManager.downloadFile(from: songUrl, filename: sID, extension: fileExtension, completion: { error in
            if error == nil  {
                LocalFilesManager.extractAudioFromVideo(songID: sID, completion: { error in
                    if error == nil {
                        _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).mp4")
                    }
                    else {
                        // Delete the extracted audio if available
                        _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).m4a")
                        _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).mp4")
                        didSucceed = false
                        print("Error converting audio to video: " + error!.localizedDescription)
                        return
                    }
                })
            } else {
                print("Error downloading video: " + error!.localizedDescription)
                didSucceed = false
                _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).mp4")
            }
            // Delete excess downloaded video regardless of the result of converting to audio
        })
        return didSucceed
    }
    
    private func buildSongForLibrary(sID: String, videoID: String?, songUrl: URL, newExtension: String, songTitle: String?, artists: NSMutableArray) -> Song {
        let duration = LocalFilesManager.extractDurationForSong(songID: sID, songExtension: newExtension)
        let link = videoID == nil ? songUrl.absoluteString : "https://www.youtube.com/embed/\(videoID ?? "UNKNOWN_ERROR")"
        
        let songDict = [SongValues.id: sID,
                            SongValues.title: filterSongTitle(songTitle) ?? sID,
                            SongValues.artists: artists,
                            SongValues.album: "",
                            SongValues.releaseYear: "",
                            SongValues.duration: duration,
                            SongValues.lyrics: "",
                            SongValues.link: link,
                            SongValues.fileExtension: newExtension] as SongDict
        let metadataDict = LocalFilesManager.extractSongMetadata(songID: sID, songExtension: newExtension)
        let song = self.enrichSong(songDict: songDict, fromMetadataDict: metadataDict)
        return song
    }
    
    private func filterSongTitle(_ title: String?) -> String? {
        if title == nil {
            return nil
        }
        var filteredTitle = title!
        let textToRemove = [
            "Official Music Video",
            "Official Video",
            "Official Lyric Video",
            "Official Audio",
            "Official Lyrics",
            "Audio",
            "Vizualizer Video",
            "Vizualizer",
            "Vizualizer Video",
            "Lyrics",
            "Lyrics Audio",
            "Lyric Video",
        ]
        var featuresToRemove = Array<String>()
        
        for i in 0..<textToRemove.count {
            let text = textToRemove[i]
            let textLower = textToRemove[i].lowercased()
            let textUpper = textToRemove[i].uppercased()

            featuresToRemove.append("(\(text))")
            featuresToRemove.append("[\(text)]")
            featuresToRemove.append("{\(text)}")
            featuresToRemove.append("<\(text)>")
            featuresToRemove.append("|\(text)|")
            
            featuresToRemove.append("(\(textLower))")
            featuresToRemove.append("[\(textLower)]")
            featuresToRemove.append("{\(textLower)}")
            featuresToRemove.append("<\(textLower)>")
            featuresToRemove.append("|\(textLower)|")
            
            featuresToRemove.append("(\(textUpper))")
            featuresToRemove.append("[\(textUpper)]")
            featuresToRemove.append("{\(textUpper)}")
            featuresToRemove.append("<\(textUpper)>")
            featuresToRemove.append("|\(textUpper)|")
        }
        for item in featuresToRemove {
            if filteredTitle.contains(item) {
                filteredTitle = filteredTitle.replacingOccurrences(of: item, with: "")
                print("removed occurance of \(item) from song title")
            }
        }
        return filteredTitle
    }
   private func enrichSong(songDict: SongDict, fromMetadataDict mdDict: SongDict) -> Song {
        var key: String
        let songID = songDict[SongValues.id] as! String
        var songTitle = songDict[SongValues.title] as! String
        var songArtists = songDict[SongValues.artists] as! NSMutableArray
        var songAlbum = songDict[SongValues.album] as! String
        var songReleaseYear = songDict[SongValues.releaseYear] as! String
        let tags = NSMutableArray()
        for (k, val) in mdDict {
            if (val as? String ?? "") == "" && (val as? Data ?? Data()).isEmpty {
                continue
            }
            key = getKey(forMetadataKey: k)

            if key == SongValues.title && (songTitle == songID || songTitle == "") {  // if metadata has value and song title is set to default value or empty String
                songTitle = val as! String
                
            } else if key == SongValues.artists && songArtists == NSMutableArray() {
                songArtists = NSMutableArray()
                songArtists.add(val as! String)
            } else if key == SongValues.album && songReleaseYear == "" {  // if metadata has value and song album is set to default value
                songAlbum = val as! String

            } else if key == SongValues.releaseYear && songAlbum == "" {  // if metadata has value and song album is set to default value
                songReleaseYear = val as! String

            } else if key == "type" {
                tags.add(val as! String)
                
            } else if key == "artwork" && !LocalFilesManager.checkFileExist(songID + ".jpg") {
                if let jpgImageData = UIImage(data: val as! Data)?.jpegData(compressionQuality: 1) {  // make sure image is jpg
                    LocalFilesManager.saveImage(UIImage(data: jpgImageData), withName: songID)
                }
                
            } else {
                print("songDict not enriched for key: " + key + " -> " + String(describing: val))
            }
        }
        let song = Song(id: songID, link: songDict[SongValues.link] as! String, fileExtension: songDict[SongValues.fileExtension] as! String, title: songTitle, artists: songArtists.asStringArray(), album: songAlbum, releaseYear: songReleaseYear, duration: songDict[SongValues.duration] as! String, lyrics: songDict[SongValues.lyrics] as? String, tags: tags.asStringArray())
        return song
    }
    private func getKey(forMetadataKey mdKey: String) -> String {
        switch mdKey {
            case "title",
                 "songName",
                 "TIT2":
                return "title"
            
            case "artist",
                 "TPE1":
                return "artist"
            
            case "albumName",
                 "album",
                 "TIT1",
                 "TALB":
                return "album"
            
            case "type",
                 "TCON":
                return "type"
            
            case "year",
                 "TYER",
                 "TDAT",
                 "TORY",
                 "TDOR":
                return "year"
            
            case "artwork",
                 "APIC":
                return "artwork"
            
            default:
                return mdKey
        }
    }
    
    private func generateIDFromTimeStamp() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var timestamp: Int = Int(Date().timeIntervalSince1970 * 1000)
        var str = ""
        while timestamp != 0 {
            str += letters[timestamp % 10]
            timestamp /= 10
        }
        return str
    }
}

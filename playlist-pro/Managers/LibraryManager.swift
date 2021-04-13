//
//  LibraryManager.swift
//  YouTag
//
//  Created by Youstanzr on 2/28/20.
//  Copyright © 2020 Youstanzr. All rights reserved.
//

import UIKit
import FirebaseAuth

class LibraryManager {

    static let shared = LibraryManager()
    
    static let LIBRARY_DISPLAY = "Music"
    
	enum ValueType {
		case min
		case max
	}
    
    // A playlist storing all songs
    var songLibrary = Playlist(title: "library")
    
    var libraryVC = LibraryViewController()
    
    init() {
        fetchLibraryFromLocalStorage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchLibraryFromLocalStorage() {
        songLibrary = LocalFilesManager.retreiveLibrary()
        libraryVC.tableView.reloadData()
    }
    
	/*
	If the following parameters have no value then pass nil and the function will handle it
		Song ID -> will generate a custom id
		Song Title -> will be set to Song ID
		Thumbnail URL -> It will skip downloading a thumbnail image
	*/
    func addSongToLibrary(songTitle: String?, artists: NSMutableArray, songUrl: URL, songExtension: String , thumbnailUrl: URL?, videoID: String?, playlistTitle: String?, completion: ((Bool) -> Void)? = nil) {
        
        var sID = videoID == nil ? "dl_" + generateIDFromTimeStamp() : "yt_" + videoID! + generateIDFromTimeStamp()
        
        if self.hasSongInLibrary(videoID: videoID) {
            print("Song \(songTitle ?? "??") found in library")
            // SongIDs are of the format yt_ + videoID + generateIDFromTimeStamp()
            // generateIDFromTimeStamp() is different everytime it is run
            // If we wish to download the thumbnail and audio again for an already generated songDict
            // we need to use to old songID so that the file location matches the songDict
            sID = findSongIDfrom(videoID: videoID)!
        }

        if LocalFilesManager.checkFileExist("\(sID).m4a") {
            print("Song already in library, skipping download")
            if (playlistTitle != nil) {
                for song in songLibrary.songList {
                    if song.id == sID {
                        PlaylistsManager.shared.addSongToPlaylist(song: song, playlistName: playlistTitle!)
                        return
                    }
                }
                print("ERROR: couldn't find song? should never get here")
                return
            }
            return
        }
        
        var newExtension: String
        var errorStr: String?
        
        //let currentViewController = UIApplication.getCurrentViewController()
        //currentViewController?.showProgressView(onView: (currentViewController?.view)!, withTitle: "Downloading...")

        let dispatchGroup = DispatchGroup()  // To keep track of the async download group
        
        print("Starting song and thumbnail download")
        
        dispatchGroup.enter()
        if songExtension == "mp4" {
            // Downloading YouTube Video
            LocalFilesManager.downloadFile(from: songUrl, filename: sID, extension: songExtension, completion: { error in
                if error == nil  {
                    // Converting video to audio
                    LocalFilesManager.extractAudioFromVideo(songID: sID, completion: { error in
                        // Deleting excess downloaded video
                        _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).mp4")

                        dispatchGroup.leave()
                        if error != nil {  // Failed to convert audio from video
                            // Delete the extracted audio if available
                            _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).m4a")
                            errorStr = error!.localizedDescription
                        }
                    })
                } else {
                    // There was an error so delete the downloaded video if available
                    _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).mp4")
                    print("Error downloading video: " + error!.localizedDescription)
                    dispatchGroup.leave()
                    errorStr = error!.localizedDescription
                }
            })
            newExtension = "m4a"
        } else {
            // case for downloading audio directly, should never get here for a youtube video but this allows for SoundCloud
            
            LocalFilesManager.downloadFile(from: songUrl, filename: sID, extension: songExtension, completion: { error in
                dispatchGroup.leave()
                if error != nil  {
                    // Delete the downloaded audio if available
                    _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).\(songExtension)")
                    print("Error downloading song: " + error!.localizedDescription)
                    errorStr = error!.localizedDescription
                }
            })
            newExtension = songExtension
        }
        // Download Thumbnail
        if let imageUrl = thumbnailUrl {
            dispatchGroup.enter()
            LocalFilesManager.downloadFile(from: imageUrl, filename: sID, extension: "jpg", completion: { error in
                dispatchGroup.leave()
                if error != nil  {
                    print("Error downloading thumbnail: " + error!.localizedDescription)
                }
            })
        }
        
        // All Downloads Complete
        dispatchGroup.notify(queue: DispatchQueue.main) {  // All async download in the group completed
            print("All async download in the group completed")
            //currentViewController?.removeProgressView()
            if errorStr == nil {
                if !self.hasSongInLibrary(videoID: videoID) {
                    let song = self.buildSongForLibrary(sID: sID, videoID: videoID, songUrl: songUrl, newExtension: newExtension, songTitle: songTitle, artists: artists, playlistTitle: playlistTitle)
                    
                    self.addSongToLibraryArray(song: song)
                    LocalFilesManager.storeLibrary(self.songLibrary)
                    DatabaseManager.shared.saveLibraryToDatabase()
                    
                    if (playlistTitle != nil) {
                        PlaylistsManager.shared.addSongToPlaylist(song: song, playlistName: playlistTitle!)
                    }
                    completion?(true)
                }
            } else {
                print("Error adding the song to the library")
                _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).jpg")  // Delete the downloaded thumbnail if available
                let alert = UIAlertController(title: "Error", message: errorStr, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler:nil))
                //currentViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
	
    private func buildSongForLibrary(sID: String, videoID: String?, songUrl: URL, newExtension: String, songTitle: String?, artists: NSMutableArray, playlistTitle: String?) -> Song {
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
    
    func addSongToLibraryArray(song: Song) {
        self.songLibrary.songList.append(song)
        libraryVC.tableView.reloadData()
    }
    
    func removeSongFromLibraryArray(song: Song) {
        for i in 0..<songLibrary.songList.count {
            if song == songLibrary.songList[i] {
                self.songLibrary.songList.remove(at: i)
                libraryVC.tableView.reloadData()
                return
            }
        }
    }
    
    func filterSongTitle(_ title: String?) -> String? {
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
            var text = textToRemove[i]
            featuresToRemove.append("\(text)")
            featuresToRemove.append("(\(text))")
            featuresToRemove.append("[\(text)]")
            featuresToRemove.append("{\(text)}")
            featuresToRemove.append("<\(text)>")
            featuresToRemove.append("|\(text)|")
            text = textToRemove[i].lowercased()
            featuresToRemove.append("\(text)")
            featuresToRemove.append("(\(text))")
            featuresToRemove.append("[\(text)]")
            featuresToRemove.append("{\(text)}")
            featuresToRemove.append("<\(text)>")
            featuresToRemove.append("|\(text)|")
            text = textToRemove[i].uppercased()
            featuresToRemove.append("\(text)")
            featuresToRemove.append("(\(text))")
            featuresToRemove.append("[\(text)]")
            featuresToRemove.append("{\(text)}")
            featuresToRemove.append("<\(text)>")
            featuresToRemove.append("|\(text)|")
        }
        for item in featuresToRemove {
            if filteredTitle.contains(item) {
                filteredTitle = filteredTitle.replacingOccurrences(of: item, with: "")
                print("removed occurance of \(item) from song title")
            }
        }
        return filteredTitle
    }
    
    /// Check if a song is in the library that matches parameter videoID
    func hasSongInLibrary(videoID: String?) -> Bool{
        if videoID != nil {
            for song in songLibrary.songList {
                let songID = song.id
                if songID.contains(videoID!) {
                    print("song \(song.title) found in library")
                    print("videoID: \(videoID!) is contained in songID: \(songID)")
                    return true
                }
            }
        }
        print("videoID: \(videoID!) was not found in the library")
        return false
    }
    
    func findSongIDfrom(videoID: String?) -> String?{
        if videoID != nil {
            for song in songLibrary.songList {
                let songID = song.id
                if songID.contains(videoID!) {
                    print("videoID: \(videoID!) is contained in songID: \(songID)")
                    return songID
                }
            }
        }
        print("videoID: \(videoID!) was not found in the library")
        return nil
    }
    
	func enrichSong(songDict: SongDict, fromMetadataDict mdDict: SongDict) -> Song {
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
    
	func deleteSongFromLibrary(songID: String) {
        QueueManager.shared.removeAllInstancesFromQueue(songID: songID)
        PlaylistsManager.shared.removeFromAllPlaylists(songID: songID)
        var song : Song
		for i in 0 ..< songLibrary.songList.count {
            song = songLibrary.songList[i]
			if song.id == songID {
                let songExt = song.fileExtension
				if LocalFilesManager.deleteFile(withNameAndExtension: "\(songID).\(songExt)") {
					_ = LocalFilesManager.deleteFile(withNameAndExtension: "\(songID).jpg")
                    songLibrary.songList.remove(at: i)
				}
				break
			}
		}
        LocalFilesManager.storeLibrary(songLibrary)
        DatabaseManager.shared.saveLibraryToDatabase()
        PlaylistsManager.shared.homeVC.reloadPlaylistDetailsVCTableView()
        libraryVC.tableView.reloadData()
	}

	func checkSongExistInLibrary(songLink: String) -> Bool {
        fetchLibraryFromLocalStorage()
		for i in 0 ..< songLibrary.songList.count {
            let song = songLibrary.songList[i]
            if song.link == songLink {
				return true
			}
		}
		return false
	}

	func getSong(forID songID: String) -> Song? {
        fetchLibraryFromLocalStorage()
        var songDict : Song
		for i in 0 ..< songLibrary.songList.count {
			songDict = songLibrary.songList[i]
			if songDict.id == songID {
				return songDict
			}
		}
		return nil
	}

//    func updateSong(newSong: Song) {
//        refreshSongLibraryFromLocalStorage()
//		var songDict = Song()
//		for i in 0 ..< songLibrary.songList.count {
//			songDict = songLibrary.songList.object(at: i) as! Song
//            if songDict.id == newSong.id {
//                songLibrary.songList.replaceObject(at: i, with: newSong)
//                saveSongLibraryToLocalStorage()
//                self.updateLibraryToDatabase()
//				break
//			}
//		}
//    }
    
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

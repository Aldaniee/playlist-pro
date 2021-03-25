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
    
    final let LIBRARY_KEY = "LibraryArray"
    final let LIBRARY_DISPLAY = "Music"
    
	enum ValueType {
		case min
		case max
	}
    
    // A playlist storing all songs
    var songLibrary = Playlist(title: "LibraryArray")
    
    var libraryVC = LibraryViewController()
    
    init() {
        refreshSongLibraryFromLocalStorage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    
    /// WARNING – this function is expensive and cannot be called just anyway
    /// 1. Downloads library array from the database based on the current logged in user
    /// 2. Downloads all missing song files from youtube on the background thread
    /// 3. Deletes all downloaded songs that are NOT in the library array
    /// This should ONLY be called when a new user is logged in who was not previously logged in
    func pullLocalLibraryFromDatabase() {
        if(Auth.auth().currentUser == nil) {
            print("ERROR: no user logged in. You should never get here. If no email account is logged in then an anonymous account should be logged in.")
            return
        }
        DatabaseManager.shared.downloadSongDictLibrary(user: Auth.auth().currentUser!, oldLibrary: songLibrary.songList) { newLibrary in

            let oldLibrary = NSMutableArray(array: self.songLibrary.songList)
            self.songLibrary.songList = [Song]()

            print("Checking for missing songs to download")
            
            var start = CFAbsoluteTimeGetCurrent()
            self.downloadMissingLibraryFiles(oldLibrary: oldLibrary, newLibrary: NSMutableArray(array: newLibrary))
            print("Download of all missing songs complete")
            print("Took \(CFAbsoluteTimeGetCurrent() - start) seconds")
            
            start = CFAbsoluteTimeGetCurrent()
            print("Deleting all excess songs from file storage")
            self.deleteExcessSongs(oldLibrary: oldLibrary, newLibrary: NSMutableArray(array: newLibrary))
            print("Delete of all excess songs from file storage complete")
            print("Took \(CFAbsoluteTimeGetCurrent() - start) seconds")
            
            LocalFilesManager.storeSongArray(self.songLibrary.songList, forKey: self.LIBRARY_KEY)
            self.libraryVC.tableView.reloadData()
        }
    }
    func deleteExcessSongs(oldLibrary: NSMutableArray, newLibrary: NSMutableArray) {
        for element in oldLibrary {
            let song = element as! Song
            let id = song.id
            let name = song.title
            if newLibrary.contains(song) == false {
                let didDelete = LocalFilesManager.deleteFile(withNameAndExtension: "\(id).m4a")
                _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(id).jpg")
                
                if didDelete {
                    print("Song named: \(name) removed from local files successfully")
                }
                else {
                    print("Song named: \(name) could not be removed from local files")
                }
            } else {
                print("Song named: \(name) wasn't removed from local files")

            }
        }

    }
    func refreshSongLibraryFromLocalStorage() {
        songLibrary.songList = LocalFilesManager.retreiveSongArray(forKey: LIBRARY_KEY)
        libraryVC.tableView.reloadData()
    }

    func updateLibraryToDatabase() {
        if(Auth.auth().currentUser == nil) {
            print("ERROR: no user logged in. You should never get here. If no email account is logged in then an anonymous account should be logged in.")
            return
        }
        DatabaseManager.shared.updateLibrary(library: songLibrary, user: Auth.auth().currentUser!) { error in
            if(error) {
                print("ERROR: \(error)")
                return
            }
        }
    }
	/*
	If the following parameters have no value then pass nil and the function will handle it
		Song ID -> will generate a custom id
		Song Title -> will be set to Song ID
		Thumbnail URL -> It will skip downloading a thumbnail image
	*/
    func addSongToLibrary(songTitle: String?, artists: NSMutableArray, songUrl: URL, songExtension: String , thumbnailUrl: URL?, videoID: String?, playlistTitle: String?, completion: (() -> Void)? = nil) {
        
        var sID = videoID == nil ? "dl_" + generateIDFromTimeStamp() : "yt_" + videoID! + generateIDFromTimeStamp()
        
        if self.hasSongInLibrary(videoID: videoID) {
            print("Song \(songTitle ?? "??") found in library")
            // SongIDs are of the format yt_ + videoID + generateIDFromTimeStamp()
            // generateIDFromTimeStamp() is different everytime it is run
            // If we wish to download the thumbnail and audio again for an already generated songDict
            // we need to use to old songID so that the file location matches the songDict
            sID = findSongIDfrom(videoID: videoID)!
        }
            //self.addSongDictToLibraryArray(sID: sID, videoID: videoID, songUrl: songUrl, newExtension: ".m4a", songTitle: songTitle, artists: artists, playlistTitle: playlistTitle) {
            //    completion?()
            //}
        if !LocalFilesManager.checkFileExist(sID) {
            var newExtension: String
            var errorStr: String?
            
            //let currentViewController = UIApplication.getCurrentViewController()
            //currentViewController?.showProgressView(onView: (currentViewController?.view)!, withTitle: "Downloading...")

            let dispatchGroup = DispatchGroup()  // To keep track of the async download group
            print("Starting the required downloads for song")
            dispatchGroup.enter()
            if songExtension == "mp4" {
                LocalFilesManager.downloadFile(from: songUrl, filename: sID, extension: songExtension, completion: { error in
                    if error == nil  {
                        print("Converting Video to Audio")
                        LocalFilesManager.extractAudioFromVideo(songID: sID, completion: { error in
                            
                            print("Deleting Video")
                            _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).mp4")  // Delete the downloaded video

                            dispatchGroup.leave()
                            if error != nil {  // Failed to extract audio from video
                                _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).m4a")  // Delete the extracted audio if available
                                errorStr = error!.localizedDescription
                            }
                        })
                    } else {
                        _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).mp4")  // Delete the downloaded video if available
                        print("Error downloading video: " + error!.localizedDescription)
                        dispatchGroup.leave()
                        errorStr = error!.localizedDescription
                    }
                })
                newExtension = "m4a"
            } else {
                LocalFilesManager.downloadFile(from: songUrl, filename: sID, extension: songExtension, completion: { error in
                    dispatchGroup.leave()
                    if error != nil  {
                        _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).\(songExtension)")  // Delete the downloaded video if available
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
                        self.addSongDictToLibraryArray(sID: sID, videoID: videoID, songUrl: songUrl, newExtension: newExtension, songTitle: songTitle, artists: artists, playlistTitle: playlistTitle) {
                            completion?()
                        }
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
    }
	
    private func addSongDictToLibraryArray(sID: String, videoID: String?, songUrl: URL, newExtension: String, songTitle: String?, artists: NSMutableArray, playlistTitle: String?, completion: (() -> Void)? = nil) {
        let duration = LocalFilesManager.extractDurationForSong(songID: sID, songExtension: newExtension)
        let link = videoID == nil ? songUrl.absoluteString : "https://www.youtube.com/embed/\(videoID ?? "UNKNOWN_ERROR")"
        let song = [SongValues.id: sID,
                            SongValues.title: songTitle ?? sID,
                            SongValues.artists: artists,
                            SongValues.album: "",
                            SongValues.releaseYear: "",
                            SongValues.duration: duration,
                            SongValues.lyrics: "",
                            SongValues.link: link,
                            SongValues.fileExtension: newExtension] as SongDict
        let metadataDict = LocalFilesManager.extractSongMetadata(songID: sID, songExtension: newExtension)
        let enrichedDict = self.enrichSongDict(song, fromMetadataDict: metadataDict)
        
        self.addSongDictToLibraryArray(song: enrichedDict)
        
        if (playlistTitle != nil) {
            PlaylistsManager.shared.addSongToPlaylist(song: enrichedDict, playlistName: playlistTitle!)
        }

        LocalFilesManager.storeSongArray(songLibrary.songList, forKey: LIBRARY_KEY)
        self.updateLibraryToDatabase()
        
        completion?()
    }
    
    func addSongDictToLibraryArray(song: Song) {
        self.songLibrary.songList.append(song)
        libraryVC.tableView.reloadData()
    }
    
    /// Given the library of songDicts is correct, download all of the missing audio files from youtube
    func downloadMissingLibraryFiles(oldLibrary: NSMutableArray, newLibrary: NSMutableArray) {
        for element in newLibrary {
            let song = element as! Song
            let songName = song.title
            var songID = song.id
            if (!oldLibrary.contains(song)) {
                print("File not found for song: \(songName). Downloading audio.")
                let title = song.title
                let artistArray = NSMutableArray(array: song.artists)
                if songID.contains("yt_") {
                    songID = songID.substring(fromIndex: 3)
                    songID = songID.substring(toIndex: 11)
                }
                YoutubeSearchManager.shared.downloadYouTubeVideo(videoID: songID, title: title, artistArray: artistArray, playlistTitle: nil)
            } else {
                print("Song already found for: \(songName), skipping download")
            }
        }

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
    
	func enrichSongDict(_ songDict: SongDict, fromMetadataDict mdDict: SongDict) -> Song {
        
        
        
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
    
	func deleteSongDictFromLibrary(songID: String) {
        QueueManager.shared.removeAllInstancesFromQueue(songID: songID)
        PlaylistsManager.shared.removeFromAllPlaylists(songID: songID)
        var songDict : Song
		for i in 0 ..< songLibrary.songList.count {
            songDict = songLibrary.songList[i]
			if songDict.id == songID {
                let songExt = songDict.fileExtension
				if LocalFilesManager.deleteFile(withNameAndExtension: "\(songID).\(songExt)") {
					_ = LocalFilesManager.deleteFile(withNameAndExtension: "\(songID).jpg")
                    deleteSongDictFromLibrary(song: songDict)
				}
				break
			}
		}
        UserDefaults.standard.set(songLibrary.songList, forKey: LIBRARY_KEY)
        self.updateLibraryToDatabase()
	}
    
    func deleteSongDictFromLibrary(song: Song) {
        let temp = NSMutableArray(array: songLibrary.songList)
        temp.remove(song)
        songLibrary.songList = temp as! [Song]
        libraryVC.tableView.reloadData()
    }

	func checkSongExistInLibrary(songLink: String) -> Bool {
        refreshSongLibraryFromLocalStorage()
        var songDict : Song
		for i in 0 ..< songLibrary.songList.count {
            songDict = songLibrary.songList[i]
            if songDict.link == songLink {
				return true
			}
		}
		return false
	}

	func getSong(forID songID: String) -> Song? {
        refreshSongLibraryFromLocalStorage()
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
			str += letters[timestamp%10]
			timestamp /= 10
		}
		return str
	}
}

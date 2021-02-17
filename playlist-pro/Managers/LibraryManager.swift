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

	enum SongProperties: String {
		case id = "id"
		case link = "link"
		case fileExtension = "fileExtension"
		case title = "title"
		case artists = "artists"
		case album = "album"
		case releaseYear = "releaseYear"
		case duration = "duration"
		case lyrics = "lyrics"
		case tags = "tags"
	}
	enum ValueType {
		case min
		case max
	}
    // An array storing all songs
	var songLibrary: Playlist!
    
    // An array of playlists in the application
    init() {
        self.songLibrary = Playlist.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
    func importLibraryFromDatabase() {
        if(Auth.auth().currentUser == nil) {
            print("ERROR: no user logged in. You should never get here. If no email account is logged in then an anonymous account should be logged in.")
            return
        }
        let newLibrary = DatabaseManager.shared.getLibrary(user: Auth.auth().currentUser!, oldLibrary: songLibrary.getSongList()) { error in
            if(error) {
                print("ERROR: \(error)")
                return
            }
        }
        self.downloadMissingSongs(newLibrary: newLibrary)
        UserDefaults.standard.set(newLibrary, forKey: "LibraryArray")
        self.songLibrary.refreshPlaylist()
        deleteExcessSongs(songLibraryArray: songLibrary.getSongList())

    }
    func downloadMissingSongs(newLibrary: NSMutableArray) {
        let oldLibrary = songLibrary.getSongList()
        for song in newLibrary {
            if (!oldLibrary.contains(song)) {
                // TODO: Download missing songs with song["link"]

            }
        }
    }
    func deleteExcessSongs(songLibraryArray: NSMutableArray) {
        // TODO: Delete any songs not in library array
    }
    func updateLibraryToDatabase() {
        if(Auth.auth().currentUser == nil) {
            print("ERROR: no user logged in. You should never get here. If no email account is logged in then an anonymous account should be logged in.")
            return
        }
        DatabaseManager.shared.updateLibrary(library: songLibrary, user: Auth.auth().currentUser!) { error in
            if(error ) {
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
    func addSongToLibrary(songTitle: String?, songUrl: URL, songExtension: String , thumbnailUrl: URL?, songID: String?, completion: (() -> Void)? = nil) {
		let sID = songID == nil ? "dl_" + generateIDFromTimeStamp() : "yt_" + songID! + generateIDFromTimeStamp()
		var newExtension: String
		var errorStr: String?
		
		let currentViewController = UIApplication.getCurrentViewController()
		currentViewController?.showProgressView(onView: (currentViewController?.view)!, withTitle: "Downloading...")

		let dispatchGroup = DispatchGroup()  // To keep track of the async download group
		print("Starting the required downloads for song")
		dispatchGroup.enter()
		if songExtension == "mp4" {
			LocalFilesManager.downloadFile(from: songUrl, filename: sID, extension: songExtension, completion: { error in
				if error == nil  {
					LocalFilesManager.extractAudioFromVideo(songID: sID, completion: { error in
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
		
		if let imageUrl = thumbnailUrl {
			dispatchGroup.enter()
			LocalFilesManager.downloadFile(from: imageUrl, filename: sID, extension: "jpg", completion: { error in
				dispatchGroup.leave()
				if error != nil  {
					print("Error downloading thumbnail: " + error!.localizedDescription)
				}
			})
		}
		
		dispatchGroup.notify(queue: DispatchQueue.main) {  // All async download in the group completed
			currentViewController?.removeProgressView()
			if errorStr == nil {
				print("All async download in the group completed")
				let duration = LocalFilesManager.extractDurationForSong(songID: sID, songExtension: newExtension)
				let link = songID == nil ? songUrl.absoluteString : "https://www.youtube.com/embed/\(songID ?? "UNKNOWN_ERROR")"
				let songDict = ["id": sID,
                                "title": songTitle ?? sID,
                                "artists": "",
                                "album": "",
								"releaseYear": "",
                                "duration": duration,
                                "lyrics": "",
								"link": link,
                                "fileExtension": newExtension] as [String : Any]
				let metadataDict = LocalFilesManager.extractSongMetadata(songID: sID, songExtension: newExtension)
				let enrichedDict = self.enrichSongDict(songDict, fromMetadataDict: metadataDict)
                self.songLibrary.add(song: enrichedDict)
                self.updateLibraryToDatabase()
                /*if (playlistID != nil) {
                    print("Adding song to playlist: \(playlistID!)")
                    if(playlistID! >= 0 && playlistID! < self.playlistLibraryArray.count) {
                        self.playlistLibraryArray[playlistID!].add(song: enrichedDict)
                    }
                }*/
                UserDefaults.standard.set(self.songLibrary.getSongList(), forKey: "LibraryArray")
                self.updateLibraryToDatabase()
                self.songLibrary.refreshPlaylist()
				completion?()
			} else {	// In case of error in adding the song to the library
				_ = LocalFilesManager.deleteFile(withNameAndExtension: "\(sID).jpg")  // Delete the downloaded thumbnail if available
				let alert = UIAlertController(title: "Error", message: errorStr, preferredStyle: UIAlertController.Style.alert)
				alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler:nil))
				currentViewController?.present(alert, animated: true, completion: nil)
			}
		}
    }
	
	func enrichSongDict(_ songDict: Dictionary<String, Any>, fromMetadataDict mdDict: Dictionary<String, Any>) -> Dictionary<String, Any> {
		var enrichredDict = songDict
		var key: String
		let songID = songDict["id"] as! String
		let songTitle = songDict["title"] as! String
		let songAlbum = songDict["album"] as! String
		let songYear = songDict["releaseYear"] as! String
		for (k, val) in mdDict {
			if (val as? String ?? "") == "" && (val as? Data ?? Data()).isEmpty {
				continue
			}
			key = getKey(forMetadataKey: k)

			if key == "title" && (songTitle == songID || songTitle == "") {  // if metadata has value and song title is set to default value or empty String
				enrichredDict["title"] = val as! String
				
			} else if key == "artist" {
				(enrichredDict["artists"] as! NSMutableArray).add(val as! String)
				
			} else if key == "album" && songYear == "" {  // if metadata has value and song album is set to default value
				enrichredDict["album"] = val as! String

			} else if key == "year" && songAlbum == "" {  // if metadata has value and song album is set to default value
				enrichredDict["releaseYear"] = val as! String

			} else if key == "type" {
				(enrichredDict["tags"] as! NSMutableArray).add(val as! String)
				
			} else if key == "artwork" && !LocalFilesManager.checkFileExist(songID + ".jpg") {
				if let jpgImageData = UIImage(data: val as! Data)?.jpegData(compressionQuality: 1) {  // make sure image is jpg
					LocalFilesManager.saveImage(UIImage(data: jpgImageData), withName: songID)
				}
				
			} else {
				print("songDict not enriched for key: " + key + " -> " + String(describing: val))
			}
		}
		return enrichredDict
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
		var songDict = Dictionary<String, Any>()
		for i in 0 ..< songLibrary.count() {
            songDict = songLibrary.get(at: i)
			if songDict["id"] as! String == songID {
				let songExt = (songDict["fileExtension"] as? String) ?? "m4a"  //support legacy code
				if LocalFilesManager.deleteFile(withNameAndExtension: "\(songID).\(songExt)") {
					_ = LocalFilesManager.deleteFile(withNameAndExtension: "\(songID).jpg")
                    songLibrary.remove(song: songDict)
				}
				break
			}
		}
        UserDefaults.standard.set(songLibrary.getSongList(), forKey: "LibraryArray")
        self.updateLibraryToDatabase()
	}

	func checkSongExistInLibrary(songLink: String) -> Bool {
        self.songLibrary.refreshPlaylist()
		var songDict = Dictionary<String, Any>()
		for i in 0 ..< songLibrary.count() {
            songDict = songLibrary.get(at: i)
			if songDict["link"] as! String == songLink {
				return true
			}
		}
		return false
	}

	func getSong(forID songID: String) -> Dictionary<String, Any> {
        self.songLibrary.refreshPlaylist()
		var songDict = Dictionary<String, Any>()
		for i in 0 ..< songLibrary.count() {
			songDict = songLibrary.get(at: i)
			if songDict["id"] as! String == songID {
				return songDict
			}
		}
		return Dictionary()
	}

    func updateSong(newSong: Dictionary<String, Any>) {
        self.songLibrary.refreshPlaylist()
		var songDict = Dictionary<String, Any>()
		for i in 0 ..< songLibrary.count() {
			songDict = songLibrary.get(at: i)
			if songDict["id"] as! String == newSong["id"] as! String {
                songLibrary.replace(index: i, song: newSong)
                UserDefaults.standard.set(songLibrary.getSongList(), forKey: "LibraryArray")
                self.updateLibraryToDatabase()
				break
			}
		}
    }
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

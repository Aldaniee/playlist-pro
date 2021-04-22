//
//  LocalFilesManager.swift
//  YouTag
//
//  Created by Youstanzr on 3/1/20.
//  Copyright © 2020 Youstanzr. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class LocalFilesManager {
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	static func getLocalFileURL(withNameAndExtension fileName_ext: String) -> URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName_ext)
	}
	
	static func getLocalFileSize(fileName_ext: String) -> String {
		do {
			let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
			let documentsDirectory = paths[0]
			let dataPathStr = documentsDirectory + "/\(fileName_ext)"
			let attr = try FileManager.default.attributesOfItem(atPath: dataPathStr)
			let fileSize = attr[FileAttributeKey.size] as! UInt64
			return ByteCountFormatter().string(fromByteCount: Int64(bitPattern: fileSize))
		} catch {
			print("Error: \(error.localizedDescription)")
			return ""
		}
	}
	
	static func downloadFile(from link: URL, filename: String, extension ext: String, completion: ((Error?) -> Void)? = nil) {
		let destination: DownloadRequest.Destination = { _, _ in
			let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
			let fileURL = documentsURL.appendingPathComponent(filename + "." + ext)

			return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
		}

		AF.download(link, to: destination).downloadProgress { progress in
			//UIApplication.getCurrentViewController()?.updateProgressView(to: progress.fractionCompleted)
		}.response { response in
			if response.error == nil {
				completion?(nil)
			} else {
				print("Error downloading file: " + (response.error?.localizedDescription ?? "Unknown error"))
				completion?(response.error)
			}
		}
	}
	
    
	static func extractAudioFromVideo(songID: String, completion: ((Error?) -> Void)? = nil) {
		let in_url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(songID).mp4")
		let out_url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(songID).m4a")
		let asset = AVURLAsset(url: in_url)
		
		asset.writeAudioTrack(to: out_url, success: {
			print("Converted video-mp4 to audio-m4a: \(songID)")
			completion?(nil)
		}) { (error) in
			print(error)
			completion?(error)
		}
	}
	
	static func extractDurationForSong(songID: String, songExtension: String) -> String {
		let asset = AVAsset(url: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songID).\(songExtension)"))
		return TimeInterval(CMTimeGetSeconds(asset.duration)).stringFromTimeInterval()
	}

	static func extractSongMetadata(songID: String, songExtension: String) -> SongDict {
		var dict = SongDict()
		let asset = AVAsset(url: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songID).\(songExtension)"))
		for item in asset.metadata {
//			print(String(describing: item.commonKey?.rawValue) + "\t" + String(describing: item.key) + " -> " + String(describing: item.value))
			guard let key = item.commonKey?.rawValue ?? item.key?.description, let value = item.value else {
				continue
			}
			dict[key] = value
		}
		return dict
	}

	static func saveImage(_ image: UIImage?, withName filename: String) {
		guard let img = image else {
			return
		}
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let documentsDirectory = paths[0]
		let dataPathStr = documentsDirectory + "/" + filename + ".jpg"
		
		let dataPath = URL(fileURLWithPath: dataPathStr)
		do {
			try img.jpegData(compressionQuality: 1.0)?.write(to: dataPath, options: .atomic)
		} catch {
			print("file cant not be save at path \(dataPath), with error : \(error)");
		}
	}
    
    static func deleteSong(song: Song) -> Bool {
        if LocalFilesManager.deleteFile(withNameAndExtension: "\(song.id).\(song.fileExtension)") {
            _ = LocalFilesManager.deleteFile(withNameAndExtension: "\(song.id).jpg")
            return true
        }
        else {
            print("ERROR: deleting song failed")
            return false
        }
    }
    
	static func deleteFile(withNameAndExtension filename_ext: String) -> Bool {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let documentsDirectory = paths[0]
		let dataPathStr = documentsDirectory + "/" + filename_ext
		if FileManager.default.fileExists(atPath: dataPathStr) {
			do {
				try FileManager.default.removeItem(atPath: dataPathStr)
			} catch let removeError {
				print("couldn't remove file at path", removeError.localizedDescription)
				return false
			}
		}
		return true
	}
	
	static func checkFileExist (_ filename_ext: String) -> Bool {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let documentsDirectory = paths[0]
		let dataPathStr = documentsDirectory + "/" + filename_ext
		return FileManager.default.fileExists(atPath: dataPathStr)
	}
	
	static func clearTmpDirectory() {
		do {
			let tmpDirURL = FileManager.default.temporaryDirectory
			let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: tmpDirURL.path)
			try tmpDirectory.forEach { file in
				let fileUrl = tmpDirURL.appendingPathComponent(file)
				try FileManager.default.removeItem(atPath: fileUrl.path)
			}
		} catch {
			print("Cleaning Tmp Directory Failed: " + error.localizedDescription)
		}
	}
    
    static func encodeSongArray(_ songArray: [Song]) -> NSArray {
        let encodedSongArray = NSMutableArray()
        for song in songArray {
            let encoder = JSONEncoder()
            if let encodedSong = try? encoder.encode(song) {
                encodedSongArray.add(encodedSong)
            }
            else {
                print("Encoding Error")
                return NSArray()
            }
        }
        return NSArray(array: encodedSongArray)
    }
    static func decodeSongArray(_ encodedSongArray: NSArray) -> [Song]{
        var songArray = [Song]()
        for encodedSong in encodedSongArray {
            let decoder = JSONDecoder()
            if let decodedSong = try? decoder.decode(Song.self, from: encodedSong as! Data) {
                songArray.append(decodedSong)
            }
            else {
                print("Decoding Error")
                return [Song]()
            }
        }
        return songArray
    }
    
    
    static func storeEmail(email: String) {
        UserDefaults.standard.set(email, forKey: "email")
    }
    static func retreiveEmail() -> String {
        return UserDefaults.standard.value(forKey: "email") as! String? ?? ""
    }
    
    static func storeNumPlaylists(numPlaylists: Int) {
        UserDefaults.standard.set(numPlaylists, forKey: "PlaylistsArray")
    }
    static func retreiveNumPlaylists() -> Int {
        return UserDefaults.standard.value(forKey: "PlaylistsArray") as! Int? ?? 0
    }

    static func retreiveLibrary() -> Playlist {
        guard let encoded = UserDefaults.standard.object(forKey: "library") as? Data else {
            print("Library Decoding Error")
            return Playlist(title: "library")
        }
        return try! PropertyListDecoder().decode(Playlist.self, from: encoded)
    }
    static func retreivePlaylists() -> [Playlist] {
        guard let encoded = UserDefaults.standard.object(forKey: "playlists") as? Data else {
            print("Playlist Array Decoding Error")
            return [Playlist]()
        }
        return try! PropertyListDecoder().decode([Playlist].self, from: encoded)
    }
    static func storePlaylists(_ playlists: [Playlist]) {
        // Store playlist object
        try? UserDefaults.standard.set(PropertyListEncoder().encode(playlists), forKey: "playlists")
    }
    static func storeLibrary(_ library: Playlist) {
        // Store playlist object
        try? UserDefaults.standard.set(PropertyListEncoder().encode(library), forKey: "library")

    }
}
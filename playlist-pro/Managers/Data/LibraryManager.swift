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
    
    // A playlist storing all songs
    var songLibrary = Playlist(title: "library")
    
    var libraryVC = LibraryViewController()
    
    // MARK: Initialization
    init() {
        fetchLibraryFromLocalStorage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func storeLibrary() {
        LocalFilesManager.storeLibrary(songLibrary)
        DatabaseManager.shared.saveLibraryToDatabase()
    }
    
    func fetchLibraryFromLocalStorage() {
        songLibrary = LocalFilesManager.retreiveLibrary()
        libraryVC.reloadTableView()
    }
    
    // MARK: Adding/Removing Songs
    func addSongToLibraryArray(song: Song) {
        self.songLibrary.songList.append(song)
        self.libraryVC.reloadTableView()
        storeLibrary()
    }
    /// Given a new library of songDicts that is correct, download all of the missing audio files from youtube
    func downloadMissingLibraryFiles(oldLibrary: Playlist, newLibrary: Playlist) -> Int {
        var downloadCount = 0
        for newSong in newLibrary.songList {
            if !oldLibrary.songInPlaylist(song: newSong) {
                print("File not found for song: \(newSong.title). Downloading audio.")
                
                let id = newSong.getVideoId()
                let title = newSong.title
                let artistArray = NSMutableArray(array: newSong.artists)
                
                YoutubeManager.shared.downloadYouTubeVideoAddToLibrary(videoID: id, title: title, artistArray: artistArray, completion: { success in
                    print("Downloaded song: \(newSong.title)")
                    downloadCount += 1
                })
            }
        }
        return downloadCount
        
    }
    
    /// Given a user just logged in, download their entire library
    func downloadAllLibraryFiles(newLibrary: Playlist) -> Int {
        var downloadCount = 0
        for newSong in newLibrary.songList {
            let id = newSong.getVideoId()
            let title = newSong.title
            let artistArray = NSMutableArray(array: newSong.artists)
            
            YoutubeManager.shared.downloadYouTubeVideoAddToLibrary(videoID: id, title: title, artistArray: artistArray, completion: { success in
                print("Downloaded song: \(newSong.title)")
                downloadCount += 1
            })
        }
        return downloadCount

    }
    
    /// Removes a song object from the library array, does not modify storage
    private func removeSongFromLibraryArray(song: Song) {
        for i in 0..<songLibrary.songList.count {
            if song == songLibrary.songList[i] {
                
                QueueManager.shared.removeAllInstancesFromQueue(songID: song.id)
                PlaylistsManager.shared.removeFromAllPlaylists(songID: song.id)
                self.songLibrary.songList.remove(at: i)
                
                storeLibrary()
                
                PlaylistsManager.shared.homeVC.reloadPlaylistContentVCTableView()
                libraryVC.reloadTableView()
                return
            }
        }
    }
    /// Deletes a song object from the library array and the song file from storage
    func deleteSongFromLibrary(song: Song) -> Bool{
        if LocalFilesManager.deleteSong(song: song) {
            removeSongFromLibraryArray(song: song)
            print("Removing song named: \(song.title) from local files successfully")
            return true
        }
        print("ERROR: Song named: \(song.title) could not be removed from local files")
        return false
    }
    
    /// Deletes all excess songs from the library
    func deleteExcessSongs(oldLibrary: Playlist, newLibrary: Playlist) -> Int {
        var deleteCount = 0
        for oldSong in oldLibrary.songList {
            if !newLibrary.songInPlaylist(song: oldSong) {
                if deleteSongFromLibrary(song: oldSong) {
                    deleteCount += 1
                }
            }
        }
        return deleteCount

    }

    /// Is a song in storage from the downloaded from the video ID
    func videoAlreadyDownloaded(videoID: String) -> Bool {
        let songID = LibraryManager.shared.getSongfrom(videoID: videoID)?.id
        return songID != nil && LocalFilesManager.checkFileExist("\(songID!).m4a")
    }
    
    func getSongfrom(videoID: String?) -> Song? {
        if videoID != nil {
            for song in songLibrary.songList {
                let songID = song.id
                if songID.contains(videoID!) {
                    return song
                }
            }
        }
        return nil
    }
    func updateDuration(song: Song, duration: String) {
        PlaylistsManager.shared.updateDuration(song: song, duration: duration)
        for i in 0..<songLibrary.songList.count {
            if song == songLibrary.songList[i] {
                songLibrary.songList[i].duration = duration
                songLibrary.songList[i].endTime = duration
                storeLibrary()
                return
            }
        }
        print("ERROR: Song not found")
    }
}

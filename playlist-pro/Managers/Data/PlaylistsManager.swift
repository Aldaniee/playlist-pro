//
//  PlaylistsManager.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/4/21.
//

import Foundation
import FirebaseAuth

class PlaylistsManager {
    static let shared = PlaylistsManager()

    var playlists = [Playlist]()
        
    var homeVC = HomeViewController()
    
    // MARK: Init
    init() {
        fetchPlaylistsFromStorage()
    }
    
    // MARK: Creating/Deleting Playlists
    func addPlaylist(playlist: Playlist) {
        var playlist = playlist
        let uniqueTitle = generateUniqueTitle(from: playlist.title)
        playlist.title = uniqueTitle
        
        playlists.append(playlist)
        homeVC.reloadTableView()
        savePlaylistsToStorage()
    }
    
    func removePlaylist(playlist: Playlist) {
        if hasPlaylist(named: playlist.title) {
            for i in 0..<playlists.count {
                if playlists[i].title == playlist.title {
                    playlists.remove(at: i)
                    homeVC.reloadTableView()
                    savePlaylistsToStorage()
                    return
                }
            }
        }
        else {
            print("ERROR: Incorrect Playlist Name Removed")
        }
    }

    // MARK: Adding/Removing Songs
    func addSongToPlaylist(song: Song, playlistName: String) {
        if hasPlaylist(named: playlistName) {
            let index = getPlaylistIndex(title: playlistName)
            playlists[index].songList.append(song)
            homeVC.reloadPlaylistContentVCTableView()
            print("Added song \(song.title) to playlist \(playlistName)")
        }
        else {
            print("Tried adding song \(song.title) to playlist \(playlistName) but the playlist was not found")
        }
        savePlaylistsToStorage()
    }
    func removeFromPlaylist(playlist: Playlist, index: Int) {
        if hasPlaylist(named: playlist.title) {
            let indexOfPlaylist = getPlaylistIndex(title: playlist.title)
            playlists[indexOfPlaylist].songList.remove(at: index)
            homeVC.reloadPlaylistContentVCTableView()
            savePlaylistsToStorage()
        }
    }
    func removeFromAllPlaylists(songID: String) {
        for playlist in playlists {
            if hasSong(playlist: playlist, songID: songID) {
                removeAllInstancesOf(songID: songID, playlist: playlist)
            }
        }
    }
    func removeAllInstancesOf(songID: String, playlist: Playlist) {
        for index in 0..<playlist.songList.count {
            let song = playlist.songList[index]
            if (song.id == songID) {
                removeFromPlaylist(playlist: playlist, index: index)
            }
        }
    }
    func setImageForPlaylist(playlistName: String, image: UIImage) {
        if hasPlaylist(named: playlistName) {
            let index = getPlaylistIndex(title: playlistName)
            playlists[index].setImage(image: image)
            print("Added image to playlist \(playlistName)")
        }
        else {
            print("Tried adding image to playlist \(playlistName) but the playlist was not found")
        }
    }
    // MARK: Local Storage
    func savePlaylistsToStorage() {
        LocalFilesManager.storePlaylists(playlists)
        DatabaseManager.shared.savePlaylistsToDatabase()
    }
    func fetchPlaylistsFromStorage() {
        playlists = LocalFilesManager.retreivePlaylists()
        homeVC.reloadTableView()
    }
    
    // MARK: Accessors
    func hasPlaylist(named title: String) -> Bool {
        for playlist in playlists {
            if playlist.title == title {
                return true
            }
        }
        return false
    }
    
    func getPlaylistIndex(title: String) -> Int {
        for playlistIndex in 0 ..< playlists.count {
            if playlists[playlistIndex].title == title || playlists[playlistIndex].title == generateUniqueTitle(from: title){
                return playlistIndex
            }
        }
        return -1
    }
    
    func getPlaylist(named title: String) -> Playlist? {
        for playlist in playlists {
            if playlist.title == title {
                return playlist
            }
        }
        return nil
    }
    
    func hasSong(playlist: Playlist, songID: String) -> Bool {
        for song in playlist.songList {
            if (song.id == songID) {
                return true
            }
        }
        return false
    }
    
    func generateUniqueTitle(from title: String) -> String{
        var uniqueTitle = title
        if uniqueTitle == "" {
            uniqueTitle = "My Playlist"
        }
        if hasPlaylist(named: uniqueTitle) {
            // If the title is taken add a " 2" to the end
            var nextNum = 2  // If this is still taken incriment the number by 1 and try again
            while hasPlaylist(named: uniqueTitle) {
                uniqueTitle = uniqueTitle + " \(nextNum)"
                nextNum += 1
            }
        }
        return uniqueTitle
    }

}

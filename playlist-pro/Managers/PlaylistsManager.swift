//
//  PlaylistsManager.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/4/21.
//

import Foundation

class PlaylistsManager {
    static let shared = PlaylistsManager()
    static let PLAYLISTS_KEY = "PlaylistsArray"

    var playlists = [Playlist]()
        
    var homeVC = HomeViewController()
    
    init() {
        fetchPlaylistsFromStorage()
    }
    func fetchPlaylistsFromStorage() {
        playlists = [Playlist]()
        let numPlaylists = LocalFilesManager.retreiveNumPlaylists()
        
        for index in 0..<numPlaylists {
            let title = LocalFilesManager.retreivePlaylistTitle(forIndex: index)
            let songList = LocalFilesManager.retreiveSongArray(forKey: "playlist_songList_\(index)") 
            playlists.append(Playlist(title: title, songList: songList))
            homeVC.reloadTableView()
        }
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
    func removeFromPlaylist(playlist: Playlist, index: Int) {
        if hasPlaylist(named: playlist.title) {
            let indexOfPlaylist = getPlaylistIndex(title: playlist.title)
            playlists[indexOfPlaylist].songList.remove(at: index)
            homeVC.reloadTableView()
            savePlaylistsToStorage()
        }
    }
    
    func addPlaylist(title: String, songList: [Song]?) {
        let uniqueTitle = generateUniqueTitle(from: title)
        let playlist = Playlist(title: uniqueTitle, songList: songList ?? [Song]())
        playlists.append(playlist)
        homeVC.reloadTableView()
        savePlaylistsToStorage()
    }
    
    func addSongToPlaylist(song: Song, playlistName: String) {
        if hasPlaylist(named: playlistName) {
            let index = getPlaylistIndex(title: playlistName)
            playlists[index].songList.append(song)
            homeVC.reloadTableView()
            print("Added song \(song.title) to playlist \(playlistName)")
        }
        else {
            print("Tried adding song \(song.title) to playlist \(playlistName) but the playlist was not found")
        }
    }
    
    func savePlaylistsToStorage() {
        for index in 0..<playlists.count {
            LocalFilesManager.storeSongArray(playlists[index].songList, forKey: "playlist_songList_\(index)")
            LocalFilesManager.storePlaylistTitle(playlists[index].title, forIndex: index)
        }
        LocalFilesManager.storeNumPlaylists(numPlaylists: playlists.count)
    }
    
    func hasPlaylist(named title: String) -> Bool {
        for playlist in playlists {
            if playlist.title == title {
                return true
            }
        }
        return false
    }
    private func generateUniqueTitle(from title: String) -> String{
        var uniqueTitle = title
        if uniqueTitle == "" {
            uniqueTitle = "My Playlist"
        }
        if hasPlaylist(named: uniqueTitle) {
            // If the title is taken add a " 2" to the end
            var nextNum = 2  // If this is still taken incriment the number by 1 and try again
            while hasPlaylist(named: title) {
                nextNum += 1
            }
            uniqueTitle = uniqueTitle + " \(nextNum)"
        }
        return uniqueTitle
    }
    func getPlaylistIndex(title: String) -> Int {
        for playlistIndex in 0 ..< playlists.count {
            if playlists[playlistIndex].title == title {
                return playlistIndex
            }
        }
        return -1
    }
    func removeFromAllPlaylists(songID: String) {
        for playlist in playlists {
            if hasSong(playlist: playlist, songID: songID) {
                removeAllInstancesOf(songID: songID, playlist: playlist)
            }
        }
    }
    
    func hasSong(playlist: Playlist, songID: String) -> Bool {
        for song in playlist.songList {
            if (song.id == songID) {
                return true
            }
        }
        return false
    }

    func removeAllInstancesOf(songID: String, playlist: Playlist) {
        for index in 0..<playlist.songList.count {
            let song = playlist.songList[index]
            if (song.id == songID) {
                removeFromPlaylist(playlist: playlist, index: index)
            }
        }
    }

}

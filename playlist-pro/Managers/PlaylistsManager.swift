//
//  PlaylistsManager.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/4/21.
//

import Foundation

class PlaylistsManager {
    static let shared = PlaylistsManager()
    final let PLAYLISTS_KEY = "PlaylistsArray"

    var playlists = [Playlist]()
    
    let userDefaults = UserDefaults.standard
    
    init() {
        fetchPlaylistsFromStorage()
    }
    func fetchPlaylistsFromStorage() {
        playlists = [Playlist]()
        let numPlaylists = userDefaults.value(forKey: PLAYLISTS_KEY) as! Int? ?? 0
        for index in 0..<numPlaylists {
            let title = userDefaults.value(forKey: "playlist_title_\(index)") as! String
            let songList = NSMutableArray(array: userDefaults.value(forKey: "playlist_songList_\(index)") as! NSArray? ?? NSArray())
            playlists.append(Playlist(title: title, songList: songList))
        }
    }
    func removePlaylist(playlist: Playlist) {
        if hasPlaylist(title: playlist.title) {
            for i in 0..<playlists.count {
                if playlists[i].title == playlist.title {
                    playlists.remove(at: i)
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
        if hasPlaylist(title: playlist.title) {
            let indexOfPlaylist = getPlaylistIndex(title: playlist.title)
            playlists[indexOfPlaylist].songList.removeObject(at: index)
            savePlaylistsToStorage()
        }
    }
    func addPlaylist(title: String) {
        let uniqueTitle = getUniqueTitle(title: title)
        let playlist = Playlist(title: uniqueTitle, songList: LibraryManager.shared.songLibrary.songList)
        playlists.append(playlist)
        savePlaylistsToStorage()
    }
    
    func savePlaylistsToStorage() {
        for index in 0..<playlists.count {
            /*do {
                let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: playlists[index].songList, requiringSecureCoding: false)
            } catch let error {
                print("error when adding playlsit: \(error)")
            }*/
            userDefaults.set(playlists[index].songList, forKey: "playlist_songList_\(index)")
            userDefaults.set(playlists[index].title, forKey: "playlist_title_\(index)")
        }
        userDefaults.set(playlists.count, forKey: PLAYLISTS_KEY)
    }
    
    func hasPlaylist(title: String) -> Bool {
        for playlist in playlists {
            if playlist.title == title {
                return true
            }
        }
        return false
    }
    func getUniqueTitle(title: String) -> String{
        var uniqueTitle = title
        if uniqueTitle == "" {
            uniqueTitle = "My Playlist"
        }
        if hasPlaylist(title: uniqueTitle) {
            // If the title is taken add a " 2" to the end
            var nextNum = 2  // If this is still taken incriment the number by 1 and try again
            while hasPlaylist(title: title) {
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
        for songDict in playlist.songList {
            let song = (songDict as! Dictionary<String, Any>)
            if (song[SongValues.id] as! String == songID) {
                return true
            }
        }
        return false
    }

    func removeAllInstancesOf(songID: String, playlist: Playlist) {
        for index in 0..<playlist.songList.count {
            let song = (playlist.songList[index] as! Dictionary<String, Any>)
            if (song[SongValues.id] as! String == songID) {
                removeFromPlaylist(playlist: playlist, index: index)
            }
        }
    }

}

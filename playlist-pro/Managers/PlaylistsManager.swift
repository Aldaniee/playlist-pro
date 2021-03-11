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

    init() {
        UserDefaults.standard.set(NSMutableArray(), forKey: PLAYLISTS_KEY)
        refreshPlaylistsFromLocalStorage()
    }
    func refreshPlaylistsFromLocalStorage() {
        playlists = [Playlist]()
        let playlistTitles = NSMutableArray(array: UserDefaults.standard.value(forKey: PLAYLISTS_KEY) as? NSArray ?? NSArray())
        for title in playlistTitles {
            print(title)
            print("building playlist")
            let songListString = UserDefaults.standard.value(forKey: title as! String)
            playlists.append(Playlist(storageString: songListString as! String, title: title as! String))
        }
    }
    func addPlaylist(playlist: Playlist) {
        if playlist.title == "" {
            playlist.title = "My Playlist"
        }
        var title = playlist.title ?? "My Playlist"
        if hasPlaylist(title: title) {
            // If the title is taken add a " 2" to the end
            var nextNum = 2
            // If that is still taken incriment the number by 1 and try again
            while hasPlaylist(title: title) {
                nextNum += 1
                title = playlist.title ?? "My Playlist" + " \(nextNum)"
            }
        }
        playlist.title = title
        playlists.append(playlist)
        let titles = NSMutableArray(array: UserDefaults.standard.value(forKey: PLAYLISTS_KEY) as? NSArray ?? NSArray())
        titles.add(playlist.title!)
        UserDefaults.standard.set(titles, forKey: PLAYLISTS_KEY)
        UserDefaults.standard.set(playlist.convertPlaylistForStorage(), forKey: playlist.title)
    }
    func hasPlaylist(title: String) -> Bool {
        for playlist in playlists {
            if playlist.title! == title {
                return true
            }
        }
        return false
    }
    func getPlaylistIndex(title: String) -> Int {
        for playlistIndex in 0 ..< playlists.count {
            if playlists[playlistIndex].title == title {
                return playlistIndex
            }
        }
        return -1
    }

}

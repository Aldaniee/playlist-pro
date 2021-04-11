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
    
    init() {
        fetchPlaylistsFromStorage()
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
    
    func addPlaylist(playlist: Playlist) {
        var playlist = playlist
        let uniqueTitle = generateUniqueTitle(from: playlist.title)
        playlist.title = uniqueTitle
        
        playlists.append(playlist)
        homeVC.reloadTableView()
        savePlaylistsToStorage()
    }
    
    func buildPlaylistFromSpotifyPlaylist(spotifyPlaylist: SpotifyPlaylist, tracks: [AudioTrack]) {
        var playlist = Playlist(title: spotifyPlaylist.name, songList: [Song](), description: spotifyPlaylist.description)
        addPlaylist(playlist: playlist)
        for track in tracks {
            let artists = track.artists
            var searchText = "\(artists[0].name) - \(track.name)"
            if artists.count > 1 {
                searchText = searchText + " ft. "
                for i in 1..<track.artists.count {
                    searchText = searchText + " \(artists[i].name)"
                }
            }
            YoutubeSearchManager.shared.search(searchText: searchText) { videos in
                if videos != nil {
                    LibraryManager.shared.downloadVideoFromSearchList(videos: videos!, playlistName: playlist.title)
                }
            }
        }
        if /*spotifyPlaylist.images.count == 0 && */playlist.songList.count > 0 {
            let firstSong = playlist.songList[0]
            let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(firstSong.id).jpg"))
            if let imgData = imageData {
                playlist.setImage(image: UIImage(data: imgData))
            }
        }
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
        savePlaylistsToStorage()
    }
    
    func savePlaylistsToStorage() {
        LocalFilesManager.storePlaylists(playlists)
        savePlaylistsToDatabase() 
    }
    func fetchPlaylistsFromStorage() {
        playlists = LocalFilesManager.retreivePlaylists()
        homeVC.reloadTableView()
    }
    
    func savePlaylistsToDatabase() {
        guard let user = Auth.auth().currentUser else {
            print("ERROR: no user logged in. You should never get here. If no email account is logged in then an anonymous account should be logged in.")
            return
        }
        DatabaseManager.shared.updatePlaylists(user: user, completion: { error in
            if(error) {
                print("ERROR: \(error)")
                return
            }
        })
    }
    func fetchPlaylistsFromDatabase() {
        guard let user = Auth.auth().currentUser else {
            print("ERROR: no user logged in. You should never get here. If no email account is logged in then an anonymous account should be logged in.")
            return
        }
        DatabaseManager.shared.downloadPlaylists(user: user) { playlists in
            print("Downloading user playlists")
            self.playlists = playlists
            self.homeVC.reloadTableView()
            LocalFilesManager.storePlaylists(playlists)
        }
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

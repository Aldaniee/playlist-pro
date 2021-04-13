//
//  DatabaseManager.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import FirebaseDatabase
import FirebaseAuth
import CodableFirebase

public class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    // MARK: - Public
    
    /// Check if email is available
    /// - Parameters
    ///     – email: String representing email
    public func emailAvailable(with email: String, completion: (Bool) -> Void) {
        completion(true)
    }

    /// Insert user data to database
    /// - Parameters
    ///     – email: String representing email
    ///     – completion: Async callback for result if database entry succeeded
    public func insertNewUser(with email: String, completion: @escaping (Bool) -> Void) {
        // Email is the database key
        // But @ and . are not allowed characters in a key
        // Call safeDatabaseKey implemented in Extensions.swift to convert
        let index = email.lastIndex(of: "@")!
        database.child(email.safeDatabaseKey()).setValue(["displayName": email.prefix(upTo: index)]) { error, _ in
            if error == nil {
                // succeeded
            }
            else {
                print(error!)
                // failed
            }
            
        }
    }
    
    func updateUserSpotifyAuth(user: User, completion: @escaping (Bool) -> Void) {
        let userPath = user.isAnonymous ? "anonymous-users/\(user.uid)" : "\(user.email!.safeDatabaseKey())"
        database.child("\(userPath)/access_token)").setValue(SpotifyAuthManager.shared.accessToken) { error, _ in
            if error == nil {
                // succeeded
                print("Successfully updated user access token to database")
            }
            else {
                print("Error while updating user access token to database")
                print(error!)
                // failed
            }
        }
        database.child("\(userPath)/refresh_token)").setValue(SpotifyAuthManager.shared.refreshToken) { error, _ in
            if error == nil {
                // succeeded
                print("Successfully updated user refresh token to database")
            }
            else {
                print("Error while updating user refresh token to database")
                print(error!)
                // failed
            }
        }
        database.child("\(userPath)/expirationDate)").setValue(SpotifyAuthManager.shared.tokenExpirationDate) { error, _ in
            if error == nil {
                // succeeded
                print("Successfully updated user expirationDate to database")
            }
            else {
                print("Error while updating user expirationDate to database")
                print(error!)
                // failed
            }
        }
    }
    func downloadUserSpotifyAuth(user: User) {
        
        let userPath = user.isAnonymous ?  "anonymous-users/\(user.uid)" : user.email!.safeDatabaseKey()
        database.child(userPath).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary {

                guard let refreshToken = dictionary["refresh_token"] as? String else {
                    print("No refresh token in database")
                    return
                }
                guard let accessToken = dictionary["access_token"] as? String else {
                    print("No refresh token in database")
                    return
                }
                guard let expirationDate = dictionary["expirationDate"] as? String else {
                    print("No refresh token in database")
                    return
                }
                UserDefaults.standard.setValue(accessToken, forKey: "access_token")
                UserDefaults.standard.setValue(refreshToken, forKey: "refresh_token")
                UserDefaults.standard.setValue(expirationDate, forKey: "expirationDate")
            }
            else {
                print("Snapshot Error")
            }
        });
    }
    /// Updates a user's music library on the database to match the library on the device
    /// - Parameters
    ///     - Async callback for result if database entry succeeded
    func updateLibrary(user: User, completion: @escaping (Bool) -> Void) {

        let library = LibraryManager.shared.songLibrary
        let userPath = user.isAnonymous ? "anonymous-users/\(user.uid)" : "\(user.email!.safeDatabaseKey())"
        database.child("\(userPath)/library").setValue(encodePlaylist(library)) { error, _ in
            if error == nil {
                // succeeded
                print("Successfully updated library to database")
            }
            else {
                print("Error While updating library to database")
                print(error!)
                // failed
            }
        }
    }
    /// Updates a user's music library on the device to match the database
    /// - Parameters
    ///     - Async callback for result if database entry succeeded
    func downloadLibrary(user: User, completion: @escaping (Playlist) -> Void) {
        
        let userPath = user.isAnonymous ?  "anonymous-users/\(user.uid)" :             user.email!.safeDatabaseKey()
        let key = "library"
        database.child(userPath).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary {

                guard let data = dictionary[key] as? [String : Any] else {
                    print("No library in database, return empty library")
                    completion(Playlist(title: key))
                    return
                }
                //dump(snapshot)
                completion(self.decodePlaylist(data))
            }
            else {
                print("Snapshot Error")
            }
        });
    }
    
    // MARK: - Library Functions

    
    /// WARNING – this function is expensive and cannot be called just anyway
    /// 1. Downloads library array from the database based on the current logged in user
    /// 2. Downloads all missing song files from youtube on the background thread
    /// 3. Deletes all downloaded songs that are NOT in the library array
    /// This should ONLY be called when a new user is logged in who was not previously logged in
    
    func fetchMusicFromDatabase() {
        guard let user = Auth.auth().currentUser else {
            print("ERROR: no user logged in. You should never get here. If no email account is logged in then an anonymous account should be logged in.")
            return
        }
        self.downloadLibrary(user: user) { newLibrary in
            var start = CFAbsoluteTimeGetCurrent()
            let oldEmail = LocalFilesManager.retreiveEmail()
            let oldLibrary = Playlist(playlist: LibraryManager.shared.songLibrary) // deep copy
            var downloadCount = 0
            if oldEmail != user.email {
                LibraryManager.shared.songLibrary.songList = [Song]()
            }
            if oldEmail != "" {
                start = CFAbsoluteTimeGetCurrent()
                let deleteCount = self.deleteExcessSongs(oldLibrary: oldLibrary, newLibrary: newLibrary)
                print("Removed \(deleteCount) songs in \(CFAbsoluteTimeGetCurrent() - start) seconds\n")
                print("\nDownloading missing songs")
                downloadCount = self.downloadMissingLibraryFiles(oldLibrary: oldLibrary, newLibrary: newLibrary)
            }
            else {
                print("\nDownloading entire library")
                downloadCount = self.downloadAllLibraryFiles(newLibrary: newLibrary)
            }
            print("Downloaded \(downloadCount) songs in \(CFAbsoluteTimeGetCurrent() - start) seconds\n")
            // TODO: UPDATE PLAYLISTS
            LibraryManager.shared.libraryVC.tableView.reloadData()
            LocalFilesManager.storeLibrary(LibraryManager.shared.songLibrary)
        }
        self.downloadPlaylists(user: user) { playlists in
            print("Downloading user playlists")
            PlaylistsManager.shared.playlists = playlists
            PlaylistsManager.shared.refreshAllPlaylistSongConnectionsToLibrary()
            PlaylistsManager.shared.homeVC.reloadTableView()
            LocalFilesManager.storePlaylists(playlists)
        }
    }

    func saveLibraryToDatabase() {
        guard let user = Auth.auth().currentUser else {
            print("ERROR: no user logged in. You should never get here. If no email account is logged in then an anonymous account should be logged in.")
            return
        }
        self.updateLibrary(user: user) { error in
            if(error) {
                print("ERROR: \(error)")
                return
            }
        }
        savePlaylistsToDatabase()
    }
    /// Given a user just logged in, download their entire library
    func downloadAllLibraryFiles(newLibrary: Playlist) -> Int {
        var downloadCount = 0
        for newSong in newLibrary.songList {
            if Auth.auth().currentUser != nil {
                print("Downloading songs interupted by logout")
                return downloadCount
            }
            let id = newSong.getVideoId()
            let title = newSong.title
            let artistArray = NSMutableArray(array: newSong.artists)
            
            YoutubeSearchManager.shared.downloadYouTubeVideo(videoID: id, title: title, artistArray: artistArray, playlistTitle: nil)
            downloadCount += 1
        }
        return downloadCount

    }
    
    func getVideoId(songId: String) -> String{
        var id = songId
        if songId.contains("yt_") {
            id = songId.substring(fromIndex: 3)
            id = songId.substring(toIndex: 11)
        }
        return id
    }
    
    /// Given the library of songDicts is correct, download all of the missing audio files from youtube
    func downloadMissingLibraryFiles(oldLibrary: Playlist, newLibrary: Playlist) -> Int {
        var downloadCount = 0
        for newSong in newLibrary.songList {
            if Auth.auth().currentUser != nil {
                print("Downloading songs interupted by logout")
                return downloadCount
            }
            var id = newSong.id
            if !oldLibrary.songInPlaylist(song: newSong) {
                let title = newSong.title
                print("File not found for song: \(newSong.title). Downloading audio.")
                let artistArray = NSMutableArray(array: newSong.artists)
                if id.contains("yt_") {
                    id = id.substring(fromIndex: 3)
                    id = id.substring(toIndex: 11)
                }
                YoutubeSearchManager.shared.downloadYouTubeVideo(videoID: id, title: title, artistArray: artistArray, playlistTitle: nil)
                downloadCount += 1
            } else {
                //print("Song found in library: \(name), skipping download")
            }
        }
        return downloadCount
        
    }
    func deleteExcessSongs(oldLibrary: Playlist, newLibrary: Playlist) -> Int {
        var deleteCount = 0
        for oldSong in oldLibrary.songList {
            if Auth.auth().currentUser != nil {
                print("deleting songs interupted by user being logged out")
                return deleteCount
            }
            if !newLibrary.songInPlaylist(song: oldSong) {
                let id = oldSong.id
                let name = oldSong.title
                let didDelete = LocalFilesManager.deleteFile(withNameAndExtension: "\(id).m4a")
                let didDeleteThumb = LocalFilesManager.deleteFile(withNameAndExtension: "\(id).jpg")
                
                if didDelete {
                    LibraryManager.shared.removeSongFromLibraryArray(song: oldSong)
                    deleteCount = deleteCount + 1
                    print("Removing song named: \(name) from local files successfully")
                }
                else {
                    print("ERROR: Song named: \(name) could not be removed from local files")
                }
                if didDeleteThumb {
                    print("Removing thumbnail for song named: \(name) from local files successfully")
                }
                else {
                    print("ERROR: Thumbnail for: \(name) could not be removed from local files")
                }
            } else {
                //print("Didn't remove song: \(name)")
            }
        }
        return deleteCount

    }
    
    // MARK: - Playlist Functions
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

    func downloadVideoFromSearchList(videos: [Video], playlistName: String?) {
        DispatchQueue.main.async {

            do {
                let video = videos[0]
                let videoID = video.videoId
                let title = try video.title.strippingHTML() ?? video.title
                let artistName = try video.artist.strippingHTML() ?? video.artist
                let artistArray = NSMutableArray(object: artistName)
                YoutubeSearchManager.shared.downloadYouTubeVideo(videoID: videoID, title: title, artistArray: artistArray, playlistTitle: playlistName) { success in
                    if success {
                        LibraryManager.shared.libraryVC.reloadTableView()
                        PlaylistsManager.shared.homeVC.reloadTableView()
                        PlaylistsManager.shared.homeVC.reloadPlaylistDetailsVCTableView()
                        return
                    }
                    else {
                        // If the previous video fails, download the next available searched video
                        self.downloadVideoFromSearchList(videos: Array<Video>() + videos[1...], playlistName: playlistName)
                    }
                }
            }
            catch {
                print("ERROR: strippingHTML error")
            }
        }
    }
    
    func updatePlaylists(user: User, completion: @escaping (Bool) -> Void) {
        let playlists = PlaylistsManager.shared.playlists
        let userPath = user.isAnonymous ?  "anonymous-users/\(user.uid)" :             user.email!.safeDatabaseKey()
        database.child("\(userPath)/playlists").setValue(encodePlaylists(playlists)) { error, _ in
            if error == nil {
                // succeeded
                print("Successfully updated playlists to database")
            }
            else {
                print("Error While updating playlists to database")
                print(error!)
                // failed
            }
        }
    }

    func downloadPlaylists(user: User, completion: @escaping ([Playlist]) -> Void) {
        let userPath = user.isAnonymous ?  "anonymous-users/\(user.uid)" : user.email!.safeDatabaseKey()
        database.child(userPath).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary {

                guard let data = dictionary["playlists"] as? [[String : Any]] else {
                    print("No playlists in database, return empty playlists")
                    completion([Playlist]())
                    return
                }
                //dump(snapshot)
                completion(self.decodePlaylists(data))
            }
            else {
                print("ERROR: Snapshot")
            }
        });
    }
    private func encodePlaylist(_ playlist: Playlist) -> [String : Any] {
        if let encodedPlaylist = try? FirestoreEncoder().encode(playlist) {
            return encodedPlaylist
        }
        else {
            print("ERROR: Failure encoding playlist: \(playlist)")
            return [String : Any]()
        }
    }
    private func decodePlaylist(_ encodedPlaylist: [String : Any]) -> Playlist{
        if let decodedPlaylist = try? FirestoreDecoder().decode(Playlist.self, from: encodedPlaylist) {
            return decodedPlaylist
        }
        else {
            print("ERROR: Failure decoding playlist")
            return Playlist(title: "")
        }
    }
    private func encodePlaylists(_ playlists: [Playlist]) -> [[String : Any]] {
        var returnArray = [[String : Any]]()
        for playlist in playlists {
            returnArray.append(encodePlaylist(playlist))
        }
        return returnArray
    }
    private func decodePlaylists(_ encodedPlaylists: [[String : Any]]) -> [Playlist] {
        var returnArray = [Playlist]()
        for encodedPlaylist in encodedPlaylists {
            returnArray.append(decodePlaylist(encodedPlaylist))
        }
        return returnArray
    }
}

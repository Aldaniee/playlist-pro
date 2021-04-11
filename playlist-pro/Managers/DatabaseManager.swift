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

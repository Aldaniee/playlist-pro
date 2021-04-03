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
    public func canCreateNewUser(with email: String, completion: (Bool) -> Void) {
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
    /// Updates a user's music library on the database to match the library on the device
    /// - Parameters
    ///     - Async callback for result if database entry succeeded
    func updateLibrary(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("ERROR: no user logged in. You should never get here. If no email account is logged in then an anonymous account should be logged in.")
            return
        }
        let library = LibraryManager.shared.songLibrary
        if(user.isAnonymous) {
            database.child("anonymous-users/\(user.uid)/library)").setValue(encodePlaylist(library)) { error, _ in
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
        else {
            if(user.email == nil) {
                print("error missing email")
            }
            else {
                database.child("\(user.email!.safeDatabaseKey())/library").setValue(encodePlaylist(library)) { error, _ in
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
        }

    }
    /// Updates a user's music library on the device to match the database
    /// - Parameters
    ///     - Async callback for result if database entry succeeded
    func downloadLibrary(completion: @escaping (Playlist) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("ERROR: no user logged in. You should never get here. If no email account is logged in then an anonymous account should be logged in.")
            return
        }
        var userPath : String!
        if(user.isAnonymous) {
            userPath = "anonymous-users/\(user.uid)"
        }
        else {
            userPath = user.email!.safeDatabaseKey()
        }
        database.child(userPath).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary {

                guard let data = dictionary["library"] as? [String : Any] else {
                    print("No library in database, return empty library")
                    completion(Playlist(title: "library"))
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
    
    func updatePlaylists(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("ERROR: no user logged in. You should never get here. If no email account is logged in then an anonymous account should be logged in.")
            return
        }
        let playlists = PlaylistsManager.shared.playlists
        if(user.isAnonymous) {
            database.child("anonymous-users/\(user.uid)/playlists)").setValue(encodePlaylists(playlists)) { error, _ in
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
        else {
            if(user.email == nil) {
                print("error missing email")
            }
            else {
                database.child("\(user.email!.safeDatabaseKey())/playlists").setValue(encodePlaylists(playlists)) { error, _ in
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
        }

    }

    func downloadPlaylists(completion: @escaping ([Playlist]) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("ERROR: no user logged in. You should never get here. If no email account is logged in then an anonymous account should be logged in.")
            return
        }
        var userPath : String!
        if(user.isAnonymous) {
            userPath = "anonymous-users/\(user.uid)"
        }
        else {
            userPath = user.email!.safeDatabaseKey()
        }
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

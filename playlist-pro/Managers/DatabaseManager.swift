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
    ///     - library: Playlist object holding all of a user's songs
    ///     - user: User object for the current user
    ///     - Async callback for result if database entry succeeded
    func updateLibrary(library: Playlist, user: User, completion: @escaping (Bool) -> Void) {
        if(user.isAnonymous) {
            database.child("anonymous-users/\(user.uid)/library").setValue(encodePlaylist(library)) { error, _ in
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
    ///     - user: User object for the current user
    ///     - Async callback for result if database entry succeeded
    func downloadLibraryPlaylist(user: User, oldLibrary: [Song], completion: @escaping (Playlist) -> Void) {
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
    private func encodePlaylist(_ playlist: Playlist) -> [String : Any] {
        if let encodedPlaylist = try? FirestoreEncoder().encode(playlist) {
            return encodedPlaylist
        }
        else {
            return [String : Any]()
        }
    }
    private func decodePlaylist(_ encodedPlaylist: [String : Any]) -> Playlist{
        if let decodedPlaylist = try? FirestoreDecoder().decode(Playlist.self, from: encodedPlaylist) {
            return decodedPlaylist
        }
        else {
            print("Decoding Error")
            return Playlist(title: "")
        }
    }
}

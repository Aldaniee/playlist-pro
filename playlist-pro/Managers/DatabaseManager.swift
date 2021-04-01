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
    public func insertNewUser(with email: String,completion: @escaping (Bool) -> Void) {
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
        let encodedSongArray = self.encodeSongArray(library.songList)
        print(encodedSongArray)

        if(user.isAnonymous) {
            database.child("anonymous-users/\(user.uid)/library").setValue(encodedSongArray ) { error, _ in
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
                database.child("\(user.email!.safeDatabaseKey())/library").setValue(encodedSongArray) { error, _ in
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
    func downloadSongDictLibrary(user: User, oldLibrary: [Song], completion: @escaping ([Song]) -> Void) {
        var userPath : String!
        if(user.isAnonymous) {
            userPath = "anonymous-users/\(user.uid)"
        }
        else {
            userPath = user.email!.safeDatabaseKey()
        }
        database.child(userPath).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary {

                let encodedSongArray = dictionary["library"] as? NSArray
                //dump(snapshot)
                if encodedSongArray != nil {
                    completion(self.decodeSongArray(encodedSongArray!))
                }
                else {
                    print("No library in database, return empty library")
                    completion([Song]())
                }
            }
            else {
                print("Snapshot Error")
            }
        });
    }
    private func encodeSongArray(_ songArray: [Song]) -> NSArray {
        let encodedSongArray = NSMutableArray()
        for song in songArray {
            if let encodedSong = try? FirestoreEncoder().encode(song) {
                encodedSongArray.add(encodedSong)
            }
            else {
                print("Encoding Error")
                return NSArray()
            }
        }
        return NSArray(array: encodedSongArray)
    }
    private func decodeSongArray(_ encodedSongArray: NSArray) -> [Song]{
        var songArray = [Song]()
        for encodedSong in encodedSongArray {
            if let decodedSong = try? FirestoreDecoder().decode(Song.self, from: encodedSong as! [String : Any]) {
                songArray.append(decodedSong)
            }
            else {
                print("Decoding Error")
                return [Song]()
            }
        }
        return songArray
    }

}

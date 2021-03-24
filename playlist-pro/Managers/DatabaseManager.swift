//
//  DatabaseManager.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import FirebaseDatabase
import FirebaseAuth
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
    ///     – displayName: String representing display name
    ///     – completion: Async callback for result if database entry succeeded
    public func insertNewUser(with email: String, displayName: String, completion: @escaping (Bool) -> Void) {
        // Email is the database key
        // But @ and . are not allowed characters in a key
        // Call safeDatabaseKey implemented in Extensions.swift to convert
        database.child(email.safeDatabaseKey()).setValue(["displayName": displayName]) { error, _ in
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
            database.child("anonymous-users/\(user.uid)/library").setValue(library.songList) { error, _ in
                if error == nil {
                    // succeeded
                }
                else {
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
                database.child("\(user.email!.safeDatabaseKey())/library").setValue(library.songList) { error, _ in
                    if error == nil {
                        // succeeded
                    }
                    else {
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
    func downloadSongDictLibrary(user: User, oldLibrary: NSMutableArray!, completion: @escaping (NSMutableArray) -> Void) {
        var userPath : String!
        if(user.isAnonymous) {
            userPath = "anonymous-users/\(user.uid)"
        }
        else {
            userPath = user.email!.safeDatabaseKey()
        }
        database.child(userPath).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary {

                let library = dictionary["library"] as? NSMutableArray
                dump(snapshot)
                if library != nil {
                    completion(library!)
                }
                else {
                    print("No library in database, return empty library")
                    completion(NSMutableArray())
                }
            }
            else {
                print("Snapshot Error")
            }
        }) { (error) in
                print(error.localizedDescription)
                return
        }
    }
}

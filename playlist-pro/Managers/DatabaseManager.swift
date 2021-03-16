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
    
    /// Check if username and email is available
    /// - Parameters
    ///     – email: String representing email
    ///     – username: String representing username
    public func canCreateNewUser(with email: String, username: String, completion: (Bool) -> Void) {
        completion(true)
    }
    /// Insert user data to database
    /// - Parameters
    ///     – email: String representing email
    ///     – username: String representing username
    ///     – completion: Async callback for result if database entry succeeded
    public func insertNewUser(with email: String, username: String, completion: @escaping (Bool) -> Void) {
        // Email is the database key
        // But @ and . are not allowed characters in a key
        // Call safeDatabaseKey implemented in Extensions.swift to convert
        database.child(email.safeDatabaseKey()).setValue(["username": username]) { error, _ in
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
    func getLibrary(user: User, oldLibrary: NSMutableArray!, completion: @escaping (Bool) -> Void) -> NSMutableArray {
        var library = oldLibrary
        var userPath : String!
        if(user.isAnonymous) {
            userPath = "anonymous-users/\(user.uid)"
        }
        else {
            userPath = user.email!.safeDatabaseKey()
        }
        database.child(userPath).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : Any] {
                library = dictionary["library"] as? NSMutableArray
                dump(library)
            }
            else {
                print("Snapshot Error")
            }
        }) { (error) in
                print(error.localizedDescription)
                return
        }
        return library!
    }
}

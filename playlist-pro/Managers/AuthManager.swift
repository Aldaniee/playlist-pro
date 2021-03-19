//
//  AuthManager.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import FirebaseAuth

public class AuthManager {
    static let shared = AuthManager()
    
    var isSignedIn = Auth.auth().currentUser != nil
    
    // MARK: - Public
    public func registerNewUser(displayName: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        // Check if email is avialable
        DatabaseManager.shared.canCreateNewUser(with: email) { canCreate in
            if canCreate {
                // Create account
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    guard error == nil, result != nil else {
                        print("Firebase auth could not create account")
                        completion(false)
                        return
                    }
                    completion(true)
                    return
                }
                // Insert Account to database
                DatabaseManager.shared.insertNewUser(with: email, displayName: displayName) { inserted in
                    if inserted {
                        // Success
                        print("Inserted into database")
                        completion(true)
                        return
                    }
                    else {
                        // Failed to insert into database
                        print("Failed to inserted into database")
                        completion(false)
                        return
                    }
                }
            }
            else {
                // either username or email does not exist
                print("Either the username or email is not valid")
                completion(false)
            }
        }
    
    }
    public func loginUser(username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void) {
        if let email = email {
            // email log in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
                return
            }
        }
        /// TODO: Implement username login
        /*else if let username = username {
            
        }*/
    }
    /// Attempt to log out Firebase User
    public func logOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            QueueManager.shared.suspend()
            completion(true)
            return
        }
        catch {
            print(error)
            completion(false)
            return
        }
    }
}

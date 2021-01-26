//
//  AuthManager.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import FirebaseAuth

public class AuthManager {
    static let shared = AuthManager()
    
    // MARK: - Public
    
    public func registerNewUser(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        // Check if username and email is avialable
        DatabaseManager.shared.canCreateNewUser(with: email, username: username) { canCreate in
            if canCreate {
                // Create account
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    guard error == nil, result != nil else {
                        // Firebase auth could not create account
                        print(error!)
                        completion(false)
                        return
                    }
                    
                }
                // Insert Account to database
                DatabaseManager.shared.insertNewUser(with: email, username: username) { inserted in
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
                print("Either the useranme or email does not exist")
                completion(false)
            }
        }
    
    }
    public func loginUser(username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void) {
        if let email = email {
            // email log in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Signed in with email")
                    completion(false)
                    return
                }
            }
        }
        else if let username = username {
            // username log in
        }
    }
    /// Attempt to log out Firebase User
    public func logOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
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

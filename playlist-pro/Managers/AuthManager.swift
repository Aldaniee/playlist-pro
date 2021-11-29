//
//  AuthManager.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import FirebaseAuth

public class AuthManager {
    
    static let shared = AuthManager()
        
    init() {
        if Auth.auth().currentUser != nil && Auth.auth().currentUser?.isAnonymous == false {
            LocalFilesManager.storeEmail(email: Auth.auth().currentUser!.email!)
        }
    }
    
    // MARK: - Public
    public func registerNewUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        // Check if email is avialable
        DatabaseManager.shared.emailAvailable(with: email) { canCreate in
            if canCreate && isValidEmail(email) && isValidPassword(password) {
                // Create account
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed: break
                        // Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
                        case .emailAlreadyInUse:
                            print("email already in use")
                        // Error: The email address is already in use by another account.
                        case .invalidEmail:
                            print("invalid email address")
                        // Error: The email address is badly formatted.
                        case .weakPassword:
                            print("password is weak")
                        // Error: The password must be 6 characters long or more.
                        default:
                            print("Error: \(error.localizedDescription)")
                        }
                        completion(false)
                        return
                    } else {
                        print("User registered successfully")
                        LocalFilesManager.storeEmail(email: Auth.auth().currentUser!.email!)
                        completion(true)
                        return
                    }
                }
                // Insert Account to database
                DatabaseManager.shared.insertNewUser(with: email) { inserted in
                    if inserted {
                        // Success
                        print("Inserted into database")
                        guard let user = Auth.auth().currentUser else {
                            print("shouldn't get here")
                            return
                        }
                        user.sendEmailVerification(completion: { (error) in
                            guard let error = error else {
                                return print("user email verification sent")
                            }
                            print(error)
                        })
                        completion(true)
                    }
                    else {
                        // Failed to insert into database
                        print("Failed to inserted into database")
                        completion(false)
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
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let minPasswordLength = 6
        return password.count >= minPasswordLength
    }
    public func loginUser(username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void) {
        if let email = email {
            // email log in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                guard let user = Auth.auth().currentUser else {
                    print("shouldn't get here")
                    return
                }
                LocalFilesManager.storeEmail(email: Auth.auth().currentUser!.email!)
                if !user.isEmailVerified {
                    user.sendEmailVerification(completion: { (error) in
                        guard let error = error else {
                            return print("user email verification sent")
                        }
                        print(error)
                    })
                }
                completion(true)
                return
            }
        }
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

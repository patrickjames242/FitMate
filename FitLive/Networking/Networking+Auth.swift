//
//  Networking+Auth.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/29/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//




import UIKit
import Quickblox

private extension String{
    func trim() -> String{
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


extension Networking{
    
    
    struct SignUpInfo{
        
        let username: String
        let displayName: String
        let password: String
        let email: String
        
        init(username: String, displayName: String, password: String, email: String) throws {
            
            let username = username.trim()
            let displayName = displayName.trim()
            let password = password.trim()
            let email = email.trim()
            
            func assert(condition: Bool, errorDescription: String) throws{
                guard condition else {throw GenericError(errorDescription)}
            }
            
            let minUsernameCharacters = 5
            try assert(condition: Array(username).count >= minUsernameCharacters, errorDescription: "Your username must be at least \(minUsernameCharacters) characters.")

            let minDisplayNameCharacters = 5
            try assert(condition: Array(displayName).count >= minDisplayNameCharacters, errorDescription: "Your display name must be at least \(minDisplayNameCharacters) characters long.")
            
            let minPasswordLength = 8
            try assert(condition: Array(password).count >= minPasswordLength, errorDescription: "Your password must be at least \(minPasswordLength) characters long.")
            
            try assert(condition: isValidEmail(email: email), errorDescription: "The email you have entered is not valid")
            
            self.username = username
            self.displayName = displayName
            self.password = password
            self.email = email
        }
        
    }
    
    
    static func signUp(info: SignUpInfo, completion: @escaping (CompletionResult<User>) -> ()){
        
        do{
            let firebaseInfo = try Firebase.SignUpInfo(username: info.username, displayName: info.displayName, email: info.email, password: info.password)
            Firebase.signUp(info: firebaseInfo) { firebaseSignUpResult in
                switch firebaseSignUpResult{
                case .success(let firebaseSignUpSuccess):
                    
                    let videoChatPassword = NSUUID().uuidString
                    let videoChatSignUpInfo = try! VideoChatAPI.SignUpInfo(email: info.email, password: videoChatPassword)
                    
                    VideoChatAPI.signUp(info: videoChatSignUpInfo) { videoChatAPIResult in
                        switch videoChatAPIResult{
                        case .success(let videoChatApISuccess):
                            firebaseSignUpSuccess.userResolver(videoChatApISuccess.userID, videoChatPassword, { userResolverResult in
                                switch userResolverResult{
                                case .success(let user):
                                    performOnLogInActions(user: user)
                                    completion(.success(user))
                                case .failure(let error):
                                    videoChatApISuccess.cancelSignUp()
                                    firebaseSignUpSuccess.cancelSignUp()
                                    completion(.failure(error))
                                }
                            })
                        case .failure(let error):
                            firebaseSignUpSuccess.cancelSignUp()
                            completion(.failure(error))
                        }
                    }
                    
                case .failure(let error): completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    
    static func logIn(email: String, password: String, completion: @escaping (CompletionResult<User>) -> ()){
        Firebase.logIn(email: email, password: password) { firebaseLogInSuccess in
            switch firebaseLogInSuccess{
                
            case .success(let firebaseLogInSuccess):
                VideoChatAPI.logIn(email: email, password: firebaseLogInSuccess.user.quickBloxPassword) { videoChatAPIResult in
                    switch videoChatAPIResult{
                    case .success:
                        performOnLogInActions(user: firebaseLogInSuccess.user)
                        completion(.success(firebaseLogInSuccess.user))
                    case .failure(let error):
                        firebaseLogInSuccess.cancelLogIn()
                        completion(.failure(error))
                    }
                }
            case .failure(let error): completion(.failure(error))
            }
        }
        
    }
    
    static func performOnLogInActions(user: User){
        CurrentUserManager.notifyThatUserDidLogIn(user: user)
        LiveChatBrain.default.setUpVideoCallConnection()
    }
    
    
    static func logOut(){
        Firebase.logOut()
        VideoChatAPI.logOut()
        CurrentUserManager.notifyThatUserDidLogOut()
    }
    
    
    
}




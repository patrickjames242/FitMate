//
//  Networking+Auth.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/29/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//




import UIKit
import Quickblox



extension Networking{
    
    
    struct SignUpInfo{
        
        let username: String
        let displayName: String
        let password: String
        let email: String
        
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




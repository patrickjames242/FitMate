//
//  Networking+LiveStreamAPI.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/30/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import Quickblox

extension Networking{
    
    enum VideoChatAPI{
    
        struct SignUpInfo{
            
            let email: String
            let password: String
            
            init(email: String, password: String) throws {
                // restricting the length of the password to 8 characters because the QuickBlox api doesn't allow passwords shorter than this
                let minCharacters = 8
                guard Array(password).count >= minCharacters else {throw GenericError("Your QuickBlox password must be at least \(minCharacters) characters")}
                self.email = email
                self.password = password
            }
        }
        
        
        /// the integer in the completion is the user ID
        static func signUp(info: SignUpInfo, completion: @escaping (CompletionResult<(userID: Int, cancelSignUp: () -> Void)>) -> ()){
            let user = QBUUser()
            user.login = info.email
            user.password = info.password
            
            let cancelSignUp: () -> Void = {
                QBRequest.deleteCurrentUser(successBlock: {_ in logOut()}, errorBlock: nil)
            }
            
            QBRequest.signUp(user, successBlock: { (response, user) in
                completion(.success((Int(user.id), cancelSignUp)))
            }, errorBlock: { completion(.failure($0.error?.error ?? GenericError("An error occured when trying to log in via QBRequest.signUp")))})
        }
        
        
        /// the integer in the completion is the id of the user
        static func logIn(email: String, password: String, completion: @escaping (CompletionResult<(userID: Int, cancelLogIn: () -> Void)>) -> ()){
            QBRequest.logIn(withUserLogin: email, password: password, successBlock: { (response, user) in
                completion(.success((Int(user.id), logOut)))
            }, errorBlock: { completion(.failure($0.error?.error ?? GenericError("An error occured when trying to log in via QBRequest.logIn")))})
        }
        
        static func logOut(){
            QBRequest.logOut(successBlock: nil, errorBlock: nil)
        }
        
        
        
        
        
        
        
    }
    
    
    
    
    
}

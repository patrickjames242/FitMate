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
        
        let email: String
        let password: String
        
        init(email: String, password: String) throws {
            // restricting the length of the password to 8 characters because the QuickBlox api doesn't allow passwords shorter than this
            let minCharacters = 8
            guard Array(password).count >= minCharacters else {throw GenericError("Your password must be at least \(minCharacters) characters")}
            self.email = email
            self.password = password
        }
    }
    
    
    static func signUp(info: SignUpInfo, completion: @escaping (CompletionResult<User>) -> ()){
        let user = QBUUser()
        user.login = info.email
        user.password = info.password
        QBRequest.signUp(user, successBlock: { (response, user) in
            let id = Int(user.id)
            let user = User(id: id, email: info.email)
            completion(.success(user))
        }, errorBlock: { completion(.failure($0.error?.error ?? GenericError("An error occured when trying to log in via QBRequest.signUp")))})
    }
    
    
    static func logIn(email: String, password: String, completion: @escaping (CompletionResult<User>) -> ()){
        QBRequest.logIn(withUserLogin: email, password: password, successBlock: { (response, user) in
            let id = Int(user.id)
            let user = User(id: id, email: email)
            print("The user is logged in so I don't know what these people talking about")
            completion(.success(user))
        }, errorBlock: { completion(.failure($0.error?.error ?? GenericError("An error occured when trying to log in via QBRequest.logIn")))})
    }
    
    
}




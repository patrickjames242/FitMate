//
//  Networking+User.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/29/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//


extension Networking{
    
    struct User: Codable{
        let firebaseID: String
        let quickBoxId: Int
        let quickBloxPassword: String
        let username: String
        let displayName: String
        let email: String
    }
    
}





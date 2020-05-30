//
//  CurrentUserManager.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/30/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import Quickblox

enum CurrentUserManager{
    
    @UserDefaultsProperty(key: "current_user")
    private(set) static var currentUser: Networking.User?
    
    
    static func notifyThatUserDidLogIn(user: Networking.User){
        currentUser = user
    }
    
    static func notifyThatUserDidLogOut(){
        currentUser = nil
    }
    
}




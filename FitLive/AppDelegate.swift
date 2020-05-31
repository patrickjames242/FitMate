//
//  AppDelegate.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/28/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // another change
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        QBSettings.applicationID = 83050
        QBSettings.authKey = "TL9TH-QqDrSFYzQ"
        QBSettings.authSecret = "vtjb22rgZCusHcu"
        QBSettings.accountKey = "mR-Z2RVG3UdyxVGq7MFf"
        QBRTCConfig.setLogLevel(.errors)
        QBRTCClient.initializeRTC()
        Networking.VideoChatAPI.setUpVideoCallConnection()
        FirebaseApp.configure()
    
        return true
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = LandingPage()
        window?.makeKeyAndVisible()

        return true
    }




}


//
//  ViewController.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/28/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC



class ViewController: UIViewController {
    
    @IBOutlet weak var slogan: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        UIFont.fontNames(forFamilyName: "Karla").forEach({print($0)})
            
        let font = UIFont(name: "Karla-Regular", size: 15)
        slogan.font = font
        

                    

    }
    
}

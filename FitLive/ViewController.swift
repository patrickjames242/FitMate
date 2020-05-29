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

let currentUserEmail = "patrickjh1998@hotmail.com"
let userToCall = 110223515

//let currentUserEmail = "patrickhanna@hotmail.com"
//let userToCall = 110223451


class ViewController: UIViewController {
    
    var session: QBRTCSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        QBRTCClient.instance().add(self)
        Networking.logIn(email: currentUserEmail, password: "12345678") { result in
            switch (result){
            case .success:
                self.setUpViews()
            case .failure: fatalError()
            }
        }
    }
    
    private func setUpViews(){
        videoView.pinAllSides(addTo: view, pinTo: view)
        callButton.pin(addTo: view, .centerX == view.centerXAnchor, .centerY == view.centerYAnchor)
    }
    
    lazy var callButton: UIButton = {
        let x = UIButton(type: .system)
        x.setTitle("START CALL", for: .normal)
        x.addTarget(self, action: #selector(callButtonPressed), for: .touchUpInside)
        return x
    }()
    
    let videoView: UIView = {
        let x = UIView()
        return x
    }()
    
    @objc func callButtonPressed(){
        let session = QBRTCClient.instance().createNewSession(withOpponents: [userToCall] as [NSNumber], with: .video)
        self.session = session
        session.startCall(nil)
        updateVideoLayer()
    }
    
    
    
    private func updateVideoLayer(){
        guard let session = session else {return}
        
        let videoFormat = QBRTCVideoFormat()
        videoFormat.frameRate = 30
        videoFormat.pixelFormat = .format420f
        videoFormat.width = 640
        videoFormat.height = 480
        
        let videoCapture = QBRTCCameraCapture(videoFormat: videoFormat, position: .front)
        
        session.localMediaStream.videoTrack.videoCapture = videoCapture
        
        self.videoView.layoutIfNeeded()
        videoCapture.previewLayer.frame = self.videoView.bounds
        videoCapture.startSession()
        
        self.videoView.layer.insertSublayer(videoCapture.previewLayer, at: 0)
    }
    
    
    

}



extension ViewController: QBRTCClientDelegate{
    
    // invoked when someone is calling you
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        self.updateVideoLayer()
        session.acceptCall(nil)
        print("someone is calling me", session, userInfo)
    }
    
    // invoked when the person you're calling accepts your call
    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        self.updateVideoLayer()
        print("someone just accepted my call", session, userID, userID)
    }
    
    // invoked when the person you're calling rejects your call
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("someone just rejected my call", session, userID, userID)
    }
    
    // invoked if the person you're calling did not respond
    func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        print("no one responded to my call", userID)
    }
    
}


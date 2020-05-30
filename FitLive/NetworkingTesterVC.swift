//
//  NetworkingTesterVC.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/29/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit




import UIKit
import Quickblox
import QuickbloxWebRTC

//let currentUserEmail = "patrickjh1998@hotmail.com"
//let userToCall = 110223515

//let currentUserEmail = "patrickhanna@hotmail.com"
//let userToCall = 110223451


class NetworkingTesterVC: UIViewController {
    
    @UserDefaultsProperty(key: "current_user_email")
    static var currentUserEmail: String?
    
    @UserDefaultsProperty(key: "user_to_Call")
    static var userToCall: Int?
    
    
        
    var session: QBRTCSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        NetworkingTesterVC.currentUserEmail = "patrickjh1998@hotmail.com"
//        NetworkingTesterVC.userToCall = 110223515
        
//        NetworkingTesterVC.currentUserEmail = "patrickhanna@hotmail.com"
//        NetworkingTesterVC.userToCall = 110223451
        
        
        
        QBRTCClient.instance().add(self)
        let password = "12345678"
        
        Networking.logIn(email: NetworkingTesterVC.currentUserEmail!, password: password) { result in
            switch (result){
            case .success(let user):
                QBChat.instance.connect(withUserID: UInt(user.id), password: password) { error in
                    print("is there an error in QBChat connect?", error as Any)
                    self.setUpViews()
                }
            case .failure: fatalError()
            }
        }
    }
    
    private func setUpViews(){
        view.backgroundColor = .white
//        videoView.pinAllSides(addTo: view, pinTo: view)
        view.addSubview(videoView)
        videoView.frame = self.view.bounds
        callButton.pin(addTo: view, .centerX == view.centerXAnchor, .centerY == view.centerYAnchor)
        
        
    }
    
    private lazy var callButton: UIButton = {
        let x = UIButton(type: .system)
        x.setTitle("START CALL", for: .normal)
        x.addTarget(self, action: #selector(callButtonPressed), for: .touchUpInside)
        return x
    }()
    
    let videoView: QBRTCRemoteVideoView = {
        let x = QBRTCRemoteVideoView()
        x.backgroundColor = .red
        x.contentMode = .scaleAspectFit
        return x
    }()
    
    @objc func callButtonPressed(){
        let session = QBRTCClient.instance().createNewSession(withOpponents: [NetworkingTesterVC.userToCall!] as [NSNumber], with: .video)
//        self.session = session
        session.startCall(nil)
    }
    
    private var localVideoPreviewLayer: CALayer?
    
//    private func updateVideoLayer(){
//        guard let session = session else {return}
//        localVideoPreviewLayer?.removeFromSuperlayer()
//
//        let videoFormat = QBRTCVideoFormat()
//
//        videoFormat.frameRate = 30
//        videoFormat.pixelFormat = .format420f
//        videoFormat.width = 640
//        videoFormat.height = 480
//
//        let videoCapture = QBRTCCameraCapture(videoFormat: videoFormat, position: .front)
//
//        session.localMediaStream.videoTrack.videoCapture = videoCapture
//
//        self.videoView.layoutIfNeeded()
//        let layer = videoCapture.previewLayer
//        layer.frame = self.videoView.bounds
//        self.localVideoPreviewLayer = layer
//
//        videoCapture.startSession()
//
//        self.videoView.layer.insertSublayer(layer, at: 0)
        
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.localVideoPreviewLayer.map{$0.frame = self.videoView.bounds}
        videoView.frame = view.bounds
    }
    
    private let cameraCapture: QBRTCCameraCapture = {
        let videoFormat = QBRTCVideoFormat()
        
        videoFormat.frameRate = 30
        videoFormat.pixelFormat = .format420f
        videoFormat.width = 640
        videoFormat.height = 480
        
        return QBRTCCameraCapture(videoFormat: videoFormat, position: .front)
    }()
    
}



extension NetworkingTesterVC: QBRTCClientDelegate{
    
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
//        let _session = session as! QBRTCSession
//        self.session = _session
//        updateVideoLayer()
        
        if session.localMediaStream.videoTrack.videoCapture == nil{
            print("did set video capture")
            session.localMediaStream.videoTrack.videoCapture = self.cameraCapture
            self.cameraCapture.startSession()
        }
        
        
        
    }
    
    // invoked when someone is calling you
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        session.acceptCall(nil)
        print("someone is calling me", session, userInfo as Any)
    }
    
    // invoked when the person you're calling accepts your call
    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("someone just accepted my call", session, userID, userInfo as Any)
    }
    
    // invoked when the person you're calling rejects your call
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("someone just rejected my call", session, userID, userInfo as Any)
    }
    
    // invoked if the person you're calling did not respond
    func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        print("no one responded to my call", userID)
    }
    
    func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        print("receivedRemoteVideoTrack")
        self.videoView.setVideoTrack(videoTrack)
    }
    
    
    
}


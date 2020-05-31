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





class LiveChatBrain{
    
    static let `default` = LiveChatBrain()
    
    func initialize(){
        
        if let currentUser = CurrentUserManager.currentUser{
            QBChat.instance.connect(withUserID: UInt(currentUser.quickBoxId), password: currentUser.quickBloxPassword) { error in
                print(error as Any)
            }
        }
    }
    
    
    // public stuff
    
    private var remoteVideoViews = [QBRTCRemoteVideoView]()
    private var localVideoViews = [UIView]()
    
    private var sessionDelegate: LiveChatBrainQBRTCClientDelegate?
    
    private init(){
        let sessionDelegate = LiveChatBrainQBRTCClientDelegate(brain: self)
        QBRTCClient.instance().add(sessionDelegate)
        self.sessionDelegate = sessionDelegate
        
    }
    
    
    func getNewRemoteVideoView() -> UIView{
        let x = QBRTCRemoteVideoView()
        
        x.videoGravity = "AVLayerVideoGravityResizeAspect"
        
        remoteVideoViews.append(x)
        return x
    }
    
    func getNewLocalVideoView() -> UIView{
        let x = LocalVideoView(captureSession: self.cameraCapture)
        return x
    }
    
    func callUser(userId: Int){
        self.session = QBRTCClient.instance().createNewSession(withOpponents: [userId] as [NSNumber], with: .video)
        self.session?.startCall(nil)
    }
    
    // accepts any incoming call, if any
    func acceptCall(){
        session?.acceptCall(nil)
    }
    
    // rejects any incoming call, if any
    func rejectCall(){
        session?.rejectCall(nil)
    }
    
    // hangs up the current calls
    func hangUp(){
        session?.hangUp(nil)
    }
    
    func setUpVideoCallConnection(){
        if let currentUser = CurrentUserManager.currentUser{
            QBChat.instance.connect(withUserID: UInt(currentUser.quickBoxId), password: currentUser.quickBloxPassword) { error in
                print(error as Any)
            }
        }
    }
    
    
    
    
    
    
    // private stuff
    
    
    private var session: QBRTCSession?
    
    
    
    
    private let cameraCapture: QBRTCCameraCapture = {
        let videoFormat = QBRTCVideoFormat()
        
        videoFormat.frameRate = 30
        videoFormat.pixelFormat = .format420f
        videoFormat.width = 800
        videoFormat.height = 600
        let cameraCapture = QBRTCCameraCapture(videoFormat: videoFormat, position: .front)
        cameraCapture.startSession()
        
        return cameraCapture
    }()
    
    
    
    fileprivate func updateSession(session: QBRTCSession?){
        self.session = session
    }
    
    fileprivate func updateCameraCaptureOn(session: QBRTCSession){
        session.localMediaStream.videoTrack.videoCapture = cameraCapture
    }
    
    
    fileprivate func updateRemoteVideoTrack(track: QBRTCVideoTrack){
        remoteVideoViews.forEach{$0.setVideoTrack(track)}
    }
    
    let someoneIsTryingToCallTheUserNotification = CustomNotification<()>()
    let callConnectedNotification = CustomNotification<()>()
    let personNeverRespondedNotification = CustomNotification<()>()
    let personDeclinedCallNotification = CustomNotification<()>()
    let personHungUpNotification = CustomNotification<()>()
    let callFailedNotification = CustomNotification<()>()
    
    
    fileprivate func someoneIsTryingToCallTheUser(){

        someoneIsTryingToCallTheUserNotification.post()
    }
    
    fileprivate func callConnected(){
        callConnectedNotification.post()
    }
    
    fileprivate func personNeverResponded(){
        personNeverRespondedNotification.post()
    }
    
    fileprivate func personDeclinedCall(){
        personDeclinedCallNotification.post()
    }
    
    fileprivate func personHungUp(){
        personHungUpNotification.post()
    }
    
    fileprivate func callFailed(){
        callFailedNotification.post()
    }
    

}

private class LiveChatBrainQBRTCClientDelegate: NSObject, QBRTCClientDelegate{
    
    private weak var brain: LiveChatBrain?
    
    init(brain: LiveChatBrain){
        self.brain = brain
        super.init()
    }
    
    
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        
        let _session = session as! QBRTCSession
        
        
        if session.localMediaStream.videoTrack.videoCapture == nil{
            brain?.updateCameraCaptureOn(session: _session)
        }
        
        
        
        switch state{
        case .unknown, .new, .pending, .connecting, .checking, .connected, .disconnected:
            brain?.updateSession(session: _session)
            
        // signifies that the call failed in some way
            
        case .closed, .count, .disconnectTimeout, .noAnswer, .rejected, .hangUp, .failed:
            brain?.updateSession(session: nil)
        @unknown default: break
        }
        
        
        
        
        switch state{
        
        case .unknown, .new, .pending, .connecting, .checking, .disconnected: break
        case .connected: self.brain?.callConnected()
        // signifies that the call failed in some way
            
        
        case .noAnswer: self.brain?.personNeverResponded()
        case .rejected: self.brain?.personDeclinedCall()
        case .hangUp: self.brain?.personHungUp()
        case .closed, .count, .disconnectTimeout, .failed: self.brain?.callFailed()
            
        @unknown default: break

        }
        
    }
    
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        self.brain?.updateSession(session: session)
        self.brain?.someoneIsTryingToCallTheUser()
    }
    
    
    
    
    
    
    
    func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        self.brain?.updateRemoteVideoTrack(track: videoTrack)
    }
    
}






extension LiveChatBrain{
    
    fileprivate class LocalVideoView: UIView{
        
        private let videoLayer: CALayer
        
        init(frame: CGRect = .zero, captureSession: QBRTCCameraCapture){
            captureSession.previewLayer.videoGravity = .resizeAspectFill
            self.videoLayer = captureSession.previewLayer
            super.init(frame: frame)
            self.contentMode = .scaleAspectFill
            self.layer.insertSublayer(videoLayer, at: 0)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            videoLayer.frame = self.layer.bounds
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init coder has not being implemented")
        }
    }
    
}




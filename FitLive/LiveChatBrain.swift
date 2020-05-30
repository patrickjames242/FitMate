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



protocol LiveChatBrainDelegate: class{
    
    func someoneIsTryingToCallTheUser()
    
    /// might be called multiple times, like if the call disconnects and reconnects
    func callConnected()
    func personNeverResponded()
    func personDeclinedCall()
    func personHungUp()
    func callFailed()
    
}





class LiveChatBrain: NSObject{
    
    
    
    // public stuff
    
    weak var delegate: LiveChatBrainDelegate?
    
    override init(){
        super.init()
        QBRTCClient.instance().add(LiveChatBrainQBRTCClientDelegate(brain: self))
    }
    
    
    var remoteVideoView: UIView{
        return self._remoteVideoView
    }
    
    var localVideoView: UIView{
        return self._localVideoView
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
    
    
    
    
    
    
    
    // private stuff
    
    
    private var session: QBRTCSession?
    
    
    private let _remoteVideoView: QBRTCRemoteVideoView = {
        let x = QBRTCRemoteVideoView()
        x.backgroundColor = .red
        x.contentMode = .scaleAspectFit
        return x
    }()
    
    
    
    private lazy var _localVideoView: UIView = {
        let x = LocalVideoView(captureSession: self.cameraCapture)
        return x
    }()
    
    private let cameraCapture: QBRTCCameraCapture = {
        let videoFormat = QBRTCVideoFormat()
        
        videoFormat.frameRate = 30
        videoFormat.pixelFormat = .format420f
        videoFormat.width = 640
        videoFormat.height = 480
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
        _remoteVideoView.setVideoTrack(track)
    }
    
    
    fileprivate func someoneIsTryingToCallTheUser(){
        delegate?.someoneIsTryingToCallTheUser()
    }
    
    fileprivate func callConnected(){
        delegate?.callConnected()
    }
    
    fileprivate func personNeverResponded(){
        delegate?.personNeverResponded()
    }
    
    fileprivate func personDeclinedCall(){
        delegate?.personDeclinedCall()
    }
    
    fileprivate func personHungUp(){
        delegate?.personHungUp()
    }
    
    fileprivate func callFailed(){
        delegate?.callFailed()
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
            self.videoLayer = captureSession.previewLayer
            super.init(frame: frame)
            self.contentMode = .scaleAspectFit
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




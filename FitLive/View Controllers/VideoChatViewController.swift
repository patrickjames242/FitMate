//
//  VideoChatViewController.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/31/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit


class VideoChatViewController: UIViewController{
    
    private let personBeingCalled: Networking.User?
    
    init(personBeingCalled: Networking.User?){
        self.personBeingCalled = personBeingCalled
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        self.view.backgroundColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViews()
        
        setUpVideoViews()
        
        LiveChatBrain.default.personHungUpNotification.listen(sender: self) {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func setUpViews(){
        let sideInsets: CGFloat = 20
        navBarView.pin(addTo: view, .left == view.leftAnchor + sideInsets, .right == view.rightAnchor - sideInsets, .top == view.safeAreaLayoutGuide.topAnchor + 20)
        localVideoViewHolder.pin(addTo: view, .right == view.rightAnchor - 20, .top == navBarView.bottomAnchor + 20)
        buttonIconsHolderView.pin(addTo: view, .bottom == view.safeAreaLayoutGuide.bottomAnchor - 20, .centerX == view.centerXAnchor)
    }
    
    func setUpVideoViews(){
        let localView = LiveChatBrain.default.getNewLocalVideoView()
        localView.pinAllSides(addTo: localVideoViewHolder, pinTo: localVideoViewHolder)
        
        let remoteView = LiveChatBrain.default.getNewRemoteVideoView()
        view.insertSubview(remoteView, at: 0)
        remoteView.pinAllSides(pinTo: self.view)
        
    }
    
    private lazy var navBarView: UIView = {
        let x = UIView()
//        backArrowButton.pin(addTo: x, .left == x.leftAnchor, .top >= x.topAnchor, .bottom <= x.bottomAnchor, .centerY == x.centerYAnchor)
        userNameLabel.pin(addTo: x, .centerY == x.centerYAnchor, .centerX == x.centerXAnchor, .top >= x.topAnchor, .bottom <= x.bottomAnchor)
        return x
    }()
    
    private lazy var backArrowButton: UIButton = {
        let x = UIButton(type: .system)
        x.imageView?.contentMode = .scaleAspectFit
        x.setBackgroundImage(UIImage(named: "arrow-left")!, for: .normal)
        x.pin(.height == 20, .width == 20)
        return x
    }()
    
    private lazy var userNameLabel: UILabel = {
        let x = UILabel()
        x.text = personBeingCalled?.displayName
        x.textColor = .white
        x.font = ThemeFont.regular.getUIFont(size: 15)
        return x
    }()
    
    private lazy var localVideoViewHolder: UIView = {
        let x = UIView()
        let widthPercentageOfHeight: CGFloat = 121 / 161
        
        x.pin(.width == widthPercentageOfHeight * x.heightAnchor, .height == 120)
        x.layer.cornerRadius = 15
        x.layer.masksToBounds = true
        x.backgroundColor = .white
        return x
    }()
    
    
    private lazy var videoButton: UIButton = {
        let x = UIButton(type: .system)
        x.setBackgroundImage(UIImage(named: "mic")!, for: .normal)
        x.pin(.height == 63, .width == 63)
        return x
    }()
    
    
    private lazy var buttonIconsHolderView: UIView = {
        let x = UIView()
        let sideButtonsBottomInset: CGFloat = 60
        videoButton.pin(addTo: x, .left == x.leftAnchor, .bottom == x.bottomAnchor - sideButtonsBottomInset)
        hangUpButton.pin(addTo: x, .bottom == x.bottomAnchor, .centerX == x.centerXAnchor)
        microphoneButton.pin(addTo: x, .right == x.rightAnchor, .bottom == x.bottomAnchor - sideButtonsBottomInset)
        excerciseTimerView.pin(addTo: x, .top == x.topAnchor, .centerX == x.centerXAnchor, .bottom == hangUpButton.topAnchor - 70)
        x.pin(.width == 250)
        return x
    }()
    
    private lazy var excerciseTimerView: UIView = {
        let x = UIView()
        x.backgroundColor = .white
        x.pin(.height == 100, .width == 100)
        return x
    }()
    
    private lazy var hangUpButton: UIButton = {
        let x = UIButton(type: .system)
        x.setBackgroundImage(UIImage(named: "endcall")!, for: .normal)
        x.pin(.height == 63, .width == 63)
        x.addTarget(self, action: #selector(respondToHangUpButtonPressed), for: .touchUpInside)
        return x
    }()
    
    @objc private func respondToHangUpButtonPressed(){
        self.dismiss(animated: true, completion: nil)
        LiveChatBrain.default.hangUp()
    }
    
    
    private lazy var microphoneButton: UIButton = {
        let x = UIButton(type: .system)
        x.setBackgroundImage(UIImage(named: "videoicon")!, for: .normal)
        x.pin(.height == 63, .width == 63)
        return x
    }()
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}

//
//  VideoChatViewController.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/31/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit


class VideoChatViewController: UIViewController{
    
    private let otherCallerName: String?
    private let workout: Workout
    private let workoutTimer: WorkoutTimer
    
    init(otherCallerName: String?, workout: Workout){
        self.workout = workout
        self.workoutTimer = WorkoutTimer(workout: workout, totalWorkoutTimeInSeconds: 4 * 5)
        self.otherCallerName = otherCallerName
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        self.view.backgroundColor = .black
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViews()
        
        setUpVideoViews()
        
        workoutTimer.stateChangedNotification.listen(sender: self) {[weak self] state in
            guard let self = self else {return}
            if let state = state {
                self.excerciseTimerView.setProgress(timeRemaining: state.exerciseSecondsRemaining, totalTime: state.totalExerciseSeconds)
            } else {
                self.excerciseTimerView.setProgress(timeRemaining: 0, totalTime: 0)
            }
            self.exerciseImageView.image = state.map{UIImage(named: $0.exercise.imageName)!}
            self.exerciseNameLabel.text = state?.exercise.name
            if state == nil{
                LiveChatBrain.default.hangUp()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        LiveChatBrain.default.callFailedNotification.listen(sender: self) {[weak self]  in
            self?.dismiss(animated: true, completion: nil)
        }
        
        LiveChatBrain.default.personDeclinedCallNotification.listen(sender: self) {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        LiveChatBrain.default.personHungUpNotification.listen(sender: self) {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        LiveChatBrain.default.callConnectedNotification.listen(sender: self) {[weak self]  in
            guard let self = self else {return}
            self.workoutTimer.startWorkout()
        }
        
    }
    
    func setUpViews(){
        let sideInsets: CGFloat = 20
        navBarView.pin(addTo: view, .left == view.leftAnchor + sideInsets, .right == view.rightAnchor - sideInsets, .top == view.safeAreaLayoutGuide.topAnchor + 20)
        localVideoViewHolder.pin(addTo: view, .right == view.rightAnchor - 20, .top == navBarView.bottomAnchor + 20)
        buttonIconsHolderView.pin(addTo: view, .bottom == view.safeAreaLayoutGuide.bottomAnchor - 20, .centerX == view.centerXAnchor)
        exerciseImageView.pin(addTo: view, .centerX == view.centerXAnchor, .bottom == buttonIconsHolderView.topAnchor + 300 , .width == 1000, .height == 1000)
        exerciseNameLabel.pin(addTo: view, .centerX == view.centerXAnchor, .bottom == buttonIconsHolderView.topAnchor - 30)
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
        x.text = self.otherCallerName
        x.textColor = .white
        x.font = ThemeFont.regular.getUIFont(size: 15)
        return x
    }()
    
    private lazy var exerciseImageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFit
        x.tintColor = .white
        
        
        
        return x
    }()
    
    private lazy var exerciseNameLabel: UILabel = {
        let x = UILabel()
        x.textColor = .white
        x.font = ThemeFont.bold.getUIFont(size: 18)
        x.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        x.layer.shadowRadius = 10
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
    
    private lazy var excerciseTimerView: AnimatedCountDownTimer = {
        let x = AnimatedCountDownTimer()
        x.pin(.height == 80, .width == 80)
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



private class AnimatedCountDownTimer: UIView{
    
    private static let timeFormatter: DateComponentsFormatter = {
        let x = DateComponentsFormatter()
        x.allowedUnits = [.minute, .second]
        x.zeroFormattingBehavior = .pad
        return x
    }()
    
    
    init(){
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        layer.addSublayer(whiteRing)
        self.setProgress(timeRemaining: 0, totalTime: 0)
        timeLabel.pin(addTo: self, .centerX == self.centerXAnchor, .centerY == self.centerYAnchor)
    }
    
    
    // accepts a number between 0 and 1,
    func setProgress(timeRemaining: TimeInterval, totalTime: TimeInterval){
        var progress = (timeRemaining / totalTime)
        if progress.isNaN{
            progress = 1
        }
        self.whiteRing.strokeEnd = CGFloat(min(max(progress, 0), 1))
        self.timeLabel.text = AnimatedCountDownTimer.timeFormatter.string(from: timeRemaining)
    }
    
    private lazy var timeLabel: UILabel = {
        let x = UILabel()
        x.textColor = .white
        x.font = ThemeFont.regular.getUIFont(size: 17)
        return x
    }()
    
    
    private let strokeWidth: CGFloat = 6
    
    
    private lazy var whiteRing: CAShapeLayer = {
        let x = CAShapeLayer()
        x.fillColor = UIColor.clear.cgColor
        x.strokeColor = UIColor.white.cgColor
        x.lineWidth = self.strokeWidth
        return x
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sizeAndPosition(ring: whiteRing)
    }
    
    
    private func sizeAndPosition(ring: CAShapeLayer){
        ring.frame = self.bounds
        let radius = (self.bounds.width / 2) - (strokeWidth / 2)
        let path = UIBezierPath(arcCenter: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2), radius: radius, startAngle: CGFloat(270).toRadians(), endAngle: CGFloat(270.001).toRadians(), clockwise: false)
        ring.path = path.cgPath
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}


extension CGFloat{
    
    func toRadians() -> CGFloat{
        return CGFloat(Measurement(value: Double(self), unit: UnitAngle.degrees).converted(to: .radians).value)
    }
    
}

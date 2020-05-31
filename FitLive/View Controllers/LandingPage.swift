//
//  LandingPage.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/30/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit


class LandingPage: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        logoView.pin(addTo: view, .centerX == view.centerXAnchor, .top == view.safeAreaLayoutGuide.topAnchor + 30)
        logoViewBottomText.pin(addTo: view, .centerX == view.centerXAnchor, .top == logoView.bottomAnchor - 30)
        
        bottomLabel.pin(addTo: view, .bottom == view.safeAreaLayoutGuide.bottomAnchor - 40, .centerX == view.centerXAnchor)
        buttonsStackView.pin(addTo: view, .left == view.leftAnchor + 30, .right == view.rightAnchor - 30, .bottom == bottomLabel.topAnchor - 50)
    }
    
    private lazy var logoView: UIImageView = {
        let x = UIImageView(image: UIImage(named: "newFitMateLogo")!)
        x.pin(.width == 233, .height == 260)
        x.contentMode = .scaleAspectFit
        return x
    }()
    
    private lazy var logoViewBottomText: UILabel = {
        let x = UILabel()
        x.font = ThemeFont.regular.getUIFont(size: 15)
        x.text = "Workout together, wherever."
        x.textColor = CustomColors.dimmedBlueText
        return x
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let x = UIStackView(arrangedSubviews: [loginButton, signUpButton])
        x.spacing = 30
        x.axis = .vertical
        return x
    }()
    
    private lazy var loginButton: UIButton = {
        let x = getNewLogInOrSignUpButton(text: "Login")
        x.addTarget(self, action: #selector(respondToLoginButtonPressed), for: .touchUpInside)
        return x
    }()
    
    @objc private func respondToLoginButtonPressed(){
        self.present(LoginViewController(), animated: true, completion: nil)
    }
    
    private lazy var signUpButton: UIButton = {
        let x = getNewLogInOrSignUpButton(text: "Sign Up")
        x.addTarget(self, action: #selector(respondToSignUpButtonPressed), for: .touchUpInside)
        return x
    }()
        
    @objc private func respondToSignUpButtonPressed(){
        
        self.present(SignUpViewController(), animated: true, completion: nil)
    }
    
    private func getNewLogInOrSignUpButton(text: String) -> UIButton{
        let x = UIButton(type: .system)
        x.setAttributedTitle(NSAttributedString(string: text, attributes: [.foregroundColor: UIColor.white, .font: ThemeFont.regular.getUIFont(size: 15)]), for: .normal)
        x.pin(.height == 60)
        x.backgroundColor = CustomColors.aqua
        x.layer.cornerRadius = 10
        x.layer.masksToBounds = true
        return x
    }
    
    private lazy var bottomLabel: UILabel = {
        let x = UILabel()
        x.numberOfLines = 0
        let fontSize: CGFloat = 12
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let text = NSMutableAttributedString(string: "By signing up you agree with Fitmate's", attributes: [.foregroundColor: CustomColors.dimmedBlueText, .font: ThemeFont.regular.getUIFont(size: fontSize), .paragraphStyle: paragraphStyle])
        text.append(NSAttributedString(string: "\nTerms of Service and Privacy Policy", attributes: [.foregroundColor: CustomColors.dimmedBlueText, .font: ThemeFont.bold.getUIFont(size: fontSize), .paragraphStyle: paragraphStyle]))
        x.attributedText = text
        return x
    }()
    
    
}

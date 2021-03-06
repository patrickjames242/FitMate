//
//  SignUpViewController.swift
//  FitLive
//
//  Created by Akeil S on 5/30/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    private let defaultScrollViewBottomInset: CGFloat = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        scrollView.pinAllSides(addTo: view, pinTo: view.safeAreaLayoutGuide)
        logoView.pin(addTo: scrollView, .centerX == scrollView.contentLayoutGuide.centerXAnchor, .top == scrollView.contentLayoutGuide.topAnchor + 25)
        titleLabel.pin(addTo: scrollView, .top == logoView.bottomAnchor + 25, .centerX == scrollView.contentLayoutGuide.centerXAnchor)
        stackView.pin(addTo: scrollView, .left == scrollView.contentLayoutGuide.leftAnchor + 30, .right == scrollView.contentLayoutGuide.rightAnchor - 30, .top == titleLabel.bottomAnchor + 35, .bottom == scrollView.contentLayoutGuide.bottomAnchor)
        
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) {[weak self] notification in
            guard let self = self else {return}
            let keyboardHeightAboveScreenBottom = UIScreen.main.bounds.height - (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).minY
            
            self.scrollView.contentInset.bottom = keyboardHeightAboveScreenBottom + self.defaultScrollViewBottomInset
            
        }
    }
    
    
    
    private lazy var scrollView: UIScrollView = {
        class CustomScrollView: UIScrollView{
            override func touchesShouldCancel(in view: UIView) -> Bool { return true }
        }
        
        let x = CustomScrollView()
        x.delaysContentTouches = false
        x.alwaysBounceVertical = true
        x.contentLayoutGuide.pin(.width == x.frameLayoutGuide.widthAnchor)
        x.contentInset.bottom = self.defaultScrollViewBottomInset
        return x
    }()
    
    private lazy var titleLabel: UILabel = {
        let x = UILabel()
        x.font = ThemeFont.bold.getUIFont(size: 25)
        x.numberOfLines = 0
        x.textAlignment = .center
        x.text = "Welcome,\nLets get fit!"
        return x
    }()
    
    private lazy var stackView: UIStackView = {
        let x = UIStackView(arrangedSubviews: [nameTextField, emailTextField, usernameTextField, passwordTextField, signUpButton])
        x.axis = .vertical
        x.spacing = 20
        return x
    }()
    
    
    private lazy var nameTextField = getNewTextField(placeholder: "name")
    private lazy var emailTextField = getNewTextField(placeholder: "email")
    private lazy var usernameTextField = getNewTextField(placeholder: "username")
    private lazy var passwordTextField = getNewTextField(placeholder: "password")
    
    
    private func getNewTextField(placeholder: String) -> UITextField{
        let x = UITextField()
        x.pin(.height == 64)
        x.textAlignment = .center
        x.font = ThemeFont.regular.getUIFont(size: 15)
        x.placeholder = placeholder
        x.layer.cornerRadius = 10
        x.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
        x.returnKeyType = .done
        x.delegate = self
        return x
    }
    
    
    private lazy var signUpButton: UIButton = {
        let x = UIButton(type: .system)
        x.setAttributedTitle(NSAttributedString(string: "Sign Up", attributes: [.foregroundColor: UIColor.white, .font: ThemeFont.regular.getUIFont(size: 15)]), for: .normal)
        x.pin(.height == 60)
        x.backgroundColor = CustomColors.aqua
        x.layer.cornerRadius = 10
        x.layer.masksToBounds = true
        x.addTarget(self, action: #selector(respondToSignUpButtonPressed), for: .touchUpInside)
        return x
    }()
    
    @objc private func respondToSignUpButtonPressed(){
        signUpButton.isUserInteractionEnabled = false
        do{
            let signUpInfo = try Networking.SignUpInfo(username: usernameTextField.text ?? "", displayName: nameTextField.text ?? "", password: passwordTextField.text ?? "", email: emailTextField.text ?? "")
            Networking.signUp(info: signUpInfo) { result in
                self.signUpButton.isUserInteractionEnabled = true
                switch result{
                case .success:
                    self.present(FitBudyViewController.getNew(), animated: true, completion: nil)
                case .failure(let error):
                    self.displayErrorMessage(message: error.localizedDescription)
                }
                
            }
        } catch {
            self.displayErrorMessage(message: error.localizedDescription)
        }

    }
    
    private lazy var logoView: UIImageView = {
        let x = UIImageView(image: UIImage(named: "newFitMateLogo")!)
        x.pin(.width == 105, .height == 83)
        return x
    }()
    
}



extension SignUpViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}



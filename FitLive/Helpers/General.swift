//
//  General.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/29/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//
import UIKit

typealias CompletionResult<ResultType> = Result<ResultType, Error>



public struct GenericError: LocalizedError{
    
    public static var unknown = GenericError("An unknown error occured.")
    
    public var errorDescription: String?
    
    public init(_ description: String){
        self.errorDescription = description
    }
}


func isValidEmail(email: String) -> Bool{
    let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    return NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: email)
    
}


extension UIViewController{
    
    func displayErrorMessage(message: String){
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}

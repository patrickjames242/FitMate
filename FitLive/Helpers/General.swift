//
//  General.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/29/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//
import Foundation

typealias CompletionResult<ResultType> = Result<ResultType, Error>



public struct GenericError: LocalizedError{
    
    public static var unknown = GenericError("An unknown error occured.")
    
    public var errorDescription: String?
    
    public init(_ description: String){
        self.errorDescription = description
    }
}

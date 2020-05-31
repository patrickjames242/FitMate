//
//  Notification.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/31/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit

extension CustomNotification where ActionParameterType == Void{
    open func post(){
        post(with: ())
    }
}



/** This class is a substitute for the NotificationCenter class. Using NotificationCenter to send custom notifications tends to be a bit verbose, and this class aims to cut down on this code and improve readability.

 To use this class, first instantiate a notification instance like below
 
 let UserDidLoginNotification = CustomNotification<User>()
 
 to post the notification:
 
 UserDidLoginNotification.post(with: User())
 
 to respond to the notification:
 
 UserDidLoginNotification.listen(sender: self) { (user) in
    // perform some action with the user instance
 }
 
 you can also remove a notification listener like so:
 
 UserDidLoginNotification.removeListener(sender: self)
 
 **/

open class CustomNotification<ActionParameterType> {
    
    public init(){}
    
    
    private var actionArray =
        [(sender: WeakWrapper<AnyObject>, action: (ActionParameterType) -> Void)]() {
        didSet {
            actionArray.removeAll(where: {$0.sender.value == nil})
        }
    }

    /// Always posts on the main thread, even if the function isn't called on the main thread.
    open func post(with parameter: ActionParameterType){
        let action = { self.actionArray.forEach{$0.action(parameter)} }

        if Thread.isMainThread == false{
            DispatchQueue.main.sync(execute: action)
        } else { action() }
    }
    
    /// the action is always performed on the main thread.
    open func listen(sender: AnyObject, action: @escaping (ActionParameterType) -> Void){
        actionArray.append((WeakWrapper(sender), action))
    }
    
    open func removeListener(sender: AnyObject){
        actionArray.removeAll(where: {$0.sender.value === sender})
    }
    
    
}




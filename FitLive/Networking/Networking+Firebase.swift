//
//  Networking+Firebase.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/30/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

extension Networking{
    
    enum Firebase{
        
        struct SignUpInfo{
            let username: String
            let displayName: String
            let email: String
            let password: String
            
            init(username: String, displayName: String, email: String, password: String) throws {
                guard isValidEmail(email: email) else {throw GenericError("The email you entered was invalid.")}
                guard Array(password).count >= 8 else {throw GenericError("Your password must be at least 8 characters long.")}
                self.username = username
                self.displayName = displayName
                self.email = email
                self.password = password
            }
        }
        
        
        typealias UserResolverFunction = (_ quickBloxID: Int, _ quickBloxPassword: String, _ completion: @escaping (CompletionResult<User>) -> ()) -> ()
        
        
        static func signUp(info: SignUpInfo, completion: @escaping (CompletionResult<(userResolver: UserResolverFunction, cancelSignUp: () -> Void)>) -> ()) {
            Auth.auth().createUser(withEmail: info.email, password: info.password) { (result, error) in
                
                guard let result = result else {
                    completion(.failure(error ?? GenericError("An unknown error occured in the Firebase signUp function")))
                    return
                }
                
                let cancelSignUp = {
                    result.user.delete(completion: nil)
                    logOut()
                }
                
                let userId = result.user.uid
                let properties: [UserProperties] = [.username(info.username), .displayName(info.displayName), .email(info.email), .firebaseID(userId)]
                
                setUserInformation(userID: userId, propertyValues: properties) { setUserInfoResult in
                    switch setUserInfoResult{
                    case .success:
                        
                        let cancelSignUp = {
                            deleteUserInformation(userID: userId, completion: nil)
                            cancelSignUp()
                        }
                        
                        completion(.success((getUserResolverFunction(firebaseUserID: userId), cancelSignUp)))
                    case .failure(let error):
                        cancelSignUp()
                        completion(.failure(error))
                    }
                }
            }
        }
        
        
        
        
        private static func getUserResolverFunction(firebaseUserID: String) -> UserResolverFunction {
            return { (quickBloxId, quickBloxPassword, completion) in
                setUserInformation(
                    userID: firebaseUserID,
                    propertyValues: [.quickBloxId(quickBloxId), .quickBloxPassword(quickBloxPassword)]
                ) { (setUserInfoResult) in
                    
                    switch setUserInfoResult{
                    case .success:
                        
                        getUserInformation(userID: firebaseUserID) { getUserInfoResult in
                            completion(getUserInfoResult.flatMap({ userInfo -> CompletionResult<User> in
                                if let user = userInfo?.userObject{
                                    return .success(user)
                                } else {
                                    return .failure(GenericError("The user object retreived from the getUserInformation function is not valid. Check the Firebase.getUserResolverFunction function."))
                                }
                            }));
                        }
                        
                    case .failure(let error): completion(.failure(error))
                    }
                }
            }
        }
        
        
        static func logIn(email: String, password: String, completion: @escaping (CompletionResult<(user: User, cancelLogIn: () -> Void)>) -> ()){
            
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                guard let result = result else {
                    completion(.failure(error ?? GenericError("An unknown error occured in the Firebase.logIn function")))
                    return
                }
                
                let cancelLogIn = {
                    logOut()
                }
                
                getUserInformation(userID: result.user.uid) { userInfoResult in
                    switch userInfoResult{
                    case .success(let userInfoObject):
                        if let user = userInfoObject?.userObject{
                            
                            completion(.success((user, cancelLogIn)))
                        } else {
                            completion(.failure(GenericError("The user object retreived from the getUserInformation function is not valid. Check the Firebase.logIn function.")))
                        }
                    case .failure(let error):
                        cancelLogIn()
                        completion(.failure(error))
                    }
                }
            }
            
        }
        
        
        
        static func logOut(){
            do{
                try Auth.auth().signOut()
            } catch {
                print(error)
            }
            
        }
        
        
        
        private struct PropertyKeys{
            static let firebaseID = "firebaseID"
            static let email = "email"
            static let username = "username"
            static let displayName = "displayName"
            static let quickBloxId = "quickBloxId"
            static let quickBloxPassword = "quickBloxPassword"
        }
        
        private struct FirebaseUserInfo{
            
            let firebaseID: String?
            let quickBloxId: Int?
            let quickBloxPassword: String?
            let username: String?
            let displayName: String?
            let email: String?
            
            var userObject: User?{
                guard let firebaseID = firebaseID,
                    let quickBloxId = quickBloxId,
                    let quickBloxPassword = quickBloxPassword,
                    let username = username,
                    let displayName = displayName,
                    let email = email else {return nil}
                return User(firebaseID: firebaseID, quickBoxId: quickBloxId, quickBloxPassword: quickBloxPassword, username: username, displayName: displayName, email: email)
            }
        }
        
        private enum UserProperties{
            
            case firebaseID(String)
            case email(String)
            case username(String)
            case displayName(String)
            case quickBloxId(Int)
            case quickBloxPassword(String)
            
            var key: String{
                switch self{
                case .firebaseID: return PropertyKeys.firebaseID
                case .email: return PropertyKeys.email
                case .username: return PropertyKeys.username
                case .displayName: return PropertyKeys.displayName
                case .quickBloxId: return PropertyKeys.quickBloxId
                case .quickBloxPassword: return PropertyKeys.quickBloxPassword
                }
            }
            
            var value: Any{
                switch self{
                case .firebaseID(let firebaseID): return firebaseID
                case .email(let email): return email
                case .username(let username): return username
                case .displayName(let displayName): return displayName
                case .quickBloxId(let quickBloxId): return quickBloxId
                case .quickBloxPassword(let quickBloxPassword): return quickBloxPassword
                }
            }
            
        }
        
        private static var usersCollection: CollectionReference{
            return Firestore.firestore().collection("Users")
        }
    
        
        private static func setUserInformation(userID: String, propertyValues: [UserProperties], completion: @escaping (CompletionResult<Void>) -> Void){
            let valueDict = Dictionary(uniqueKeysWithValues: propertyValues.map{($0.key, $0.value)})
            usersCollection.document(userID).setData(valueDict, merge: true) { error in
                if let error = error{
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
        
        private static func deleteUserInformation(userID: String, completion: ((CompletionResult<Void>) -> Void)?){
            usersCollection.document(userID).delete { error in
                if let error = error{
                    completion?(.failure(error))
                } else {
                    completion?(.success(()))
                }
            }
        }
        
        
        static func observeUsers(handleNewUsersArray: @escaping ([Networking.User]) -> ()) -> ListenerRegistration{
            return usersCollection.addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                let users = snapshot.documents.compactMap{ parseFirebaseUserInfoFrom(dict: $0.data()).userObject }
                handleNewUsersArray(users)
            }
        }
        
        
        private static func getUserInformation(userID: String, completion: @escaping (CompletionResult<FirebaseUserInfo?>) -> ()){
            usersCollection.document(userID).getDocument { (snapshot, error) in
                if let data = snapshot?.data(){
                    let user = FirebaseUserInfo(
                        firebaseID: data[PropertyKeys.firebaseID] as? String,
                        quickBloxId: data[PropertyKeys.quickBloxId] as? Int,
                        quickBloxPassword: data[PropertyKeys.quickBloxPassword] as? String,
                        username: data[PropertyKeys.username] as? String,
                        displayName: data[PropertyKeys.displayName] as? String,
                        email: data[PropertyKeys.email] as? String
                    )
                    completion(.success(user))
                } else {
                    completion(.failure(error ?? GenericError("An unknown error occured in the getUserInformation function")))
                }
            }
        }
        
        
        private static func parseFirebaseUserInfoFrom(dict: [String: Any]) -> FirebaseUserInfo{
            return FirebaseUserInfo(
                firebaseID: dict[PropertyKeys.firebaseID] as? String,
                quickBloxId: dict[PropertyKeys.quickBloxId] as? Int,
                quickBloxPassword: dict[PropertyKeys.quickBloxPassword] as? String,
                username: dict[PropertyKeys.username] as? String,
                displayName: dict[PropertyKeys.displayName] as? String,
                email: dict[PropertyKeys.email] as? String
            )
        }
        
        
    }
    
    
    
}



//
//  UserDefaultsProperty.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/29/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//




import UIKit


/// use this struct to access a particular property in User Defaults. Handles encoding and decoding automatically IF NEEDED
@propertyWrapper
struct UserDefaultsProperty<Value: Codable>{
    
    private let key: String
    
    init(key: String){
        self.key = key
    }

    /// if the value is a valid property list object, it is placed directly in UserDefaults as is, if not, it is converted to a data object first, then placed into UserDefaults
    var wrappedValue: Value?{
        get{ return getValue() }
        set{ setValue(to: newValue) }
    }
    
    private func getValue() -> Value?{
        guard let gottenValue = UserDefaults.standard.value(forKey: key) else {return nil}
        
        if let gottenValue = gottenValue as? Value{
            return gottenValue
        } else if let data = gottenValue as? Data{
            return try? PropertyListDecoder().decode(Value.self, from: data)
        } else {
            return nil
        }
    }
    
    private func setValue(to newValue: Value?){
        guard let newValue = newValue else {
            UserDefaults.standard.removeObject(forKey: key)
            return
        }
        
        if isValidPropertyList(value: newValue){
            UserDefaults.standard.set(newValue, forKey: key)
        } else if let data = try? PropertyListEncoder().encode(newValue){
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func isValidPropertyList(value: Any) -> Bool{
        return PropertyListSerialization.propertyList(value, isValidFor: .binary)
    }
}


@propertyWrapper
struct NonNilUserDefaultsProperty<Value: Codable>{
    
    private var property: UserDefaultsProperty<Value>
    
    private let defaultValue: Value
    
    init(key: String, defaultValue: Value){
        self.defaultValue = defaultValue
        self.property = UserDefaultsProperty(key: key)
    }
    
    var wrappedValue: Value{
        get{
            return property.wrappedValue ?? self.defaultValue
        } set {
            self.property.wrappedValue = newValue
        }
    }
}

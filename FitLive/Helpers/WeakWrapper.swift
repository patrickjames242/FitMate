//
//  WeakWrapper.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/31/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import Foundation



/// This struct allows you to place class instances in collections without worry that the collection will prevent the instances from being deallocated.
struct WeakWrapper<Wrapped: AnyObject>{
    
    private(set) weak var value: Wrapped?
    
    init(_ value: Wrapped){
        self.value = value
    }
    
}

extension WeakWrapper: Hashable where Wrapped: Hashable{
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
}

extension WeakWrapper: Equatable{
    
    static func == (lhs: WeakWrapper<Wrapped>, rhs: WeakWrapper<Wrapped>) -> Bool {
        return lhs.value === rhs.value
    }
    
}



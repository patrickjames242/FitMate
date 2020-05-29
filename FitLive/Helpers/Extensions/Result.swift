//
//  Result.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/29/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

extension Result{
    
    var result: Success?{
        switch(self){
        case .success(let success): return success
        case .failure: return nil
        }
    }
    
    var error: Failure?{
        switch (self){
        case .success: return nil
        case .failure(let error): return error
        }
    }
    
}

//
//  Fonts.swift
//  FitLive
//
//  Created by Patrick Hanna on 5/30/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit



enum ThemeFont{
    
    case regular, bold
    
    func getUIFont(size: CGFloat) -> UIFont{
        let helveticaPrefix = "HelveticaNeue"
        let typeString: String = {
            switch self{
            case .regular: return helveticaPrefix
            case .bold: return helveticaPrefix + "-Bold"
            }
        }()
        return UIFont(name: typeString, size: size)!
    }
    
}

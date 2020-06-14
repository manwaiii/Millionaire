//
//  RoundedButton.swift
//  Millionare
//
//  Created by delta on 12/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable extension UIButton {
   
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
            layer.masksToBounds = true
            layer.cornerRadius = bounds.size.width/2
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

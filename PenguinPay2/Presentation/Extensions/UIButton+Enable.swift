//
//  UIButton+Enable.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 24/03/2022.
//

import UIKit

extension UIButton {
    func enable() {
        isEnabled = true
        setTitleColor(.white, for: .normal)
        backgroundColor = UIColor(red: 0.00, green: 0.37, blue: 0.45, alpha: 1.00)
    }
    
    func disable() {
        isEnabled = false
        setTitleColor(.gray, for: .normal)
        backgroundColor = .lightGray
    }
}

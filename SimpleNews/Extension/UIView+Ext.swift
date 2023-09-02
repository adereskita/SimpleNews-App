//
//  UIView+Ext.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import UIKit

extension UIView {
    // MARK: - NIB
    static func nibName() -> String {
        let nameSpaceClassName = NSStringFromClass(self)
        let className = nameSpaceClassName.components(separatedBy: ".").last! as String
        return className
    }
    
    static func nib() -> UINib {
        return UINib(nibName: self.nibName(), bundle: nil)
    }
    
    static func identifier() -> String {
        return self.nibName()
    }
}

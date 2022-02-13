//
//  Extensions.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 10/2/22.
//

import UIKit


extension NSLayoutConstraint {
    //MARK: Change NSLayoutConstraint Multiplier Property
    func changeMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
          item: firstItem,
          attribute: firstAttribute,
          relatedBy: relation,
          toItem: secondItem,
          attribute: secondAttribute,
          multiplier: multiplier,
          constant: constant)
        newConstraint.priority = priority

        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

//MARK: Defines the action when adding or editing a StudentLocation
enum StudentLocationAction {
    case add, override
}


extension URL {
    func isValid() -> Bool { return UIApplication.shared.canOpenURL(self) }
}


extension String {
    func isOnlyWhiteSpaces() -> Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

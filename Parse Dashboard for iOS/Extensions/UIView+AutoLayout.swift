//
//  UIView+Autolayout.swift
//  Reward Wallet
//
//  Copyright © 2017 Nathan Tannar.
//  Created by Nathan Tannar on 7/5/17.
//

import UIKit

public extension UIView {
    
    func fillSuperview() {
        
        guard let superview = self.superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
    
    func anchorAspectRatio() {
        let aspectRatioConstraint = NSLayoutConstraint(item: self,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: self,
                                                       attribute: .width,
                                                       multiplier: 1,
                                                       constant: 0)
        
        self.addConstraint(aspectRatioConstraint)
    }
    
    @discardableResult
    func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        
        translatesAutoresizingMaskIntoConstraints = false
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            let constraint = topAnchor.constraint(equalTo: top, constant: topConstant)
            constraint.identifier = "top"
            anchors.append(constraint)
        }
        
        if let left = left {
            let constraint = leftAnchor.constraint(equalTo: left, constant: leftConstant)
            constraint.identifier = "left"
            anchors.append(constraint)
        }
        
        if let bottom = bottom {
            let constraint = bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant)
            constraint.identifier = "bottom"
            anchors.append(constraint)
        }
        
        if let right = right {
            let constraint = rightAnchor.constraint(equalTo: right, constant: -rightConstant)
            constraint.identifier = "right"
            anchors.append(constraint)
        }
        
        if widthConstant > 0 {
            let constraint = widthAnchor.constraint(equalToConstant: widthConstant)
            constraint.identifier = "width"
            anchors.append(constraint)
        }
        
        if heightConstant > 0 {
            let constraint = heightAnchor.constraint(equalToConstant: heightConstant)
            constraint.identifier = "height"
            anchors.append(constraint)
        }
        
        NSLayoutConstraint.activate(anchors)
        return anchors
    }
    
    func anchorCenterXToSuperview(constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    func anchorCenterYToSuperview(constant: CGFloat = 0) {
      
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    func anchorCenterToSuperview() {
        anchorCenterYToSuperview()
        anchorCenterXToSuperview()
    }
    
    func constraint(withIdentifier identifier: String) -> NSLayoutConstraint? {
        let constraints = self.constraints.filter { $0.identifier == identifier }
        return constraints.first
    }
    
    func anchorWidthToItem(_ item: UIView) {
        let widthConstraint = widthAnchor.constraint(equalTo: item.widthAnchor, multiplier: 1)
        widthConstraint.isActive = true
    }
    
    func anchorHeightToItem(_ item: UIView) {
        let widthConstraint = heightAnchor.constraint(equalTo: item.heightAnchor, multiplier: 1)
        widthConstraint.isActive = true
    }
    
    func removeAllConstraints() {
        for constraint in constraints {
            NSLayoutConstraint.deactivate([constraint])
            removeConstraint(constraint)
        }
    }
}

//
//  UIView+Autolayout.swift
//  AlertKit
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 2/12/17.
//

import UIKit

extension UIView {
    
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
        var view: UIView? = self
        while let currentView = view {
            currentView.removeConstraints(currentView.constraints.filter {
                return $0.firstItem as? UIView == self || $0.secondItem as? UIView == self
            })
            view = view?.superview
        }
    }
}

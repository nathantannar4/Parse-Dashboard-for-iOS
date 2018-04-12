//
//  Ping.swift
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
//  Created by Nathan Tannar on 10/19/17.
//

import UIKit

open class Ping: UIView {
    
    // MARK: - Properties [Public]
    
    open var currentState: Alert.State = .inactive
    
    open let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.textAlignment = .center
        return label
    }()
    
    public var statusBar: UIView? {
        return UIApplication.shared.value(forKey: "statusBar") as? UIView
    }
    
    // MARK: - Initialization
    
    required public init(text: String, style: Alert.Style) {
        super.init(frame: .zero)
        backgroundColor = style.color
        textLabel.text = text
        textLabel.font = style.font
        textLabel.textColor = style.color.isDark ? .white : .darkText
        addSubview(textLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Standard Methods
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = requiredTextLabelFrame()
    }
    
    // MARK: - Presentation/Dismissal
    
    open func show(animated: Bool = true, duration: TimeInterval = 3.0) {
        
        guard let statusBar = statusBar, currentState == .inactive else { return }
        currentState = .transitioning
        statusBar.addSubview(self)
        frame = requiredFrame()
        frame.origin.y = statusBar.frame.origin.y - statusBar.frame.size.height
        UIView.transition(with: self, duration: 0.3, options: .curveEaseOut, animations: {
                self.frame.origin.y = statusBar.frame.origin.y
            }, completion: { _ in
                self.currentState = .active
                self.anchor(statusBar.topAnchor,
                            left: statusBar.leftAnchor,
                            right: statusBar.rightAnchor,
                            heightConstant: self.frame.height)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                    self.dismiss(animated: animated)
                }
            }
        )
    }
    
    open func dismiss(animated: Bool = true) {
        
        guard currentState == .active else { return }
        currentState = .transitioning
        if animated {
            UIView.transition(with: self, duration: 0.3, options: .curveEaseIn, animations: {
                self.frame.origin = CGPoint(x: 0, y: -self.frame.height)
            }, completion: { finished in
                self.currentState = .inactive
                self.removeFromSuperview()
            })
        } else {
            currentState = .inactive
            removeFromSuperview()
        }
    }
    
    private func requiredFrame() -> CGRect {
        
        guard let statusBar = statusBar else { return .zero }
        if UIDevice.current.model == .iPhoneX {
            return CGRect(x: 0, y: 0,
                          width: statusBar.frame.size.width, height: statusBar.frame.height + 6)
        } else {
            return statusBar.frame
        }
    }
    
    private func requiredTextLabelFrame() -> CGRect {
        if UIDevice.current.model == .iPhoneX {
            let insetHeight: CGFloat = 33
            return CGRect(x: 16, y: insetHeight,
                          width: frame.size.width - 32, height: frame.size.height - insetHeight - 1)
        } else {
            return frame.insetBy(dx: 16, dy: 1)
        }
    }
}


//
//  Toast.swift
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

open class Toast: UIView {
    
    // MARK: - Properties [Public]
    
    open var dismissOnTap: Bool = true
    
    open var showActionButton: Bool = false {
        didSet {
            layoutElements()
        }
    }
    
    open var currentState: Alert.State = .inactive {
        didSet {
            isUserInteractionEnabled = currentState != .transitioning
        }
    }
    
    open var isRippleEnabled: Bool = true
    
    open var rippleAnimationTime: TimeInterval = 0.75
    
    open var ripplePercent: CGFloat = 150 {
        didSet {
            layoutRippleView()
        }
    }
    
    open var rippleColor: UIColor? = UIColor(white: 1, alpha: 0.1) {
        didSet {
            rippleView.backgroundColor = rippleColor
        }
    }
    
    open var rippleBackgroundColor: UIColor? {
        didSet {
            rippleBackgroundView.backgroundColor = rippleBackgroundColor
        }
    }
    
    open var height: CGFloat = 44 {
        didSet {
            let newFrame = CGRect(origin: frame.origin, size: CGSize(width: frame.size.width, height: height))
            frame = newFrame
            layoutSubviews()
        }
    }
    
    open let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.textColor = .white
        label.font = Alert.Defaults.Font.Info
        return label
    }()
    
    open let actionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .highlighted)
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    private var touchCenterLocation: CGPoint?
    private let rippleView = UIView()
    private let rippleBackgroundView = UIView()
    private var action: (()->Void)?
    
    // MARK: - Initializers
    
    public convenience init(text: String) {
        self.init(text: text, actionText: nil, action: nil)
    }
    
    required public init(text: String, actionText: String?, action: (()->Void)?) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: height)))
        self.textLabel.text = text
        self.actionButton.setTitle(actionText, for: .normal)
        self.showActionButton = action != nil
        self.action = action
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Additional Setup
    
    open func setup() {
        addSubviews()
        layoutRippleView()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(Toast.didTap(gesture:))))
        actionButton.addTarget(self, action: #selector(Toast.didTapActionButton(button:)), for: .touchUpInside)
        backgroundColor = UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1)
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    private func layoutRippleView() {
        
        let size: CGFloat = bounds.width * ripplePercent / 100
        let x: CGFloat = (bounds.width/2) - (size/2)
        let y: CGFloat = (bounds.height/2) - (size/2)
        let corner: CGFloat = size/2
        
        rippleView.backgroundColor = rippleColor
        rippleView.frame = CGRect(x: x, y: y, width: size, height: size)
        rippleView.layer.cornerRadius = corner
        
        rippleBackgroundView.backgroundColor = rippleBackgroundColor
        rippleBackgroundView.frame = bounds
        rippleBackgroundView.alpha = 0
        
        if let knownTouchCenterLocation = touchCenterLocation {
            rippleView.center = knownTouchCenterLocation
        }
        rippleBackgroundView.layer.frame = bounds
        rippleBackgroundView.layer.mask = rippleMask()
    }
    
    private func layoutElements() {
        
        let bottomInset: CGFloat = UIDevice.current.model == .iPhoneX ? 20 : 0
        if showActionButton {
            let requiredButtonSize = actionButton.intrinsicContentSize
            actionButton.frame = CGRect(x: bounds.width - requiredButtonSize.width - 16, y: 4,
                                        width: requiredButtonSize.width, height: bounds.height - 8 - bottomInset)
            textLabel.frame = CGRect(x: 16, y: 4,
                                     width: bounds.width - requiredButtonSize.width - 42,
                                     height: bounds.height - 8 - bottomInset)
        } else {
            textLabel.frame = CGRect(x: 16, y: 4,
                                     width: bounds.width - 32, height: bounds.height - 8 - bottomInset)
        }
    }
    
    private func addSubviews() {
        addSubview(rippleBackgroundView)
        rippleBackgroundView.addSubview(rippleView)
        addSubview(textLabel)
        addSubview(actionButton)
    }
    
    // MARK: - Standard Methods
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layoutRippleView()
        layoutElements()
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isRippleEnabled {
            rippleView.center = touches.first?.location(in: self) ?? center
        } else {
            rippleView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        }
        animate()
        super.touchesBegan(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateToNormal()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateToNormal()
    }
    
    // MARK: - Presentation/Dismissal
    
    open func present(_ viewController: UIViewController, animated: Bool = true, duration: TimeInterval = 3.0) {
        
        guard currentState == .inactive else { return }
        currentState = .transitioning
        let height = UIDevice.current.model == .iPhoneX ? (frame.height + 20) : frame.height
        frame = CGRect(x: 0, y: viewController.view.frame.height,
                       width: viewController.view.frame.width, height: height)
        viewController.view.addSubview(self)
        UIView.transition(with: self, duration: 0.3, options: .curveLinear, animations: {
                self.frame.origin.y = viewController.view.frame.height - self.frame.height
            }, completion: { _ in
                self.currentState = .active
                self.anchor(left: viewController.view.leftAnchor,
                            bottom: viewController.view.bottomAnchor,
                            right: viewController.view.rightAnchor,
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
            UIView.transition(with: self, duration: 0.3, options: .curveLinear, animations: {
                self.alpha = 0
            }, completion: { _ in
                self.currentState = .inactive
                self.removeFromSuperview()
            })
        } else {
            currentState = .inactive
            removeFromSuperview()
        }
    }
    
    @objc
    private func didTap(gesture: UITapGestureRecognizer) {
        if dismissOnTap {
            dismiss()
        }
    }
    
    @objc
    private func didTapActionButton(button: UIButton) {
        button.isUserInteractionEnabled = false
        rippleView.center = button.center
        animate()
        action?()
        dismiss()
    }
    
    // MARK: - Ripple Animation Methods
    
    private func animate() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
            self.rippleBackgroundView.alpha = 1
        }, completion: nil)
        rippleView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseOut, .allowUserInteraction],
                       animations: {
                        self.rippleView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private func animateToNormal() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
            self.rippleBackgroundView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: self.rippleAnimationTime, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                self.rippleBackgroundView.alpha = 0
            }, completion: nil)
        })
        
        UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction], animations: {
            self.rippleView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private func rippleMask() -> CAShapeLayer {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        return maskLayer
    }
}


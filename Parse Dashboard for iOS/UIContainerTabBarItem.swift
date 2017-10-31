//
//  UIContainerTabBarItem.swift
//  UIControllerContainer
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
//  Created by Nathan Tannar on 10/28/17.
//

import UIKit

open class UIContainerTabBarItem: UICollectionViewCell {
    
    public enum UIContainerTabBarItemSelectionStyle {
        case none, gray, automatic
        case custom(UIColor)
    }
    
    // MARK: - Properties [Public]
    
    public static var reuseIdentifier: String {
        return "UIContainerTabBarItem"
    }
    
    open var activeTintColor: UIColor?
    
    open var inactiveTintColor: UIColor?
    
    open var isActive: Bool = false {
        didSet {
            tintColor = isActive ? activeTintColor : inactiveTintColor
        }
    }

    open var selectionStyle: UIContainerTabBarItemSelectionStyle = .gray {
        didSet {
            updateSelectionStyle()
        }
    }
    
    // MARK: - Subviews [Public]

    open var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    open var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    open var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        return stackView
    }()
    
    // MARK: - Subviews [Private]
    
    fileprivate let tapEffectView = UIView()

    // MARK: - Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup [Private]
    
    fileprivate func setup() {
        tapEffectView.alpha = 0
        contentView.addSubview(tapEffectView)
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(label)
        contentView.addSubview(stackView)
        stackView.fillSuperview()
        setupRippleView()
    }
    
    fileprivate func updateSelectionStyle() {
        switch selectionStyle {
        case .none:
            tapEffectView.backgroundColor = .clear
        case .gray:
            tapEffectView.backgroundColor = UIColor(white: 0.95, alpha: 0.75)
        case .automatic:
            tapEffectView.backgroundColor = activeTintColor?.withAlphaComponent(0.5)
        case .custom(let color):
            tapEffectView.backgroundColor = color
        }
    }
    
    fileprivate func setupRippleView() {
        let y = (bounds.height/2) - (bounds.width/2)
        tapEffectView.frame = CGRect(x: 0, y: y - 4, width: bounds.width, height: bounds.width + 8)
        updateSelectionStyle()
    }
    
    // MARK: - Methods [Public]
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        iconView.image = nil
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        iconView.tintColor = tintColor
        label.textColor = tintColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        setupRippleView()
    }
    
    // MARK: - Touch Animation Methods [Public]
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateTouch()
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        endTouchAnimation()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        endTouchAnimation()
    }
    
    open func animateTouch() {
//        tapEffectView.center = contentView.center
        UIView.animate(withDuration: 0.3) {
            self.tapEffectView.alpha = 1
        }
    }
    
    open func endTouchAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.tapEffectView.alpha = 0
        }
    }
}

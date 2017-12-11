//
//  DynamicTabBarCell.swift
//  DynamicTabBarController
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

open class DynamicTabBarCell: UICollectionViewCell {
    
    // MARK: - Properties [Public]
    
    open class var reuseIdentifier: String {
        return "DynamicTabBarCell"
    }
    
    open var activeTintColor: UIColor?
    
    open var inactiveTintColor: UIColor?
    
    open var isActive: Bool = false {
        didSet {
            tintColor = isActive ? activeTintColor : inactiveTintColor
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
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(label)
        contentView.addSubview(stackView)
        stackView.fillSuperview()
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

}

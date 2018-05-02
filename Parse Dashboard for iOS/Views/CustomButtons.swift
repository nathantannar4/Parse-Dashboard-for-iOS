//
//  CustomButtons.swift
//  Parse Dashboard for iOS
//
//  Copyright © 2018 Nathan Tannar.
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
//  Created by Nathan Tannar on 4/29/18.
//

import UIKit

final class CloseButton: UIButton {
    
    init(target: Any?, action: Selector) {
        super.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        setImage(UIImage(named: "icon_close")?.scale(to: 30), for: .normal)
        addTarget(target, action: action, for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

final class CloudCodeItemView: UIView {
    
    init(target: Any?, action: Selector?) {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        super.init(frame: frame)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        label.text = "Execute Cloud Code"
        label.textColor = .logoTint
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .right
        addSubview(label)
        let imageView = UIImageView(frame: CGRect(x: 150, y: 5, width: 50, height: 30))
        imageView.image = UIImage(named: "CloudCode")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .logoTint
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

final class PushNotificationItemView: UIView {
    
    init(target: Any?, action: Selector?) {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        super.init(frame: frame)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        label.text = "Send Push Notification"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .right
        addSubview(label)
        let imageView = UIImageView(frame: CGRect(x: 150, y: 5, width: 50, height: 30))
        imageView.image = UIImage(named: "Push")
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  UIActivity+OpenInSafari.swift
//  Parse Dashboard for iOS
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
//  Created by Nathan Tannar on 8/10/17.
//

import UIKit

class OpenInSafariActivity: UIActivity {
    
    private var _URL: URL?
    
    override var activityType: UIActivityType? {
        return UIActivityType(rawValue: NSStringFromClass(OpenInSafariActivity.self))
    }
    
    override var activityTitle: String? {
        return "Open in Safari"
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "icon_safari")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for activityItem in activityItems {
            guard let url = activityItem as? URL else {
                return false
            }
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        for activityItem in activityItems {
            if let url = activityItem as? URL {
                _URL = url
            }
        }
    }
    
    override func perform() {
        guard let url = _URL else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:]) { (success) in
                self.activityDidFinish(success)
            }
        } else {
            activityDidFinish(UIApplication.shared.openURL(url))
        }
        
    }
}

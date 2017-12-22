//
//  NSAttributedString+Extensions.swift
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
//  Created by Nathan Tannar on 8/31/17.
//

import UIKit

public extension NSAttributedString {
    
    static func bold(_ text: String, size: CGFloat = 11, color: UIColor = .black) -> NSAttributedString {
        let attrs: [NSAttributedStringKey:AnyObject] = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: size),
            NSAttributedStringKey.foregroundColor : color
        ]
        return NSAttributedString(string: text, attributes: attrs)
    }
    
    static func italic(_ text: String, size: CGFloat = 11, color: UIColor = .black) -> NSAttributedString {
        let attrs: [NSAttributedStringKey:AnyObject] = [
            NSAttributedStringKey.font : UIFont.italicSystemFont(ofSize: size),
            NSAttributedStringKey.foregroundColor : color
        ]
        return NSAttributedString(string: text, attributes: attrs)
    }
    
    static func normal(_ text: String, size: CGFloat = 11, color: UIColor = .black) -> NSAttributedString {
        let attrs: [NSAttributedStringKey:AnyObject] = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: size),
            NSAttributedStringKey.foregroundColor : color
        ]
        return NSAttributedString(string: text, attributes: attrs)
    }
    
}

public extension NSMutableAttributedString {
    
    @discardableResult
    func bold(_ text: String, size: CGFloat = 11, color: UIColor = .black) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey:AnyObject] = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: size),
            NSAttributedStringKey.foregroundColor : color
        ]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult
    func italic(_ text: String, size: CGFloat = 11, color: UIColor = .black) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey:AnyObject] = [
            NSAttributedStringKey.font : UIFont.italicSystemFont(ofSize: size),
            NSAttributedStringKey.foregroundColor : color
        ]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult
    func normal(_ text: String, font: UIFont = .systemFont(ofSize: 11), color: UIColor = .black) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey:AnyObject] = [
            NSAttributedStringKey.font : font,
            NSAttributedStringKey.foregroundColor : color
        ]
        let normal =  NSMutableAttributedString(string: text, attributes: attrs)
        self.append(normal)
        return self
    }
    
    
}

//
//  QueryInputCell.swift
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

final class QueryInputCell: UITableViewCell {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String {
        return "QueryInputCell"
    }
    
    var delegate: UITextViewDelegate? {
        didSet {
            textInput.delegate = delegate
        }
    }
    
    let textInput: InputTextView = {
        let textView = InputTextView()
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.returnKeyType = .done
        textView.keyboardType = .asciiCapable
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.placeholder = "limit=10&where={\"name\":\"John Doe\"}"
        return textView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func addSubviews() {
        
        addSubview(textInput)
    }
    
    private func setupConstraints() {
        
        textInput.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 4, leftConstant: 12, bottomConstant: 4, rightConstant: 12, widthConstant: 0, heightConstant: 0)
    }
}


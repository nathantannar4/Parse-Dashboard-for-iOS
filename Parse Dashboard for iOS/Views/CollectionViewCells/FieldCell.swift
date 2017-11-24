//
//  FieldCell.swift
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

class FieldCell: UITableViewCell {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String {
       return "FieldCell"
    }
    
    var key: String? {
        didSet {
            keyLabel.text = key
        }
    }
    var value: Any? {
        didSet {
            valueTextView.text = String(describing: value ?? "")
        }
    }
    
    let keyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .logoTint
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let valueTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textContainerInset.left = -5
        textView.font = UIFont.systemFont(ofSize: 14)
        return textView
    }()
    
    let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func addSubviews() {
        
        addSubview(separatorLine)
        contentView.addSubview(keyLabel)
        contentView.addSubview(valueTextView)
    }
    
    private func setupConstraints() {
        
        separatorLine.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, heightConstant: 0.5)
        
        keyLabel.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: valueTextView.topAnchor, right: contentView.rightAnchor, topConstant: 8, leftConstant: 12, bottomConstant: 6, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        valueTextView.anchor(keyLabel.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 6, leftConstant: 12, bottomConstant: 8, rightConstant: 12, widthConstant: 0, heightConstant: 0)
    }
}

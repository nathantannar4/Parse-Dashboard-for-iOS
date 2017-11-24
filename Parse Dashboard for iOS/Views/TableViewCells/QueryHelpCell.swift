//
//  QueryHelpCell.swift
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

class QueryHelpCell: UITableViewCell {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String {
        return "QueryHelpCell"
    }
    
    var leftText: [String] = [] {
        didSet {
            var text = String()
            for item in self.leftText {
                text.append(item)
                text.append("\n")
            }
            leftTextView.text = text
        }
    }
    
    var rightText: [String] = [] {
        didSet {
            var text = String()
            for item in self.rightText {
                text.append(item)
                text.append("\n")
            }
            rightTextView.text = text
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Help"
        label.textColor = .logoTint
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    let leftTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textColor = .darkGray
        textView.textContainerInset.left = -5
        return textView
    }()
    
    let rightTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textColor = .darkGray
        return textView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        
        contentView.addSubview(titleLabel)
        titleLabel.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 4, leftConstant: 16, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 20)
        
        let stackView = UIStackView(arrangedSubviews: [leftTextView, rightTextView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        contentView.addSubview(stackView)
        stackView.anchor(titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: contentView.bottomAnchor, right: titleLabel.rightAnchor, topConstant: 4, heightConstant: 0)
    }
}

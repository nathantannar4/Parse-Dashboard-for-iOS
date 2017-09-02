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
import NTComponents

class QueryHelpCell: UITableViewCell {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String {
        return "QueryHelpCell"
    }
    
    var title: String? {
        didSet {
            titleLabel.text = self.title
        }
    }
    
    var leftText: [String]! {
        didSet {
            var text = String()
            for item in self.leftText {
                text.append(item)
                text.append("\n")
            }
            leftTextView.text = text
        }
    }
    
    var rightText: [String]! {
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
        label.numberOfLines = 0
        label.textColor = Color.Default.Tint.View
        label.font = Font.Default.Subtitle
        return label
    }()
    
    let leftTextView: NTTextView = {
        let textView = NTTextView()
        textView.isEditable = false
        textView.textColor = .darkGray
        return textView
    }()
    
    let rightTextView: NTTextView = {
        let textView = NTTextView()
        textView.isEditable = false
        textView.textColor = .darkGray
        return textView
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
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(leftTextView)
        contentView.addSubview(rightTextView)
    }
    
    private func setupConstraints() {
        
        titleLabel.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: leftTextView.topAnchor, right: contentView.rightAnchor, topConstant: 8, leftConstant: 12, bottomConstant: 0, rightConstant: 2, widthConstant: 0, heightConstant: 0)
        leftTextView.anchor(titleLabel.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 85, heightConstant: 0)
        rightTextView.anchor(titleLabel.bottomAnchor, left: leftTextView.rightAnchor, bottom: contentView.bottomAnchor, right: titleLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}

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
import NTComponents

class FieldCell: UITableViewCell {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String {
       return "FieldCell"
    }
    
    var key: String? {
        didSet {
            keyLabel.text = self.key
        }
    }
    var value: Any? {
        didSet {
            guard let value = self.value else { return }
            valueTextView.text = String(describing: value)
        }
    }
    
    let keyLabel: NTLabel = {
        let label = NTLabel()
        label.textColor = Color.Default.Tint.View
        label.font = Font.Default.Subtitle
        return label
    }()
    
    let valueTextView: NTTextView = {
        let textView = NTTextView()
        textView.isEditable = false
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
        addSubview(keyLabel)
        addSubview(valueTextView)
    }
    
    private func setupConstraints() {
        
        separatorLine.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, heightConstant: 0.5)
        
        keyLabel.anchor(topAnchor, left: leftAnchor, bottom: valueTextView.topAnchor, right: rightAnchor, topConstant: 8, leftConstant: 12, bottomConstant: 6, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        valueTextView.anchor(keyLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 6, leftConstant: 12, bottomConstant: 8, rightConstant: 12, widthConstant: 0, heightConstant: 0)
    }
}

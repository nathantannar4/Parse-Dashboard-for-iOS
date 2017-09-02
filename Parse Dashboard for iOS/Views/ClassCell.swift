//
//  ClassCell.swift
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

class ClassCell: UITableViewCell {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String {
        return "ClassCell"
    }
    
    var schema: PFSchema? {
        set {
            guard let parseClass = newValue else { return }
            nameLabel.text = parseClass.name
        }
        get {
            return nil
        }
    }
    
    let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 14, g: 105, b: 160)
        view.layer.cornerRadius = 3
        return view
    }()
    
    let nameLabel: NTLabel = {
        let label = NTLabel(style: .title)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .lightBlueBackground
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func addSubviews() {
        
        addSubview(colorView)
        addSubview(nameLabel)
    }
    
    private func setupConstraints() {
        
        colorView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 5, leftConstant: 12, bottomConstant: 5, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        nameLabel.anchor(colorView.topAnchor, left: colorView.leftAnchor, bottom: colorView.bottomAnchor, right: colorView.rightAnchor, topConstant: 5, leftConstant: 8, bottomConstant: 5, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    }
}

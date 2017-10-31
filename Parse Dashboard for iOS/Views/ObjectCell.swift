//
//  ObjectCell.swift
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

class ObjectCell: UITableViewCell {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String {
        return "ObjectCell"
    }
    
    var object: PFObject? {
        set {
            guard let object = newValue else { return }
            guard let keys = self.previewKeys else { return }
            if keys.count >= 1 {
                objectIdLabel.text = object.keys.index(of: keys[0]) != nil ? String(describing: object.values[object.keys.index(of: keys[0])!]) : .undefined
                if keys.count >= 2 {
                    createdAtLabel.text = object.keys.index(of: keys[1]) != nil ? String(describing: object.values[object.keys.index(of: keys[1])!]) : .undefined
                    if keys.count >= 3 {
                        updatedAtLabel.text = object.keys.index(of: keys[2]) != nil ? String(describing: object.values[object.keys.index(of: keys[2])!]) : .undefined
                    } else {
                        updatedAtLabel.text = String(describing: object.updatedAt)
                    }
                } else {
                    createdAtLabel.text = String(describing: object.createdAt)
                    updatedAtLabel.text = String(describing: object.updatedAt)
                }
            } else {
                objectIdLabel.text = object.id
                createdAtLabel.text = String(describing: object.createdAt)
                updatedAtLabel.text = String(describing: object.updatedAt)
            }
        }
        get {
            return nil
        }
    }
    
    var previewKeys: [String]?
    
    let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 3
        return view
    }()
    
    let objectIdLabel: UILabel = {
        let label = NTLabel(style: .subtitle)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    let createdAtLabel: UILabel = {
        let label = NTLabel(style: .body)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    let updatedAtLabel: UILabel = {
        let label = NTLabel(style: .body)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initalizers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .darkPurpleAccent
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func addSubviews() {
        
        addSubview(colorView)
        addSubview(objectIdLabel)
        addSubview(createdAtLabel)
        addSubview(updatedAtLabel)
    }
    
    private func setupConstraints() {
        
        colorView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 5, leftConstant: 12, bottomConstant: 5, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        objectIdLabel.anchor(colorView.topAnchor, left: colorView.leftAnchor, bottom: createdAtLabel.topAnchor, right: colorView.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        
        createdAtLabel.anchor(objectIdLabel.bottomAnchor, left: objectIdLabel.leftAnchor, bottom: updatedAtLabel.topAnchor, right: objectIdLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        updatedAtLabel.anchor(createdAtLabel.bottomAnchor, left: objectIdLabel.leftAnchor, bottom: colorView.bottomAnchor, right: objectIdLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    // MARK: - User Interaction
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            colorView.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.colorView.backgroundColor = .white
            }
        }
    }
}

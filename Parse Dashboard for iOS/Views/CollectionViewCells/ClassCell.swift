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
import IGListKit

final class ClassCell: CollectionViewCell, ListBindable {
    
    // MARK: - Properties
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    private let middleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    // MARK: - Methods
    
    override func setupViews() {
        super.setupViews()
        
        contentView.backgroundColor = .darkPurpleAccent
        
        let stackView = UIStackView(arrangedSubviews: [topLabel, middleLabel, bottomLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        contentView.addSubview(stackView)
        stackView.anchor(contentView.topAnchor, left: contentView.layoutMarginsGuide.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.layoutMarginsGuide.rightAnchor, topConstant: 4, leftConstant: 4, bottomConstant: 4, rightConstant: 4)
    }
    
    // MARK: - ListBindle
    
    func bindViewModel(_ viewModel: Any) {
        guard let object = viewModel as? ParseLiteObject else { return }
        if let value = object.displayValue() {
            topLabel.text = String(describing: value)
        } else {
            topLabel.text = .undefined
        }
        middleLabel.text = object.createdAt
        bottomLabel.text = object.updatedAt
    }
}

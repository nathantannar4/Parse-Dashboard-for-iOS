//
//  ServerCell.swift
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
//  Created by Nathan Tannar on 8/30/17.
//

import UIKit
import IGListKit

final class ServerCell: CollectionViewCell, ListBindable {
    
    // MARK: - Subviews
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .darkBlueBackground
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    private let applicationIdLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let serverUrlLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Methods
    
    override func setupViews() {
        super.setupViews()
        
        contentView.backgroundColor = .darkBlueAccent
        
        contentView.addSubview(iconImageView)
        iconImageView.anchor(contentView.topAnchor, left: contentView.layoutMarginsGuide.leftAnchor, bottom: contentView.bottomAnchor, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 8, rightConstant: 0)
        iconImageView.anchorAspectRatio()
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, applicationIdLabel, serverUrlLabel])
        stackView.axis = .vertical
        contentView.addSubview(stackView)
        stackView.anchor(contentView.topAnchor, left: iconImageView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.layoutMarginsGuide.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 0)
    }
    
    // MARK: - ListBindable
    
    func bindViewModel(_ viewModel: Any) {
        guard let config = viewModel as? ParseServerConfig else { return }
        nameLabel.text = config.name
        if let imageData = config.icon  {
            iconImageView.image = UIImage(data: imageData)
        } else {
            iconImageView.image = nil
        }
        applicationIdLabel.text = config.applicationId
        serverUrlLabel.text = config.serverUrl
    }
}

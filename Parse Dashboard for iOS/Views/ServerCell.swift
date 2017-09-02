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
import NTComponents

class ServerCell: UITableViewCell {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String {
        return "ServerCell"
    }
    
    var server: ParseServerConfig? {
        didSet {
            guard let server = self.server else { return }
            nameLabel.text = server.name
            if let imageData = server.icon as Data?  {
                iconImageView.image = UIImage(data: imageData)
            }
            applicationIDLabel.text = server.applicationId
            serverURLLabel.text = server.serverUrl
        }
    }
    
    let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 25, g: 48, b: 64)
        view.layer.cornerRadius = 3
        return view
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(r: 30, g: 59, b: 77)
        imageView.layer.cornerRadius = 3
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let nameLabel: NTLabel = {
        let label = NTLabel(style: .title)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        return label
    }()
    
    let applicationIDLabel: NTLabel = {
        let label = NTLabel(style: .body)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        return label
    }()
    
    let serverURLLabel: NTLabel = {
        let label = NTLabel(style: .body)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        return label
    }()
    
    // MARK: - Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectionStyle = .none
        backgroundColor = .darkBlueBackground
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        
        addSubview(colorView)
        addSubview(iconImageView)
        addSubview(nameLabel)
        addSubview(applicationIDLabel)
        addSubview(serverURLLabel)
    }
    
    private func setupConstraints() {
        
        colorView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 10, leftConstant: 12, bottomConstant: 10, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        iconImageView.anchor(colorView.topAnchor, left: colorView.leftAnchor, bottom: colorView.bottomAnchor, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 0, widthConstant: 64, heightConstant: 0)
        
        nameLabel.anchor(colorView.topAnchor, left: iconImageView.rightAnchor, bottom: nil, right: colorView.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        
        applicationIDLabel.anchor(nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nameLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        serverURLLabel.anchor(applicationIDLabel.bottomAnchor, left: applicationIDLabel.leftAnchor, bottom: nil, right: applicationIDLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    // MARK: - User Interaction
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            colorView.backgroundColor = UIColor(r: 21, g: 156, b: 238)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.colorView.backgroundColor = UIColor(r: 25, g: 48, b: 64)
            }
        }
    }
}

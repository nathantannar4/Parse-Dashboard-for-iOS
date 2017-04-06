//
//  CustomCells.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 3/5/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import NTComponents

class ServerCell: UITableViewCell {
    
    var server: ParseServer? {
        didSet {
            guard let server = self.server else { return }
            nameLabel.text = server.name
            if let imageData = server.icon as? Data {
                iconImageView.image = UIImage(data: imageData)
            }
            applicationIDLabel.text = server.applicationId
            serverURLLabel.text = server.serverUrl
        }
    }
    
    let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = Color(r: 25, g: 48, b: 64)
        view.layer.cornerRadius = 3
        return view
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Color(r: 30, g: 59, b: 77)
        imageView.layer.cornerRadius = 3
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let nameLabel: NTLabel = {
        let label = NTLabel(type: .title)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        return label
    }()
    
    let applicationIDLabel: NTLabel = {
        let label = NTLabel(type: .content)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        return label
    }()
    
    let serverURLLabel: NTLabel = {
        let label = NTLabel(type: .content)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectionStyle = .none
        backgroundColor = Color(r: 30, g: 59, b: 77)
        
        addSubview(colorView)
        addSubview(iconImageView)
        addSubview(nameLabel)
        addSubview(applicationIDLabel)
        addSubview(serverURLLabel)
        
        colorView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 10, leftConstant: 12, bottomConstant: 10, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        iconImageView.anchor(colorView.topAnchor, left: colorView.leftAnchor, bottom: colorView.bottomAnchor, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 0, widthConstant: 64, heightConstant: 0)
        
        nameLabel.anchor(colorView.topAnchor, left: iconImageView.rightAnchor, bottom: nil, right: colorView.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        
        applicationIDLabel.anchor(nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nameLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        serverURLLabel.anchor(applicationIDLabel.bottomAnchor, left: applicationIDLabel.leftAnchor, bottom: nil, right: applicationIDLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            colorView.backgroundColor = Color(r: 21, g: 156, b: 238)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.colorView.backgroundColor = Color(r: 25, g: 48, b: 64)
            }
        }
    }
}

class ParseClassCell: UITableViewCell {
    
    var parseClass: ParseClass? {
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
        view.backgroundColor = Color(r: 14, g: 105, b: 160)
        view.layer.cornerRadius = 3
        return view
    }()
    
    let nameLabel: NTLabel = {
        let label = NTLabel(type: .title)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = Color(r: 21, g: 156, b: 238)
        
        addSubview(colorView)
        addSubview(nameLabel)
        
        colorView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 5, leftConstant: 12, bottomConstant: 5, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        nameLabel.anchor(colorView.topAnchor, left: colorView.leftAnchor, bottom: colorView.bottomAnchor, right: colorView.rightAnchor, topConstant: 5, leftConstant: 8, bottomConstant: 5, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HelpCell: UITableViewCell {
    
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
        label.textColor = Color.Defaults.tint
        label.font = Font.Defaults.subtitle
        return label
    }()
    
    let leftTextView: NTTextView = {
        let textView = NTTextView()
        textView.isEditable = false
        textView.textColor = Color.darkGray
        return textView
    }()
    
    let rightTextView: NTTextView = {
        let textView = NTTextView()
        textView.isEditable = false
        textView.textColor = Color.darkGray
        return textView
    }()
    
    // MARK: - Initalizers
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(leftTextView)
        contentView.addSubview(rightTextView)
        
        titleLabel.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: leftTextView.topAnchor, right: contentView.rightAnchor, topConstant: 8, leftConstant: 12, bottomConstant: 0, rightConstant: 2, widthConstant: 0, heightConstant: 0)
        leftTextView.anchor(titleLabel.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 7, bottomConstant: 0, rightConstant: 0, widthConstant: 85, heightConstant: 0)
        rightTextView.anchor(titleLabel.bottomAnchor, left: leftTextView.rightAnchor, bottom: contentView.bottomAnchor, right: titleLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ObjectColumnCell: UITableViewCell {
    
    var key: String? {
        didSet {
            keyLabel.text = self.key
        }
    }
    var value: AnyObject? {
        didSet {
            guard let value = self.value else { return }
            valueTextView.text = "\(value)"
        }
    }
    
    let keyLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.Defaults.tint
        label.font = Font.Defaults.subtitle
        return label
    }()
    
    let valueTextView: NTTextView = {
        let textView = NTTextView()
        textView.isEditable = false
        return textView
    }()
    
    // MARK: - Initalizers
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        contentView.addSubview(keyLabel)
        contentView.addSubview(valueTextView)
        
        keyLabel.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: valueTextView.topAnchor, right: contentView.rightAnchor, topConstant: 8, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        valueTextView.anchor(keyLabel.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 7, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ObjectPreviewCell: UITableViewCell {
    
    var object: ParseObject? {
        set {
            guard let object = newValue else { return }
            guard let keys = self.previewKeys else { return }
            if keys.count >= 1 {
                objectIdLabel.text = object.keys.index(of: keys[0]) != nil ? String(describing: object.values[object.keys.index(of: keys[0])!]) : "<null>"
                if keys.count >= 2 {
                    createdAtLabel.text = object.keys.index(of: keys[1]) != nil ? String(describing: object.values[object.keys.index(of: keys[1])!]) : "<null>"
                    if keys.count >= 3 {
                        updatedAtLabel.text = object.keys.index(of: keys[2]) != nil ? String(describing: object.values[object.keys.index(of: keys[2])!]) : "<null>"
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
        let label = NTLabel(type: .subtitle)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    let createdAtLabel: UILabel = {
        let label = NTLabel(type: .content)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    let updatedAtLabel: UILabel = {
        let label = NTLabel(type: .content)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initalizers
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = Color(r: 102, g: 99, b: 122)
        
        addSubview(colorView)
        addSubview(objectIdLabel)
        addSubview(createdAtLabel)
        addSubview(updatedAtLabel)
        
        colorView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 5, leftConstant: 12, bottomConstant: 5, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        objectIdLabel.anchor(colorView.topAnchor, left: colorView.leftAnchor, bottom: createdAtLabel.topAnchor, right: colorView.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        
        createdAtLabel.anchor(objectIdLabel.bottomAnchor, left: objectIdLabel.leftAnchor, bottom: updatedAtLabel.topAnchor, right: objectIdLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        updatedAtLabel.anchor(createdAtLabel.bottomAnchor, left: objectIdLabel.leftAnchor, bottom: colorView.bottomAnchor, right: objectIdLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            colorView.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.colorView.backgroundColor = .white
            }
        }
    }
}


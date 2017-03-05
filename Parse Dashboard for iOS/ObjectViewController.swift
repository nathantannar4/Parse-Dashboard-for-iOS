//
//  ObjectViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 3/1/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit
import NTComponents

class ObjectViewController: UITableViewController {
    
    var parseClass: ParseClass!
    var object: ParseObject!
    
    convenience init(_ object: ParseObject, parseClass: ParseClass) {
        self.init()
        self.object = object
        self.parseClass = parseClass
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleView(title: parseClass.name, subtitle: "Object")
        view.backgroundColor = Color(r: 114, g: 111, b: 133)
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 10
        tableView.backgroundColor = Color(r: 114, g: 111, b: 133)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(ObjectColumnCell.self, forCellReuseIdentifier: "ObjectColumnCell")
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshObject), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func refreshObject() {
        Parse.fetch(endpoint: "/classes/" + parseClass.name + "/" + object.id) { (json) in
            self.object = ParseObject(json)
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return object.keys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectColumnCell", for: indexPath)  as! ObjectColumnCell
        cell.key = object.keys[indexPath.row]
        cell.value = object.values[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        
        valueTextView.anchor(keyLabel.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 7, bottomConstant: 7, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

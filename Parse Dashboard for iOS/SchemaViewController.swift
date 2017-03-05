//
//  SchemaViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 2/28/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit
import NTComponents

class SchemaViewController: UITableViewController {
    
    var server: ParseServer?
    var schemas = [ParseClass]()
    
    convenience init(server: ParseServer) {
        self.init()
        self.server = server
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleView(title: server!.name!.isEmpty ? server?.applicationId : server?.name, subtitle: "Classes")
        view.backgroundColor = Color(r: 21, g: 156, b: 238)
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 10
        tableView.backgroundColor = Color(r: 21, g: 156, b: 238)
        tableView.separatorStyle = .none
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(loadSchemas), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        loadSchemas()
    }
    
    func loadSchemas() {
        schemas.removeAll()
        tableView.reloadSections([0], with: .automatic)
        tableView.refreshControl?.beginRefreshing()
        Parse.fetch(endpoint: "/schemas") { (json) in
            guard let results = json["results"] as? [[String: AnyObject]] else {
                Toast(text: "Unexpected Results, is your URL correct?").show(duration: 3.0)
                self.tableView.refreshControl?.endRefreshing()
                return
            }
            for result in results {
                
                var fields: [String: AnyObject]?
                var permissions: [String: AnyObject]?
                var name: String?
                for parseClass in result {
                    if parseClass.key == "fields" {
                        fields = parseClass.value as? [String: AnyObject]
                    } else if parseClass.key == "classLevelPermissions" {
                        permissions = parseClass.value as? [String: AnyObject]
                    } else if parseClass.key == "className" {
                        name = "\(parseClass.value)"
                    }
                }
                self.schemas.append(ParseClass(name: name, fields: fields, permissions: permissions))
            }
            DispatchQueue.main.async {
                self.tableView.reloadSections([0], with: .automatic)
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schemas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ParseClassCell()
        cell.parseClass = schemas[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ClassViewController(parseClass: schemas[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
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

//
//  SchemaDetailViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 3/5/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit
import NTComponents

class SchemaDetailViewController: UITableViewController {
    
    var parseClass: ParseClass!
    enum ViewStyle {
        case json, formatted
    }
    var viewStyle = ViewStyle.formatted
    
    convenience init(_ parseClass: ParseClass) {
        self.init()
        self.parseClass = parseClass
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleView(title: parseClass.name, subtitle: "Class")
        view.backgroundColor = Color(r: 14, g: 105, b: 160)
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 10
        tableView.backgroundColor = Color(r: 14, g: 105, b: 160)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        tableView.register(ObjectColumnCell.self, forCellReuseIdentifier: "ObjectColumnCell")
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Json"), style: .plain, target: self, action: #selector(toggleView(sender:))), UIBarButtonItem(image: UIImage(named: "Delete"), style: .plain, target: self, action: #selector(deleteClass))]
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshClass), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func refreshClass() {
        Parse.get(endpoint: "/schemas/" + parseClass.name!) { (json) in
            DispatchQueue.main.async {
                print(json)
                self.parseClass = ParseClass(json)
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    func deleteClass() {
        Parse.delete(endpoint: "/schemas/" + parseClass!.name!, completion: { (response, code, success) in
            DispatchQueue.main.async {
                Toast(text: response, color: Color(r: 30, g: 59, b: 77), height: 50).show(duration: 2.0)
                if success {
                    let _ = self.navigationController?.popViewController(animated: true)
                } else if code == 255 {
                    let alertController = UIAlertController(title: "Delete class and objects?", message: "This cannot be undone", preferredStyle: .alert)
                    alertController.view.tintColor = Color.Defaults.tint
                    
                    let saveAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                        alert -> Void in
                        Parse.get(endpoint: "/classes/" + self.parseClass!.name!) { (json) in
                            guard let results = json["results"] as? [[String: AnyObject]] else {
                                DispatchQueue.main.async {
                                    Toast(text: "Unexpected Results", color: Color(r: 114, g: 111, b: 133), height: 50).show(duration: 2.0)
                                }
                                return
                            }
                            for result in results {
                                Parse.delete(endpoint: "/classes/" + self.parseClass!.name! + "/" + (result["objectId"] as! String), completion: { (response, code, success) in
                                    if !success {
                                        DispatchQueue.main.async {
                                            Toast(text: response, color: Color(r: 114, g: 111, b: 133), height: 50).show()
                                        }
                                    }
                                })
                            }
                            self.deleteClass()
                        }
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    alertController.addAction(saveAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }
    
    func toggleView(sender: UIBarButtonItem) {
        switch viewStyle {
        case .json:
            sender.image = UIImage(named: "Json")
            viewStyle = .formatted
            tableView.reloadSections([0], with: .automatic)
        case .formatted:
            sender.image = UIImage(named: "Json_Filled")
            viewStyle = .json
            tableView.reloadSections([0], with: .automatic)
        }
    }
    
    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewStyle == .formatted {
            return 3
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectColumnCell", for: indexPath)  as! ObjectColumnCell
        
        if viewStyle == .formatted {
            switch indexPath.row {
            case 0:
                cell.key = "Permissions"
                cell.value = parseClass.permissions as AnyObject
            case 1:
                cell.key = "Classname"
                cell.value = parseClass.name as AnyObject
            case 2:
                cell.key = "Fields"
                cell.value = parseClass.fields as AnyObject
            default:
                break
            }
            return cell
        }
        
        cell.key = "JSON"
        cell.value = parseClass.json as AnyObject
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if viewStyle == .formatted {
            return false
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .default, title: " Edit ", handler: { action, indexpath in
            
            
        })
        editAction.backgroundColor = Color.Defaults.tint
       
        return [editAction]
    }
}

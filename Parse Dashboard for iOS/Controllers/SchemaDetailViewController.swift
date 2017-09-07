//
//  SchemaDetailViewController.swift
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

class SchemaDetailViewController: UITableViewController {
    
    // MARK: - Properties
    
    var schema: PFSchema
    enum ViewStyle {
        case json, formatted
    }
    var viewStyle = ViewStyle.formatted
    
    // MARK: - Initialization
    
    init(_ schma: PFSchema) {
        self.schema = schma
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
    }
    
    // MARK: Data Refresh
    
    func refreshClass() {
        
        Parse.get(endpoint: "/schemas/" + schema.name) { (json) in
            DispatchQueue.main.async {
                self.schema = PFSchema(json)
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.backgroundColor = .darkPurpleBackground
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        tableView.register(FieldCell.self, forCellReuseIdentifier: FieldCell.reuseIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshClass), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        
        setTitleView(title: schema.name, subtitle: "Schema")
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "Raw"),
                            style: .plain,
                            target: self,
                            action: #selector(toggleView(sender:))),
            UIBarButtonItem(image: UIImage(named: "Delete"),
                            style: .plain,
                            target: self,
                            action: #selector(deleteClass))
        ]
    }
    
    // MARK: - User Actions
    
    func deleteClass() {
        Parse.delete(endpoint: "/schemas/" + schema.name, completion: { (response, code, success) in
            DispatchQueue.main.async {
                NTToast(text: response, color: .darkPurpleAccent, height: 50).show(duration: 2.0)
                if success {
                    let _ = self.navigationController?.popViewController(animated: true)
                } else if code == 255 {
                    
                    let alertController = UIAlertController(title: "Delete class and objects?", message: "This cannot be undone", preferredStyle: .alert)
                    alertController.view.tintColor = Color.Default.Tint.View
                    
                    let saveAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                        alert -> Void in
                        Parse.get(endpoint: "/classes/" + self.schema.name) { (json) in
                            guard let results = json["results"] as? [[String: AnyObject]] else {
                                DispatchQueue.main.async {
                                    NTToast(text: "Unexpected Results", color: .darkPurpleAccent, height: 50).show(duration: 2.0)
                                }
                                return
                            }
                            for result in results {
                                Parse.delete(endpoint: "/classes/" + self.schema.name + "/" + (result["objectId"] as! String), completion: { (response, code, success) in
                                    if !success {
                                        DispatchQueue.main.async {
                                            NTToast(text: response, color: .darkPurpleAccent, height: 50).show()
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
            sender.image = UIImage(named: "Raw")
            viewStyle = .formatted
            tableView.reloadSections([0], with: .automatic)
        case .formatted:
            sender.image = UIImage(named: "Raw_Filled")
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FieldCell.reuseIdentifier, for: indexPath)  as? FieldCell else {
            return UITableViewCell()
        }
        
        if viewStyle == .formatted {
            switch indexPath.row {
            case 0:
                cell.key = "Permissions"
                cell.value = schema.permissions 
            case 1:
                cell.key = "Classname"
                cell.value = schema.name 
            case 2:
                cell.key = "Fields"
                cell.value = schema.fields 
            default:
                break
            }
            return cell
        }
        
        cell.key = "JSON"
        cell.value = schema.json 
        return cell
    }
}

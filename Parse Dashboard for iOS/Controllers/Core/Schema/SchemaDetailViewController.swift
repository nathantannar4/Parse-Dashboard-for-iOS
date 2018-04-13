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

class SchemaDetailViewController: PFTableViewController {
    
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
        
        configure()
        setupTableView()
        setupNavigationBar()
    }
    
    // MARK: Data Refresh
    
    @objc
    func refreshClass() {
        
        ParseLite.shared.get("/schemas/" + schema.name) { [weak self] (result, json) in
            guard result.success, let json = json else {
                self?.handleError(result.error)
                self?.tableView.refreshControl?.endRefreshing()
                return
            }
            self?.schema = PFSchema(json)
            self?.tableView.reloadData()
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.backgroundColor = .lightBlueBackground
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        tableView.register(FieldCell.self, forCellReuseIdentifier: FieldCell.reuseIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshClass), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        
        title = "Class Details"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "Raw"),
                            style: .plain,
                            target: self,
                            action: #selector(toggleView(sender:))),
            UIBarButtonItem(image: UIImage(named: Localizable.delete.localized),
                            style: .plain,
                            target: self,
                            action: #selector(deleteSchema))
        ]
    }
    
    // MARK: - User Actions
    
    @objc
    func deleteSchema() {
        
        ParseLite.shared.delete("/schemas/" + schema.name) { [weak self] (result, json) in
            if result.success {
                self?.handleSuccess("Class Deleted")
                 _ = self?.navigationController?.popViewController(animated: true)
            } else {
                if let code = json?["code"] as? Int, code == 255 {
                    self?.deleteAllObjectsInSchema()
                } else {
                    self?.handleError(result.error)
                }
            }
        }
    }
    
    func deleteAllObjectsInSchema() {
        
        let alert = UIAlertController(title: "Warning: Class contains objects", message: "Delete ALL objects and class?", preferredStyle: .alert)
        alert.configureView()
        
        let deleteAction = UIAlertAction(title: Localizable.delete.localized, style: .destructive, handler: { [weak self] _ in
            
            guard let classname = self?.schema.name else { return }
            self?.handleSuccess("Deleting objects in class \(classname)")
            ParseLite.shared.get("/classes/" + classname, completion: { [weak self] (result, json) in
                
                guard result.success, let results = json?["results"] as? [[String: AnyObject]] else {
                    self?.handleError(result.error)
                    return
                }
                for result in results {
                    if let id = result["objectId"] as? String {
                        ParseLite.shared.delete("/classes/\(classname)/\(id)", completion: { _,_  in })
                    }
                }
                self?.deleteSchema() // Retry to delete the schema
            })
        })
        
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: Localizable.cancel.localized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc
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
        return viewStyle == .formatted ? 3 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FieldCell.reuseIdentifier, for: indexPath) as! FieldCell
        
        if viewStyle == .formatted {
            switch indexPath.row {
            case 0:
                cell.key = "Classname"
                cell.value = schema.name
            case 1:
                cell.key = "Permissions"
                cell.value = schema.json?.dictionaryValue["classLevelPermissions"]
            case 2:
                cell.key = "Fields"
                cell.value = schema.json?.dictionaryValue["fields"]
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

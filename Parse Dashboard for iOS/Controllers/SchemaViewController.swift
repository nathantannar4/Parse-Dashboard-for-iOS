//
//  SchemaViewController.swift
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

class SchemaViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var server: ParseServerConfig
    private var schemas = [PFSchema]()
    
    // MARK: - Initialization
    
    init(_ config: ParseServerConfig) {
        server = config
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
        loadSchemas()
    }
    
    // MARK: - Data Refresh
    
    @objc func loadSchemas() {
        
        if !schemas.isEmpty {
            schemas.removeAll()
            tableView.deleteSections([0], with: .none)
        }
        
        Parse.get(endpoint: "/schemas") { (json) in
            guard let results = json["results"] as? [[String: AnyObject]] else {
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    NTToast(text: "Unexpected Results, is your URL correct?", color: .lightBlueAccent, height: 50).show(duration: 3.0)
                }
                return
            }
            self.schemas = results.map { return PFSchema($0) }
            if !self.schemas.isEmpty {
                DispatchQueue.main.async {
                    self.tableView.insertSections([0], with: .top)
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.backgroundColor = .lightBlueBackground
        tableView.separatorStyle = .none
        tableView.register(ClassCell.self, forCellReuseIdentifier: ClassCell.reuseIdentifier)
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(self.loadSchemas), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        
        setTitleView(title: server.name!.isEmpty ? server.applicationId : server.name, subtitle: "Classes")
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(addSchema)),
            UIBarButtonItem(image: UIImage(named: "Info"),
                            style: .plain,
                            target: self,
                            action: #selector(showServerInfo))
        ]
    }
    
    @objc func showServerInfo() {
        
        Parse.get(endpoint: "/serverInfo/") { (info) in

            DispatchQueue.main.async {
                let server = PFServer(info) 
                let viewController = ServerDetailViewController(server)
                viewController.title = self.title
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    // MARK: - User Actions
    
    @objc func addSchema() {
        let alertController = UIAlertController(title: "Create Class", message: nil, preferredStyle: .alert)
        alertController.view.tintColor = Color.Default.Tint.View
        
        let saveAction = UIAlertAction(title: "Create", style: .default, handler: {
            alert -> Void in
            
            guard let schemaClassname = alertController.textFields![0].text else { return }
            Parse.post(endpoint: "/schemas/" + schemaClassname, completion: { (response, json, success) in
                DispatchQueue.main.async {
                    NTToast(text: response, color: .darkBlueBackground, height: 50).show(duration: 2.0)
                    if success {
                        let schema = PFSchema(json)
                        DispatchQueue.main.async {
                            self.schemas.insert(schema, at: 0)
                            if self.schemas.count == 1 {
                                self.tableView.insertSections([0], with: .top)
                            } else {
                                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                            }
                        }
                    }
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.addTextField { $0.placeholder = "Classname" }
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return schemas.count > 0 ? 1 : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schemas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ClassCell.reuseIdentifier, for: indexPath) as! ClassCell
        cell.schema = schemas[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController = ClassViewController(schemas[indexPath.row])
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let detailAction = UITableViewRowAction(style: .default, title: "Details", handler: { action, indexpath in
            let viewController = SchemaDetailViewController(self.schemas[indexPath.row])
            self.navigationController?.pushViewController(viewController, animated: true)
        })
        detailAction.backgroundColor = .lightBlueAccent
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { action, indexpath in
            
            self.tableView.setEditing(false, animated: true)
            
            let alertController = UIAlertController(title: "Are you sure?", message: "This cannot be undone", preferredStyle: .alert)
            let actions = [
                UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    
                    let classname = self.schemas[indexPath.row].name
                    Parse.delete(endpoint: "/schemas/" + classname, completion: { (response, code, success) in
                        DispatchQueue.main.async {
                            NTToast(text: response, color: .darkBlueBackground, height: 50).show(duration: 2.0)
                            if success {
                                self.schemas.remove(at: indexPath.row)
                                self.tableView.deleteRows(at: [indexPath], with: .top)
                            } else if code == 255 {
                                let alertController = UIAlertController(title: "Delete class and objects?", message: "This cannot be undone", preferredStyle: .alert)
                                alertController.view.tintColor = Color.Default.Tint.View
                                
                                let saveAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                                    alert -> Void in
                                    Parse.get(endpoint: "/classes/" + self.schemas[indexPath.row].name) { (json) in
                                        guard let results = json["results"] as? [[String: AnyObject]] else {
                                            DispatchQueue.main.async {
                                                NTToast(text: "Unexpected Results", color: .darkPurpleAccent, height: 50).show(duration: 2.0)
                                            }
                                            return
                                        }
                                        for result in results {
                                            Parse.delete(endpoint: "/classes/" + self.schemas[indexPath.row].name + "/" + (result["objectId"] as! String), completion: { (response, code, success) in
                                                if !success {
                                                    DispatchQueue.main.async {
                                                        NTToast(text: response, color: .darkPurpleAccent, height: 50).show()
                                                    }
                                                }
                                            })
                                        }
                                        Parse.delete(endpoint: "/schemas/" + classname, completion: { (response, code, success) in
                                            DispatchQueue.main.async {
                                                NTToast(text: response, color: .darkBlueBackground, height: 50).show(duration: 2.0)
                                                if success {
                                                    self.schemas.remove(at: indexPath.row)
                                                    self.tableView.deleteRows(at: [indexPath], with: .top)
                                                }
                                            }
                                        })
                                    }
                                })
                                
                                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                                alertController.addAction(cancelAction)
                                alertController.addAction(saveAction)
                                
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    })
                    
                }),
                UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
                ]
            actions.forEach { alertController.addAction($0) }
            self.present(alertController, animated: true, completion: nil)
        })
        deleteAction.backgroundColor = Color.Default.Status.Danger
        
        return [deleteAction, detailAction]
    }
}


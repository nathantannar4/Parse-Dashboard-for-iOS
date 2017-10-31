//
//  ClassViewController.swift
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

class ClassViewController: UITableViewController, QueryDelegate {
    
    // MARK: - Properties
    
    var query = "limit=1000&order=-updatedAt"
    
    private var schema: PFSchema
    private var objects = [PFObject]()
    private var previewKeys = ["objectId", "createdAt", "updatedAt"]
    
    // MARK: - Initialization
    
    init(_ schma: PFSchema) {
        schema = schma
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
        setupToolbar()
        loadObjects()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isToolbarHidden = true
    }
    
    // MARK: - Data Refresh
    
    @objc func loadObjects() {
      
        if !objects.isEmpty {
            objects.removeAll()
            tableView.deleteSections([0], with: .none)
        }
        
        Parse.get(endpoint: "/classes/" + schema.name, query: "?" + query) { (json) in
            
            guard let results = json["results"] as? [[String: AnyObject]] else {
                DispatchQueue.main.async {
                    self.setTitleView(title: self.schema.name, subtitle: "0 Objects")
                    self.tableView.refreshControl?.endRefreshing()
                }
                return
            }
            self.objects = results.map { return PFObject($0, self.schema) }
            if !self.objects.isEmpty {
                DispatchQueue.main.async {
                    self.tableView.insertSections([0], with: .top)
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
            DispatchQueue.executeAfter(0.5, closure: {
                self.setTitleView(title: self.schema.name, subtitle: String(results.count) + " Objects")
            })
        }
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.backgroundColor = .darkPurpleBackground
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ObjectCell.self, forCellReuseIdentifier: ObjectCell.reuseIdentifier)
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(ClassViewController.loadObjects), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        
        title = schema.name
        setTitleView(title: schema.name)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icon.Delete?.scale(to: 30), style: .plain, target: self, action: #selector(ClassViewController.close))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(ClassViewController.addObject)),
            UIBarButtonItem(image: UIImage(named: "Filter"),
                            style: .plain,
                            target: self,
                            action: #selector(ClassViewController.modifyQuery(sender:)))
        ]
    }
    
    private func setupToolbar() {
        
        if schema.name == "_Installation" {
            
            navigationController?.toolbar.barTintColor = .darkPurpleAccent
            navigationController?.toolbar.tintColor = .white
            var items = [UIBarButtonItem]()
            items.append(
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            )
            let pushItem: UIBarButtonItem = {
                let containView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
                label.text = "Send Push Notification"
                label.textColor = .white
                label.font = Font.Default.Body
                label.textAlignment = .right
                containView.addSubview(label)
                let imageview = UIImageView(frame: CGRect(x: 150, y: 5, width: 50, height: 30))
                imageview.image = UIImage(named: "Push")
                imageview.contentMode = .scaleAspectFit
                containView.addSubview(imageview)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ClassViewController.sendPushNotification))
                containView.addGestureRecognizer(tapGesture)
                return UIBarButtonItem(customView: containView)
            }()
            items.append(pushItem)
            setToolbarItems(items, animated: true)
            navigationController?.isToolbarHidden = false
        }
    }
    
    // MARK: - User Actions
    
    @objc func close() {
        controllerContainer?.removeViewController(navigationController ?? self, animated: true)
    }
    
    @objc func addObject() {
        let alertController = UIAlertController(title: "Create Object", message: nil, preferredStyle: .alert)
        alertController.view.tintColor = Color.Default.Tint.View
        
        let saveAction = UIAlertAction(title: "Create", style: .default, handler: {
            alert -> Void in
            
            let body = alertController.textFields?[0].text
            Parse.post(endpoint: "/classes/" + self.schema.name, body: body, completion: { (response, json, success) in
                DispatchQueue.main.async {
                    NTToast(text: response, color: .darkPurpleAccent, height: 50).show(duration: 2.0)
                    if success {
                        print(json)
                        let object = PFObject(json, self.schema)
                        self.objects.insert(object, at: 0)
                        self.setTitleView(title: self.schema.name, subtitle: String(self.objects.count) + " Objects")
                        if self.objects.count == 1 {
                            self.tableView.insertSections([0], with: .top)
                        } else {
                            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                        }
                    }
                }
            })
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.addTextField { $0.placeholder = "POST Body" }
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func sendPushNotification() {
        let alertController = UIAlertController(title: "Push Notification", message: "To current query results", preferredStyle: .alert)
        alertController.view.tintColor = Color.Default.Tint.View
        
        let saveAction = UIAlertAction(title: "Send", style: .default, handler: {
            alert -> Void in
            
            let message = alertController.textFields![0].text!
            
            let userIds = self.objects.map({ (object) -> String in
                guard let userID = object.json["user"].dictionary?["objectId"]?.stringValue else {
                    return String()
                }
                return userID
            })
            
            // Example: where={"user":{"$inQuery":{"className":"_User","where":{"objectId":{"$in":["zaAqYBP8X9"]}}}}}
            let body = "{\"where\":{\"user\":{\"$inQuery\":{\"className\":\"_User\",\"where\":{\"objectId\":{\"$in\":\(userIds)}}}}},\"data\":{\"title\":\"Message from Server\",\"alert\":\"\(message)\"}}"
            print(body)
            Parse.post(endpoint: "/push", body: body) { (response, json, success) in
                DispatchQueue.main.async {
                    NTToast(text: response, color: .darkPurpleAccent, height: 44).show(duration: 2.0)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.addTextField { $0.placeholder = "Message" }
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func modifyQuery(sender: AnyObject) {
        
        let queryVC = QueryViewController(schema, selectedKeys: previewKeys, query: query)
        queryVC.delegate = self
        
        let navVC = NTNavigationController(rootViewController: queryVC)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navVC.modalPresentationStyle = .popover
            navVC.popoverPresentationController?.permittedArrowDirections = .up
            navVC.popoverPresentationController?.delegate = self
            navVC.popoverPresentationController?.sourceView = navigationItem.titleView
            navVC.popoverPresentationController?.sourceRect = navigationItem.titleView!.bounds
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            navVC.modalPresentationStyle = .formSheet
        }
        present(navVC, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return objects.count > 0 ? 1 : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ObjectCell.reuseIdentifier, for: indexPath) as! ObjectCell
        cell.previewKeys = previewKeys
        cell.object = objects[indexPath.row]
        cell.backgroundColor = ((indexPath.row % 2) == 0) ? .darkPurpleBackground : .darkPurpleAccent
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController = ObjectViewController(objects[indexPath.row])
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexpath in
            
            let alertController = UIAlertController(title: "Are you sure?", message: "This cannot be undone", preferredStyle: .alert)
            let actions = [
                UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    
                    Parse.delete(endpoint: "/classes/" + self.schema.name + "/" + self.objects[indexPath.row].id, completion: { (response, code, success) in
                        DispatchQueue.main.async {
                            NTToast(text: response, color: .darkPurpleAccent, height: 50).show(duration: 2.0)
                            if success {
                                self.objects.remove(at: indexPath.row)
                                self.setTitleView(title: self.schema.name, subtitle: String(self.objects.count) + " Objects")
                                self.tableView.deleteRows(at: [indexPath], with: .top)
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
        
        return [deleteAction]
    }
    
    // MARK: - QueryDelegate
    
    func query(didChangeWith query: String, previewKeys: [String]) {
        if self.query != query {
            self.query = query
            self.previewKeys = previewKeys
            loadObjects()
        } else {
            self.previewKeys = previewKeys
            tableView.reloadData()
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ClassViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

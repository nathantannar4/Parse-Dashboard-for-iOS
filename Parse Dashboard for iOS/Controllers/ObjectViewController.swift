//
//  ObjectViewController.swift
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

class ObjectViewController: UITableViewController {
    
    // MARK: - Properties
    
    enum ViewStyle {
        case json, formatted
    }
    
    private var object: PFObject
    private var viewStyle = ViewStyle.formatted
    
    // MARK: - Initialization
    
    init(_ obj: PFObject) {
        object = obj
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    // MARK: - Object Refresh
    
    func refreshObject() {
        
        if tableView.refreshControl?.isRefreshing == true {
            self.tableView.refreshControl?.endRefreshing()
            return
        }
        
        Parse.get(endpoint: "/classes/" + object.schema.name! + "/" + object.id) { (json) in
            self.tableView.refreshControl?.endRefreshing()
            DispatchQueue.main.async {
                self.object = PFObject(json, self.object.schema)
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = (object.schema.name == "_User") ? 0 : 10
        tableView.backgroundColor = .darkPurpleAccent
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(FieldCell.self, forCellReuseIdentifier: FieldCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(ObjectViewController.refreshObject), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        
        setTitleView(title: object.schema.name, subtitle: "Object")
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "Json"),
                            style: .plain,
                            target: self,
                            action: #selector(ObjectViewController.toggleView(sender:))),
            UIBarButtonItem(image: UIImage(named: "Delete"),
                            style: .plain,
                            target: self,
                            action: #selector(ObjectViewController.deleteObject))
        ]
    }
    
    private func setupToolbar() {
        
        if object.schema.name == "_User" {
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
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ObjectViewController.sendPushNotification))
                containView.addGestureRecognizer(tapGesture)
                return UIBarButtonItem(customView: containView)
            }()
            items.append(pushItem)
            toolbarItems = items
            navigationController?.isToolbarHidden = false
        }
    }
   
    // MARK: - User Actions
    
    func deleteObject() {
        
        let alertController = UIAlertController(title: "Are you sure?", message: "This cannot be undone", preferredStyle: .alert)
        let actions = [
            UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                
                Parse.delete(endpoint: "/classes/" + self.object.schema.name! + "/" + self.object.id) { (response, code, success) in
                    DispatchQueue.main.async {
                        NTToast(text: response, color: .darkPurpleAccent, height: 50).show(duration: 2.0)
                        if success {
                            let _ = self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                
            }),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
            ]
        actions.forEach { alertController.addAction($0) }
        self.present(alertController, animated: true, completion: nil)
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
    
    func sendPushNotification() {
        let alertController = UIAlertController(title: "Push Notification", message: "To " + (object.json["username"] as! String), preferredStyle: .alert)
        alertController.view.tintColor = Color.Default.Tint.View
        
        let saveAction = UIAlertAction(title: "Send", style: .default, handler: {
            alert -> Void in
            
            let message = alertController.textFields![0].text!
            let body = "{\"where\":{\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"\(self.object.id)\"}},\"data\":{\"title\":\"Message from Server\",\"alert\":\"\(message)\"}}"
            Parse.post(endpoint: "/push", body: body) { (response, json, success) in
                DispatchQueue.main.async {
                    NTToast(text: response, color: .darkPurpleBackground, height: 44).show(duration: 2.0)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.addTextField { $0.placeholder = "Message" }
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewStyle == .formatted {
            return object.keys.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FieldCell.reuseIdentifier, for: indexPath) as! FieldCell
        let key = object.keys[indexPath.row]
        cell.key = key
        
        if viewStyle == .formatted {
            
            let value = object.values[indexPath.row]
            
            if let type = self.object.schema.typeForField(key) {
                if type == "File", let dict = value as? [String : AnyObject] {
                    // File Type
                    cell.value = dict["name"]
                    cell.valueTextView.isUserInteractionEnabled = false
                    cell.selectionStyle = .default
                    return cell
                } else if type == "Pointer", let dict = value as? [String : AnyObject] {
                    // Pointer
                    let stringValue = String(describing: dict).replacingOccurrences(of: "[", with: " ").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: ",", with: "\n")
                    cell.value = stringValue as AnyObject
                    cell.valueTextView.layer.cornerRadius = 3
                    cell.valueTextView.layer.backgroundColor = UIColor(r: 102, g: 99, b: 122).cgColor
                    cell.valueTextView.textColor = .white
                    cell.valueTextView.isUserInteractionEnabled = false
                    return cell
                } else if type == "Boolean", let booleanValue = value as? Bool {
                    // Boolean
                    cell.value = (booleanValue ? "True" : "False") as AnyObject
                    return cell
                } else if type == "String" {
                    cell.value = value
                    return cell
                    
                } else if type == "Array" {
                    if let array = value as? [String] {
                        cell.value = String(describing: array) as AnyObject
                        return cell
                    }
                } else if type == "Date", let stringValue = value as? String {
                    // Date Data Type
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    if let date = dateFormatter.date(from: stringValue) {
                        cell.value = date.string(dateStyle: .full, timeStyle: .full) as AnyObject
                        return cell
                    }
                }
            }
            cell.value = value
            return cell
        }
        cell.key = "JSON"
        cell.value = object.json as AnyObject
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if viewStyle == .formatted {
            let value = object.values[indexPath.row]
            if let dict = value as? [String : AnyObject] {
                if let type = dict["__type"] as? String {
                    if type == "File" {
                        let url = dict["url"] as! String
                        let name = dict["name"] as! String
                        let imageVC = FileViewController(url, _filename: name, _schema: self.object.schema, _key: object.keys[indexPath.row], _objectId: object.id)
                        let navVC = NTNavigationController(rootViewController: imageVC)
                        navVC.modalTransitionStyle = .crossDissolve
                        present(navVC, animated: true, completion: nil)
                    }
                    if type == "Pointer" {
                        guard let cell = tableView.cellForRow(at: indexPath) as? FieldCell else {
                            return
                        }
                        cell.valueTextView.layer.backgroundColor = UIColor.darkPurpleAccent.cgColor
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            cell.valueTextView.layer.backgroundColor = UIColor.darkPurpleBackground.cgColor
                        }
                        guard let className = dict["className"] as? String, let objectId = dict["objectId"] as? String else {
                            NTToast.genericErrorMessage()
                            return
                        }
                        Parse.get(endpoint: "/classes/" + className + "/" + objectId, completion: { (objectJson) in
                            Parse.get(endpoint: "/schemas/" + className, completion: { (classJson) in
                                DispatchQueue.main.async {
                                    let schema = PFSchema(classJson)
                                    let object = PFObject(objectJson, schema)
                                    let vc = ObjectViewController(object)
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            })
                        })
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if viewStyle == .formatted {
            if object.keys[indexPath.row] == .objectId ||
                object.keys[indexPath.row] == .createdAt ||
                object.keys[indexPath.row] ==  .updatedAt ||
                object.keys[indexPath.row] == .acl {
                return false
            }
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .default, title: " Edit ", handler: { action, indexpath in
            self.tableView.setEditing(false, animated: true)
            
            let value = self.object.values[indexPath.row]
            let key = self.object.keys[indexPath.row]
            guard let type = self.object.schema.typeForField(key) else { return }
            
            if type == "File" {
                if let dict = value as? [String : AnyObject] {
                    if let type = dict["__type"] as? String {
                        if type == "File" {
                            let url = dict["url"] as! String
                            let name = dict["name"] as! String
                            let imageVC = FileViewController(url, _filename: name, _schema: self.object.schema, _key: key, _objectId: self.object.id)
                            let navVC = NTNavigationController(rootViewController: imageVC)
                            navVC.modalTransitionStyle = .crossDissolve
                            self.present(navVC, animated: true, completion: {
                                imageVC.presentImagePicker()
                            })
                        }
                    }
                } else {
                    let imageVC = FileViewController(String(), _filename: String(), _schema: self.object.schema, _key: key, _objectId: self.object.id)
                    let navVC = NTNavigationController(rootViewController: imageVC)
                    self.present(navVC, animated: true, completion: {
                        imageVC.presentImagePicker()
                    })
                }
            } else if type == "String" {
                let alertController = UIAlertController(title: key, message: type, preferredStyle: .alert)
                alertController.view.tintColor = Color.Default.Tint.View
                
                let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
                    alert -> Void in
                    
                    guard let newValue = alertController.textFields![0].text else { return }
                    let body = "{\"" + key + "\":\"" + newValue + "\"}"
                    Parse.put(endpoint: "/classes/" + self.object.schema.name! + "/" + self.object.id, body: body, completion: { (response, json, success) in
                        DispatchQueue.main.async {
                            NTToast(text: response, color: .darkPurpleBackground, height: 44).show(duration: 2.0)
                            if success {
                                self.object.values[indexPath.row] = newValue as AnyObject
                                self.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }
                    })
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                alertController.addAction(cancelAction)
                alertController.addAction(saveAction)
                
                alertController.addTextField { (textField : UITextField!) -> Void in
                    textField.placeholder = value as? String
                    textField.text = value as? String
                }
                
                self.present(alertController, animated: true, completion: nil)
            } else if type == "Number" {
                let alertController = UIAlertController(title: key, message: type, preferredStyle: .alert)
                alertController.view.tintColor = Color.Default.Tint.View
                
                let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
                    alert -> Void in
                    
                    guard let newValue = alertController.textFields![0].text else { return }
                    let body = "{\"" + key + "\":" + newValue + "}"
                    Parse.put(endpoint: "/classes/" + self.object.schema.name! + "/" + self.object.id, body: body, completion: { (response, json, success) in
                        
                        DispatchQueue.main.async {
                            NTToast(text: response, color: .darkPurpleBackground, height: 44).show(duration: 2.0)
                            if success {
                                
                                self.object.values[indexPath.row] = newValue as AnyObject
                                self.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }
                    })
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                alertController.addAction(cancelAction)
                alertController.addAction(saveAction)
                
                alertController.addTextField {
                    $0.text = value as? String
                    $0.placeholder = value as? String
                    $0.keyboardType = .numberPad
                }
                
                self.present(alertController, animated: true, completion: nil)
                
            } else if type == "Date" {
                
            } else if type == "Boolean" {
                
                let alertController = UIAlertController(title: key, message: type, preferredStyle: .alert)
                alertController.view.tintColor = Color.Default.Tint.View
                
                let trueAction = UIAlertAction(title: "True", style: .default, handler: {
                    alert -> Void in
                    
                    let body = "{\"" + key + "\":" + "true" + "}"
                    Parse.put(endpoint: "/classes/" + self.object.schema.name! + "/" + self.object.id, body: body, completion: { (response, json, success) in
                        
                        DispatchQueue.main.async {
                            NTToast(text: response, color: .darkPurpleBackground, height: 44).show(duration: 2.0)
                            if success {
                                
                                self.object.values[indexPath.row] = true as AnyObject
                                self.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }
                    })
                })
                
                let falseAction = UIAlertAction(title: "False", style: .default, handler: {
                    alert -> Void in
                    
                    let body = "{\"" + key + "\":" + "false" + "}"
                    Parse.put(endpoint: "/classes/" + self.object.schema.name! + "/" + self.object.id, body: body, completion: { (response, json, success) in
                        
                        DispatchQueue.main.async {
                            NTToast(text: response, color: .darkPurpleBackground, height: 44).show(duration: 2.0)
                            if success {
                                
                                self.object.values[indexPath.row] = false as AnyObject
                                self.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }
                    })
                })
                
                alertController.addAction(falseAction)
                alertController.addAction(trueAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        })
        editAction.backgroundColor = .darkPurpleAccent
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexpath in
            let body = "{\"" + self.object.keys[indexPath.row] + "\":null}"
            Parse.put(endpoint: "/classes/" + self.object.schema.name! + "/" + self.object.id, body: body, completion: { (response, json, success) in
                DispatchQueue.main.async {
                    NTToast(text: response, color: .darkPurpleBackground, height: 44).show(duration: 2.0)
                    if success {
                        self.object.updatedAt = json[.updatedAt] as! String
                        let index = self.object.keys.index(of: .updatedAt)!
                        self.object.values[index] = json[.updatedAt]!
                        self.object.values[indexPath.row] = String.undefined as AnyObject
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0), indexPath], with: .none)
                    }
                }
            })
        })
        
        return [deleteAction, editAction]
    }
}

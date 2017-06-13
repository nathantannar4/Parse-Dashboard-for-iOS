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
    enum ViewStyle {
        case json, formatted
    }
    var viewStyle = ViewStyle.formatted
    
    convenience init(_ object: ParseObject, parseClass: ParseClass) {
        self.init()
        self.object = object
        self.parseClass = parseClass
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleView(title: parseClass.name, subtitle: "Object")
        view.backgroundColor = UIColor(r: 114, g: 111, b: 133)
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = (parseClass.name! == "_User") ? 0 : 10
        tableView.backgroundColor = UIColor(r: 114, g: 111, b: 133)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(ObjectColumnCell.self, forCellReuseIdentifier: "ObjectColumnCell")
        tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Json"), style: .plain, target: self, action: #selector(toggleView(sender:))), UIBarButtonItem(image: UIImage(named: "Delete"), style: .plain, target: self, action: #selector(deleteObject))]
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshObject), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        if parseClass.name! == "_User" {
            
            navigationController?.toolbar.barTintColor = UIColor(r: 114, g: 111, b: 133)
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
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sendPushNotification))
                containView.addGestureRecognizer(tapGesture)
                return UIBarButtonItem(customView: containView)
            }()
            items.append(pushItem)
            toolbarItems = items
            navigationController?.isToolbarHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isToolbarHidden = true
    }
    
    func refreshObject() {
        Parse.get(endpoint: "/classes/" + parseClass.name! + "/" + object.id) { (json) in
            DispatchQueue.main.async {
                self.object = ParseObject(json)
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    func deleteObject() {
        let alert = NTAlertViewController(title: "Are you sure?", subtitle: "This cannot be undone", type: .isDanger)
        alert.onConfirm = {
            Parse.delete(endpoint: "/classes/" + self.parseClass!.name! + "/" + self.object.id) { (response, code, success) in
                DispatchQueue.main.async {
                    NTToast(text: response, color: UIColor(r: 114, g: 111, b: 133), height: 50).show(duration: 2.0)
                    if success {
                        let _ = self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        alert.show(self, sender: nil)
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
                    NTToast(text: response, color: UIColor(r: 102, g: 99, b: 122), height: 44).show(duration: 2.0)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Message"
        }
        
        present(alertController, animated: true, completion: nil)
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
            return object.keys.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectColumnCell", for: indexPath) as! ObjectColumnCell
        let key = object.keys[indexPath.row]
        cell.key = key
        
        if viewStyle == .formatted {
            
            let value = object.values[indexPath.row]

            if let type = self.parseClass.typeForField(key) {
                if type == "File", let dict = value as? [String : AnyObject] {
                    // File Type
                    let imageFileCell = ObjectColumnCell()
                    imageFileCell.key = object.keys[indexPath.row]
                    imageFileCell.value = dict["name"]
                    imageFileCell.valueTextView.isUserInteractionEnabled = false
                    imageFileCell.selectionStyle = .default
                    return imageFileCell
                } else if type == "Pointer", let dict = value as? [String : AnyObject] {
                    // Pointer
                    let pointerCell = ObjectColumnCell()
                    pointerCell.key = object.keys[indexPath.row]
                    let stringValue = String(describing: dict).replacingOccurrences(of: "[", with: " ").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: ",", with: "\n")
                    pointerCell.value = stringValue as AnyObject
                    pointerCell.valueTextView.layer.cornerRadius = 3
                    pointerCell.valueTextView.layer.backgroundColor = UIColor(r: 102, g: 99, b: 122).cgColor
                    pointerCell.valueTextView.textColor = .white
                    pointerCell.valueTextView.isUserInteractionEnabled = false
                    return pointerCell
                } else if type == "Boolean", let booleanValue = value as? Bool {
                    // Boolean Data Type
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
                        let imageVC = ImageViewController(url, filename: name, parseClass: self.parseClass, key: object.keys[indexPath.row], objectId: object.id)
                        let navVC = NTNavigationController(rootViewController: imageVC)
                        navVC.modalPresentationStyle = .custom
                        let delegate = NTSwipeableTransitioningDelegate(fromViewController: self, toViewController: navVC)
                        navVC.transitioningDelegate = delegate
                        navVC.view.layer.cornerRadius = 12
                        navVC.view.clipsToBounds = true
                        present(navVC, animated: true, completion: nil)
                    }
                    if type == "Pointer" {
                        let cell = tableView.cellForRow(at: indexPath) as! ObjectColumnCell
                        cell.valueTextView.layer.backgroundColor = UIColor(r: 114, g: 111, b: 133).cgColor
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            cell.valueTextView.layer.backgroundColor = UIColor(r: 102, g: 99, b: 122).cgColor
                        }
                        guard let className = dict["className"] as? String, let objectId = dict["objectId"] as? String else {
                            NTToast.genericErrorMessage()
                            return
                        }
                        Parse.get(endpoint: "/classes/" + className + "/" + objectId, completion: { (objectJson) in
                            Parse.get(endpoint: "/schemas/" + className, completion: { (classJson) in
                                DispatchQueue.main.async {
                                    let object = ParseObject(objectJson)
                                    let parseClass = ParseClass(classJson)
                                    let vc = ObjectViewController(object, parseClass: parseClass)
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
            if object.keys[indexPath.row] == "objectId" || object.keys[indexPath.row] == "createdAt" || object.keys[indexPath.row] ==  "updatedAt" || object.keys[indexPath.row] == "ACL" {
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
            guard let type = self.parseClass.typeForField(key) else { return }
            
            if type == "File" {
                if let dict = value as? [String : AnyObject] {
                    if let type = dict["__type"] as? String {
                        if type == "File" {
                            let url = dict["url"] as! String
                            let name = dict["name"] as! String
                            let imageVC = ImageViewController(url, filename: name, parseClass: self.parseClass, key: key, objectId: self.object.id)
                            let navVC = NTNavigationController(rootViewController: imageVC)
                            navVC.modalPresentationStyle = .custom
                            let delegate = NTSwipeableTransitioningDelegate(fromViewController: self, toViewController: navVC)
                            navVC.transitioningDelegate = delegate
                            navVC.view.layer.cornerRadius = 12
                            navVC.view.clipsToBounds = true
                            self.present(navVC, animated: true, completion: {
                                imageVC.presentImagePicker()
                            })
                        }
                    }
                } else {
                    let imageVC = ImageViewController(String(), filename: String(), parseClass: self.parseClass, key: key, objectId: self.object.id)
                    let navVC = NTNavigationController(rootViewController: imageVC)
                    navVC.modalPresentationStyle = .custom
                    let delegate = NTSwipeableTransitioningDelegate(fromViewController: self, toViewController: navVC)
                    navVC.transitioningDelegate = delegate
                    navVC.view.layer.cornerRadius = 12
                    navVC.view.clipsToBounds = true
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
                    Parse.put(endpoint: "/classes/" + self.parseClass!.name! + "/" + self.object.id, body: body, completion: { (response, json, success) in
                        DispatchQueue.main.async {
                            NTToast(text: response, color: UIColor(r: 102, g: 99, b: 122), height: 44).show(duration: 2.0)
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
                    Parse.put(endpoint: "/classes/" + self.parseClass!.name! + "/" + self.object.id, body: body, completion: { (response, json, success) in
                        
                        DispatchQueue.main.async {
                            NTToast(text: response, color: UIColor(r: 102, g: 99, b: 122), height: 44).show(duration: 2.0)
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
                    textField.text = value as? String
                    textField.placeholder = value as? String
                    textField.keyboardType = .numberPad
                }
                
                self.present(alertController, animated: true, completion: nil)
            } else if type == "Date" {
                
            } else if type == "Boolean" {
                
                let alertController = UIAlertController(title: key, message: type, preferredStyle: .alert)
                alertController.view.tintColor = Color.Default.Tint.View
                
                let trueAction = UIAlertAction(title: "True", style: .default, handler: {
                    alert -> Void in
                    
                    let body = "{\"" + key + "\":" + "true" + "}"
                    Parse.put(endpoint: "/classes/" + self.parseClass!.name! + "/" + self.object.id, body: body, completion: { (response, json, success) in
                        
                        DispatchQueue.main.async {
                            NTToast(text: response, color: UIColor(r: 102, g: 99, b: 122), height: 44).show(duration: 2.0)
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
                    Parse.put(endpoint: "/classes/" + self.parseClass!.name! + "/" + self.object.id, body: body, completion: { (response, json, success) in
                        
                        DispatchQueue.main.async {
                            NTToast(text: response, color: UIColor(r: 102, g: 99, b: 122), height: 44).show(duration: 2.0)
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
        editAction.backgroundColor = Color.Default.Tint.View
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexpath in
            let body = "{\"" + self.object.keys[indexPath.row] + "\":null}"
            Parse.put(endpoint: "/classes/" + self.parseClass!.name! + "/" + self.object!.id, body: body, completion: { (response, json, success) in
                DispatchQueue.main.async {
                    NTToast(text: response, color: UIColor(r: 102, g: 99, b: 122), height: 44).show(duration: 2.0)
                    if success {
                        self.object.updatedAt = json["updatedAt"] as! String
                        let index = self.object.keys.index(of: "updatedAt")!
                        self.object.values[index] = json["updatedAt"]!
                        self.object.values[indexPath.row] = "<null>" as AnyObject
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0), indexPath], with: .none)
                    }
                }
            })
        })
        
        return [deleteAction, editAction]
    }
}



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

class ObjectViewController: PFTableViewController {
    
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
    }

    // MARK: - Object Refresh
    
    @objc
    func handleRefresh() {
        
        guard let classname = object.schema?.name else { return }
        Parse.shared.get("/classes/\(classname)/\(object.id)") { [weak self] (result, json) in
            guard result.success, let json = json else {
                self?.tableView.refreshControl?.endRefreshing()
                self?.handleError(result.error)
                return
            }
            let schema = self?.object.schema
            self?.object = PFObject(json)
            self?.object.schema = schema
            self?.tableView.reloadData()
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.backgroundColor = .darkPurpleAccent
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(FieldCell.self, forCellReuseIdentifier: FieldCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        
        title = object.id
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "Raw"),
                            style: .plain,
                            target: self,
                            action: #selector(toggleView(sender:))),
            UIBarButtonItem(image: UIImage(named: "Delete"),
                            style: .plain,
                            target: self,
                            action: #selector(deleteObject))
        ]
    }
    
    // MARK: - User Actions
    
    @objc
    func deleteObject() {
        
        let alert = UIAlertController(title: "Are you sure?", message: "This cannot be undone", preferredStyle: .alert)
        let actions = [
            UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                
                guard let classname = self?.object.schema?.name, let id = self?.object.id else { return }
                Parse.shared.delete("/classes/\(classname)/\(id)", completion: { [weak self] (result, json) in
                    guard result.success else {
                        self?.tableView.refreshControl?.endRefreshing()
                        self?.handleError(result.error)
                        return
                    }
                    self?.handleSuccess("Object \(id) deleted")
                    _ = self?.navigationController?.popViewController(animated: true)
                })
            }),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
            ]
        actions.forEach { alert.addAction($0) }
        self.present(alert, animated: true, completion: nil)
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
        if viewStyle == .formatted {
            return object.keys.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FieldCell.reuseIdentifier, for: indexPath) as? FieldCell else {
            return UITableViewCell()
        }
        let key = object.keys[indexPath.row]
        cell.key = key
        
        cell.valueTextView.layer.backgroundColor = UIColor.white.cgColor
        cell.valueTextView.textColor = .black
        cell.valueTextView.isUserInteractionEnabled = true
        
        if viewStyle == .formatted {
            
            let value = object.value(forKey: object.keys[indexPath.row])
            
            if let type = self.object.schema?.typeForField(key) {
                
                if type == .file, let dict = value as? [String : AnyObject] {
                    
                    // File Type
                    cell.value = dict["name"]
                    cell.valueTextView.isUserInteractionEnabled = false
                    cell.selectionStyle = .default
                    return cell
                    
                } else if type == .pointer, let dict = value as? [String : AnyObject] {
                    
                    // Pointer
                    let stringValue = String(describing: dict).replacingOccurrences(of: "[", with: " ").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: ",", with: "\n")
                    cell.value = stringValue 
                    cell.valueTextView.layer.cornerRadius = 3
                    cell.valueTextView.layer.backgroundColor = UIColor.darkPurpleAccent.cgColor
                    cell.valueTextView.textColor = .white
                    cell.valueTextView.isUserInteractionEnabled = false
                    return cell
                
                } else if type == .boolean, let booleanValue = value as? Bool {
                    
                    // Boolean
                    cell.value = (booleanValue ? "True" : "False") 
                    return cell
                    
                } else if type == .string {
                    
                    // String
                    cell.value = value
                    return cell
                    
                } else if type == .array {
                    
                    if let array = value as? [String] {
                        
                        // Array
                        if array.count > 0 {
                            cell.value = "\n Array of \(array.count) elements\n"
                            cell.valueTextView.layer.cornerRadius = 5
                            cell.valueTextView.layer.backgroundColor = UIColor.darkPurpleAccent.cgColor
                            cell.valueTextView.textColor = .white
                            cell.valueTextView.isUserInteractionEnabled = false
                        } else {
                            cell.value = "[]" 
                        }
                        return cell
                    } else if let array = value as? NSArray {
                        
                        // Array of Objects
                        if array.count > 0 {
                            cell.value = "\n Array of \(array.count) objects\n" 
                            cell.valueTextView.layer.cornerRadius = 5
                            cell.valueTextView.layer.backgroundColor = UIColor.darkPurpleAccent.cgColor
                            cell.valueTextView.textColor = .white
                            cell.valueTextView.isUserInteractionEnabled = false
                        } else {
                            cell.value = "[]" 
                        }
                        return cell
                    } else {
                        cell.value = String.undefined
                        return cell
                    }
                } else if type == .relation {
                    
                    var value = "\n View Relation\n"
                    if let dict = object.value(forKey: object.keys[indexPath.row]) as? [String : AnyObject] {
                        if let className = dict["className"] as? String {
                            value = "\n View Relation to Class: \(className)\n"
                        }
                    }
                    
                    // Array of Objects
                    cell.value = value
                    cell.valueTextView.layer.cornerRadius = 3
                    cell.valueTextView.layer.backgroundColor = UIColor.darkPurpleAccent.cgColor
                    cell.valueTextView.textColor = .white
                    cell.valueTextView.isUserInteractionEnabled = false
                    return cell
                    
                } else if type == .date, let stringValue = value as? String {
                    
                    // Date Data Type
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    if let date = dateFormatter.date(from: stringValue) {
                        cell.value = date.string(dateStyle: .full, timeStyle: .full) 
                        return cell
                    }
                }
            }
            cell.value = value
            return cell
        }
        cell.key = "JSON"
        cell.value = object.json 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if viewStyle == .formatted {
            let value = object.value(forKey: object.keys[indexPath.row])
            if let dict = value as? [String : AnyObject] {
                if let type = dict["__type"] as? String {
                    
                    if type == .file, let schema = object.schema {
                        
                        let url = dict["url"] as! String
                        let name = dict["name"] as! String
                        let imageVC = FileViewController(url: URL(string: url)!,
                                                         filename: name,
                                                         schema: schema,
                                                         key: object.keys[indexPath.row],
                                                         objectId: object.id)
                        let navVC = UINavigationController(rootViewController: imageVC)
                        navVC.navigationBar.isTranslucent = false
                        navVC.navigationBar.tintColor = .logoTint
                        navVC.modalPresentationStyle = .formSheet
                        present(navVC, animated: true, completion: nil)
                        
                    } else if type == .pointer {
                        
                        guard let classname = dict["className"] as? String, let objectId = dict[.objectId] as? String else {
                            handleError(nil)
                            return
                        }
                        Parse.shared.get("/schemas/" + classname, completion: { [weak self] (result, json) in
                            
                            guard result.success, let schemaJSON = json else {
                                self?.handleError(result.error)
                                return
                            }
                            Parse.shared.get("/classes/\(classname)/\(objectId)", completion: { (result, json) in
                                guard result.success, let objectJSON = json else {
                                    self?.handleError(result.error)
                                    return
                                }
                                let object = PFObject(objectJSON)
                                object.schema = PFSchema(schemaJSON)
                                self?.navigationController?.pushViewController(ObjectViewController(object), animated: true)
                            })
                        })

                    } else if type == .relation, let dict = object.value(forKey: object.keys[indexPath.row]) as? [String : AnyObject] {
                        
                        if let classname = dict["className"] as? String {
                            
                            let object = "{\"__type\":\"Pointer\", \"className\":\"\(classname)\", \"objectId\":\"\(self.object.id)\"}"
                            let relation = "\"$relatedTo\":{\"object\":\(object), \"key\":\"\(self.object.keys[indexPath.row])\"}"
                            let query = "where={" + relation + "}"
                            
                            Parse.shared.get("/schemas/" + classname, completion: { [weak self] (result, json) in
                                
                                guard result.success, let json = json else {
                                    self?.handleError(result.error)
                                    return
                                }
                                let schema = PFSchema(json)
                                let viewController = ClassViewController(schema)
                                viewController.query = query
                                self?.navigationController?.pushViewController(viewController, animated: true)
                            })
                        }
                    }
                }
            } else if let array = value as? NSArray {
                
                // Array of objects
                // For ease of reuse we will create a new PFObject from the arrays components and resuse ObjectViewController
                //                        let dictionary: [String:AnyObject] = [:]
                let viewController = ArrayViewController(array, fieldName: object.keys[indexPath.row])
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if viewStyle == .formatted {
            
            guard let type = object.schema?.typeForField(object.keys[indexPath.row]) else { return false }
            return (type == .file || type == .string || type ==  .number || type == .boolean)
                && (object.keys[indexPath.row] != .objectId) && (object.keys[indexPath.row] != .createdAt) && (object.keys[indexPath.row] != .updatedAt)
        }
        return false
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let editAction = UITableViewRowAction(style: .default, title: " Edit ", handler: { [weak self] _,_ in
            self?.tableView.setEditing(false, animated: true)

            let keys = self?.object.keys ?? []
            let value = self?.object.value(forKey: keys[indexPath.row])
            let key = keys[indexPath.row]
            guard let type = self?.object.schema?.typeForField(key), let schema = self?.object.schema, let id = self?.object.id else { return }

            if type == .file {
                if let dict = value as? [String : AnyObject] {
                    if let type = dict["__type"] as? String {
                        
                        if type == .file {
                            let url = dict["url"] as! String
                            let name = dict["name"] as! String
                            let imageVC = FileViewController(url: URL(string: url)!,
                                                             filename: name,
                                                             schema: schema,
                                                             key: key,
                                                             objectId: id)
                            let navVC = UINavigationController(rootViewController: imageVC)
                            navVC.navigationBar.isTranslucent = false
                            navVC.navigationBar.tintColor = .logoTint
                            navVC.modalPresentationStyle = .formSheet
                            self?.present(navVC, animated: true, completion: {
                                imageVC.presentImagePicker()
                            })
                        }
                    }
                } else {
                    
                    let imageVC = FileViewController(url: URL(string: "http://nathantannar.me")!,
                                                     filename: String(),
                                                     schema: schema,
                                                     key: key,
                                                     objectId: id)
                    let navVC = UINavigationController(rootViewController: imageVC)
                    navVC.navigationBar.isTranslucent = false
                    navVC.navigationBar.tintColor = .logoTint
                    navVC.modalPresentationStyle = .formSheet
                    self?.present(navVC, animated: true, completion: {
                        imageVC.presentImagePicker()
                    })
                    
                }
            } else if type == .string {
                
                let alert = UIAlertController(title: key, message: type, preferredStyle: .alert)

                let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
                    guard let newValue = alert.textFields?.first?.text else { return }
                    let data = "{\"\(key)\":\(newValue)}".data(using: .utf8)
                    self?.updateField(with: data)
                })

                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                alert.addAction(cancelAction)
                alert.addAction(saveAction)

                alert.addTextField { (textField : UITextField!) -> Void in
                    textField.placeholder = value as? String
                    textField.text = value as? String
                }
                self?.present(alert, animated: true, completion: nil)
                
            } else if type == .number {
                
                let alert = UIAlertController(title: key, message: type, preferredStyle: .alert)

                let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
                    guard let newValue = alert.textFields?.first?.text else { return }
                    let data = "{\"\(key)\":\(newValue)}".data(using: .utf8)
                    self?.updateField(with: data)
                })

                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                alert.addAction(cancelAction)
                alert.addAction(saveAction)

                alert.addTextField {
                    $0.text = value as? String
                    $0.placeholder = value as? String
                    $0.keyboardType = .numberPad
                }
                self?.present(alert, animated: true, completion: nil)

            } else if type == .date {
                
                // TODO: Implement Later

            } else if type == .boolean {

                let alert = UIAlertController(title: key, message: type, preferredStyle: .alert)
                let trueAction = UIAlertAction(title: "True", style: .default, handler: {
                    alert -> Void in
                    let data = "{\"\(key)\":true}".data(using: .utf8)
                    self?.updateField(with: data)
                })

                let falseAction = UIAlertAction(title: "False", style: .default, handler: {
                    alert -> Void in
                    let data = "{\"\(key)\":false}".data(using: .utf8)
                    self?.updateField(with: data)
                })

                alert.addAction(falseAction)
                alert.addAction(trueAction)
                self?.present(alert, animated: true, completion: nil)
            }
        })
        editAction.backgroundColor = .logoTint

        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexpath in
            
            let data = "{\"\(self.object.keys[indexPath.row])\":null}".data(using: .utf8)
            self.updateField(with: data)
        })

        return [deleteAction, editAction]
    }
    
    func updateField(with data: Data?) {
        
        guard let data = data else {
            handleError("JSON encoding failed")
            return
        }
        
        guard let classname = self.object.schema?.name else { return }
        Parse.shared.put("/classes/\(classname)/\(object.id)", data: data, completion: { [weak self] (result, json) in
            
            guard result.success, let json = json else {
                self?.handleError(result.error)
                return
            }
            let schema = self?.object.schema
            self?.object = PFObject(json)
            self?.object.schema = schema
            self?.tableView.reloadData()
            self?.tableView.refreshControl?.endRefreshing()
            self?.handleSuccess("Object Updated")
        })
    }
}

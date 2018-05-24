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

// Appologies, this file is a mess

import UIKit
import SwiftyJSON
import AlertHUDKit
import RMDateSelectionViewController

class ObjectViewController: TableViewController {
    
    // MARK: - Properties
    
    enum ViewStyle {
        case json, formatted
    }
    
    private var object: ParseLiteObject
    private var viewStyle = ViewStyle.formatted
    
    // MARK: - Initialization
    
    init(for object: ParseLiteObject) {
        self.object = object
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if object.schema?.name == "_User" {
            setupToolbar()
            navigationController?.setToolbarHidden(false, animated: animated)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if object.schema?.name == "_User" {
            if !(navigationController?.viewControllers.last is ClassViewController) {
                navigationController?.setToolbarHidden(true, animated: animated)
            }
        }
    }

    // MARK: - Object Refresh
    
    @objc
    func handleRefresh() {
        
        guard let classname = object.schema?.name else { return }
        ParseLite.shared.get("/classes/\(classname)/\(object.id)") { [weak self] (result, json) in
            guard result.success, let json = json else {
                self?.tableView.refreshControl?.endRefreshing()
                self?.handleError(result.error)
                return
            }
            let schema = self?.object.schema
            self?.object = ParseLiteObject(json)
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
        
        let rc = UIRefreshControl()
        rc.tintColor = .white
        rc.attributedTitle = NSAttributedString(string: "Pull to Refresh", attributes: [.foregroundColor : UIColor.white, .font: UIFont.boldSystemFont(ofSize: 12)])
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = rc
    }
    
    private func setupNavigationBar() {
        
        title = object.id
        subtitle = object.schema?.name
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "Raw"),
                            style: .plain,
                            target: self,
                            action: #selector(toggleView(sender:))),
            UIBarButtonItem(image: UIImage(named: "Delete")?.scale(to: 30),
                            style: .plain,
                            target: self,
                            action: #selector(deleteObject))
        ]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Object", style: .plain, target: nil, action: nil)
    }
    
    private func setupToolbar() {
        
        navigationController?.toolbar.isTranslucent = false
        navigationController?.toolbar.barTintColor = .darkPurpleAccent
        navigationController?.toolbar.tintColor = .white
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil), UIBarButtonItem(customView: PushNotificationItemView(target: self, action: #selector(presentPushNotificationController)))]
    }
    
    // MARK: - User Actions
    
    @objc
    func presentPushNotificationController() {
        
        let pushNotificationController = PushNotificationController(to: object)
        present(pushNotificationController, animated: true, completion: nil)
    }
    
    @objc
    func deleteObject() {
        
        let action = ActionSheetAction(title: Localizable.delete.localized, style: .destructive) { [weak self] _ in
            guard let classname = self?.object.schema?.name, let id = self?.object.id else { return }
            ParseLite.shared.delete("/classes/\(classname)/\(id)", completion: { [weak self] (result, json) in
                self?.tableView.refreshControl?.endRefreshing()
                guard result.success else {
                    self?.handleError(result.error)
                    return
                }
                self?.handleSuccess("Object \(id) deleted")
                self?.navigationController?.popViewController(animated: true)
            })
        }
        let alertPromptViewController = AlertPromptViewController(title: "Create Class", initialValue: nil, placeholder: "Classname", action: action)
        present(alertPromptViewController, animated: true, completion: nil)
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
                    
                    if let array = value as? [AnyObject] {
                        
                        // Array
                        cell.value = "\n Array of \(array.count) elements\n"
                        cell.valueTextView.layer.cornerRadius = 5
                        cell.valueTextView.layer.backgroundColor = UIColor.darkPurpleAccent.cgColor
                        cell.valueTextView.textColor = .white
                        cell.valueTextView.isUserInteractionEnabled = false
                        return cell
                    } else if let array = value as? [String : AnyObject] {
                        
                        // Array of Objects
                        cell.value = "\n Array of \(array.count) objects\n"
                        cell.valueTextView.layer.cornerRadius = 5
                        cell.valueTextView.layer.backgroundColor = UIColor.darkPurpleAccent.cgColor
                        cell.valueTextView.textColor = .white
                        cell.valueTextView.isUserInteractionEnabled = false
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
                    
                } else if type == .date, let iso = (value as? [String:String])?["iso"] ?? value as? String {
                    
                    // Date Data Type
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    if let date = dateFormatter.date(from: iso) {
                        cell.value = date.string(dateStyle: .full, timeStyle: .full) 
                        return cell
                    }
                }
            }
            cell.value = object.json.dictionaryValue[key] ?? String.null
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
                        let fileVC = FileViewController(url: URL(string: url)!,
                                                         filename: name,
                                                         schema: schema,
                                                         key: object.keys[indexPath.row],
                                                         objectId: object.id)
                        navigationController?.pushViewController(fileVC, animated: true)
                        
                    } else if type == .pointer {
                        
                        guard let classname = dict["className"] as? String, let objectId = dict[.objectId] as? String else {
                            handleError(nil)
                            return
                        }
                        ParseLite.shared.get("/schemas/" + classname, completion: { [weak self] (result, json) in
                            
                            guard result.success, let schemaJSON = json else {
                                self?.handleError(result.error)
                                return
                            }
                            ParseLite.shared.get("/classes/\(classname)/\(objectId)", completion: { (result, json) in
                                guard result.success, let objectJSON = json else {
                                    self?.handleError(result.error)
                                    return
                                }
                                let object = ParseLiteObject(objectJSON)
                                object.schema = PFSchema(schemaJSON)
                                self?.navigationController?.pushViewController(ObjectViewController(for: object), animated: true)
                            })
                        })

                    } else if type == .relation, let dict = object.value(forKey: object.keys[indexPath.row]) as? [String : AnyObject] {
                        
                        if let classname = dict["className"] as? String, let schema = self.object.schema?.name {
                            
                            let object = "{\"__type\":\"Pointer\", \"className\":\"\(schema)\", \"objectId\":\"\(self.object.id)\"}"
                            let relation = "\"$relatedTo\":{\"object\":\(object), \"key\":\"\(self.object.keys[indexPath.row])\"}"
                            let query = "where={" + relation + "}"
                            
                            ParseLite.shared.get("/schemas/" + classname, completion: { [weak self] (result, json) in
                                
                                guard result.success, let json = json else {
                                    self?.handleError(result.error)
                                    return
                                }
                                let schema = PFSchema(json)
                                let viewController = ClassViewController(for: schema)
                                viewController.query = query
                                self?.navigationController?.pushViewController(viewController, animated: true)
                            })
                        }
                    }
                }
            } else if let array = value as? NSArray {
                
                // Array of objects
                // For ease of reuse we will create a new ParseLiteObject from the arrays components and resuse ObjectViewController
                //                        let dictionary: [String:AnyObject] = [:]
                let viewController = ArrayViewController(array, fieldName: object.keys[indexPath.row])
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if viewStyle == .formatted {
            guard let type = object.schema?.typeForField(object.keys[indexPath.row]) else { return false }
            return (type != .relation) && (object.keys[indexPath.row] != .objectId) && (object.keys[indexPath.row] != .createdAt) && (object.keys[indexPath.row] != .updatedAt)
        }
        return false
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

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
                            let fileVC = FileViewController(url: URL(string: url)!,
                                                             filename: name,
                                                             schema: schema,
                                                             key: key,
                                                             objectId: id)
                            self?.navigationController?.pushViewController(fileVC, animated: true)
                        }
                    }
                } else {
                    
                    let fileVC = FileViewController(url: nil,
                                                     filename: String(),
                                                     schema: schema,
                                                     key: key,
                                                     objectId: id)
                    self?.navigationController?.pushViewController(fileVC, animated: true)
                    
                }
            } else if type == .string {
                
                let action = ActionSheetAction(title: "Save", style: .default) { [weak self] newValue in
                    guard let newValue = newValue as? String else { return }
                    let data = "{\"\(key)\":\"\(newValue)\"}".data(using: .utf8)
                    self?.updateField(with: data)
                }
                let alertPromptViewController = AlertPromptViewController(title: "Value for key `\(key)`", initialValue: value as? String, placeholder: "String", action: action)
                alertPromptViewController.additionalHeight = 100
                self?.present(alertPromptViewController, animated: true, completion: nil)
                
            } else if type == .number {
                
                let action = ActionSheetAction(title: "Save", style: .default) { [weak self] newValue in
                    guard let newValue = newValue as? String else { return }
                    let data = "{\"\(key)\":\(newValue)}".data(using: .utf8)
                    self?.updateField(with: data)
                }
                let alertPromptViewController = AlertPromptViewController(title: "Value for key `\(key)`", initialValue: value as? String, placeholder: "Number", action: action)
                alertPromptViewController.messageTextView.keyboardType = .numberPad
                self?.present(alertPromptViewController, animated: true, completion: nil)

            } else if type == .date {
                
                let selectAction = RMAction<UIDatePicker>(title: Localizable.save.localized, style: .default, andHandler: { controller in
                    let date = controller.contentView.date
                    let dateString = date.stringify()
                    let data = "{\"\(key)\":{\"__type\":\"Date\", \"iso\":\"\(dateString)\"}}".data(using: .utf8)
                    self?.updateField(with: data)
                })
                let cancelAction = RMAction<UIDatePicker>(title: Localizable.cancel.localized, style: .destructive, andHandler: nil)
                guard let datePicker = RMDateSelectionViewController(style: .white, title: key, message: type, select: selectAction, andCancel: cancelAction) else { return }
                datePicker.disableMotionEffects = true
                datePicker.disableBouncingEffects = true
                datePicker.disableBlurEffects = true
                self?.present(datePicker, animated: true, completion: nil)

            } else if type == .boolean {
                
                let actions = [
                    ActionSheetAction(title: "True", style: .default, callback: { [weak self] _ in
                        let data = "{\"\(key)\":true}".data(using: .utf8)
                        self?.updateField(with: data)
                    }),
                    ActionSheetAction(title: "False", style: .default, callback: { [weak self] _ in
                        let data = "{\"\(key)\":false}".data(using: .utf8)
                        self?.updateField(with: data)
                    })
                ]
                let actionSheetController = ActionSheetController(title: "Value for key `\(key)`", message: nil, actions: actions)
                self?.present(actionSheetController, animated: true, completion: nil)
                
            } else if type == .pointer {
                
                guard let pointer = self?.object.schema?.fields?[key] as? [String:String] else {
                    self?.handleError("Failed to parse schema for type")
                    return
                }
                guard let targetClass = pointer["targetClass"] else { return }
                
                ParseLite.shared.get("/schemas/" + targetClass, completion: { [weak self] (result, json) in
                    
                    guard result.success, let schemaJSON = json else {
                        self?.handleError(result.error)
                        return
                    }
                    let schema = PFSchema(schemaJSON)
                    let selectionController = ObjectSelectorViewController(selecting: key, in: schema)
                    selectionController.delegate = self
                    self?.navigationController?.pushViewController(selectionController, animated: true)
                })
                
            } else if type == .array {
                
                let value: [Any] = self?.object.json.dictionary?[key]?.arrayObject ?? []
                
                let action = ActionSheetAction(title: "Save", style: .default) { [weak self] newValue in
                    guard let newValue = newValue as? String else { return }
                    let data = "{\"\(key)\":\(newValue)}".data(using: .utf8)
                    self?.updateField(with: data)
                }
                let alertPromptViewController = AlertPromptViewController(title: "Value for key `\(key)`", initialValue: String(describing: value), placeholder: "Array", action: action)
                alertPromptViewController.additionalHeight = 100
                self?.present(alertPromptViewController, animated: true, completion: nil)

            } else {
                
                // Any other type is treated as a JSON object
                
                let json = self?.object.value(forKey: key) ?? []
                guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), let value = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) else {
                    self?.handleError("JSON parse failed")
                    return
                }
                
                let currentValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
                
                let action = ActionSheetAction(title: "Save", style: .default) { [weak self] newValue in
                    guard let newValue = newValue as? String else { return }
                    let data = "{\"\(key)\":\(newValue)}".data(using: .utf8)
                    self?.updateField(with: data)
                }
                let alertPromptViewController = AlertPromptViewController(title: "Value for key `\(key)`", initialValue: currentValue, placeholder: "Unknown Type", action: action)
                alertPromptViewController.additionalHeight = 100
                self?.present(alertPromptViewController, animated: true, completion: nil)
            }
        })
        editAction.backgroundColor = .logoTint

        let deleteAction = UITableViewRowAction(style: .destructive, title: Localizable.delete.localized, handler: { action, indexpath in
            
            let keys = self.object.keys
            let value = self.object.value(forKey: keys[indexPath.row])
            if let dict = value as? [String : AnyObject] {
                if let type = dict["__type"] as? String {
                    // We need to remove the appId
                    guard let appId = ParseLite.shared.currentConfiguration?.applicationId else { return }
                    
                    if type == .file, let urlString = (dict["url"] as? String)?.replacingOccurrences(of: "\(appId)/", with: ""), let url = URL(string: urlString) {
                        // Delete the file
                        ParseLite.shared.delete(url: url, completion: { _, _ in })
                    }
                }
            }
            
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
        ParseLite.shared.put("/classes/\(classname)/\(object.id)", data: data, completion: { [weak self] (result, json) in
            
            guard result.success else {
                self?.handleError(result.error)
                return
            }
            self?.handleRefresh()
            self?.handleSuccess("Object Updated")
        })
    }
}

extension ObjectViewController: ObjectSelectorViewControllerDelegate {
    
    func objectSelector(_ viewController: ObjectSelectorViewController, didSelect object: ParseLiteObject, for key: String) {
        guard let type = self.object.schema?.typeForField(key) else {
            handleError("Unknown type for selected field")
            return
        }
        switch type {
        case .pointer:
            
            var body = JSON()
            body.dictionaryObject?[key] = [
                "__type"    : "Pointer",
                "objectId"  : object.id,
                "className" : object.schema?.name
            ]
            do {
                let data = try body.rawData()
                updateField(with: data)
                viewController.navigationController?.popViewController(animated: true)
            } catch let error {
                handleError(error.localizedDescription)
            }
            
        default:
            handleError("Type `Pointer` cannot be assigned to field `\(key)`")
        }
    }
    
}


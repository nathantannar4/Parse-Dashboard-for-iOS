//
//  ClassViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 3/1/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit
import NTComponents

class ClassViewController: UITableViewController {
    
    var parseClass: ParseClass?
    var objects = [ParseObject]()
    var previewKeys = ["objectId", "createdAt", "updatedAt"]
    var query = "limit=1000&order=-updatedAt"
    
    convenience init(parseClass: ParseClass) {
        self.init()
        self.parseClass = parseClass
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleView(title: parseClass?.name)
        view.backgroundColor = UIColor(r: 102, g: 99, b: 122)
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 10
        tableView.backgroundColor = UIColor(r: 102, g: 99, b: 122)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ObjectPreviewCell.self, forCellReuseIdentifier: "ObjectPreviewCell")
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(loadObjects), for: .valueChanged)
        tableView.refreshControl = refreshControl
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addObject)), UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(setPreferredCellLabels(sender:)))]
        
        loadObjects()
        
        if parseClass!.name! == "_Installation" {
            
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
            setToolbarItems(items, animated: true)
            navigationController?.isToolbarHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isToolbarHidden = true
    }
    
    func loadObjects() {
        objects.removeAll()
        tableView.reloadSections([0], with: .automatic)
        Parse.get(endpoint: "/classes/" + parseClass!.name!, query: "?" + query) { (json) in
            guard let results = json["results"] as? [[String: AnyObject]] else {
                DispatchQueue.main.async {
                    NTToast(text: "Unexpected Results", color: UIColor(r: 114, g: 111, b: 133), height: 50).show(duration: 2.0)
                    self.setTitleView(title: self.parseClass?.name, subtitle: "0 Objects")
                    self.tableView.refreshControl?.endRefreshing()
                }
                return
            }
            self.objects = results.map({ (dictionary) -> ParseObject in
                return ParseObject(dictionary)
            })
            DispatchQueue.main.async {
                self.tableView.reloadSections([0], with: .automatic)
                self.tableView.refreshControl?.endRefreshing()
            }
            DispatchQueue.executeAfter(0.5, closure: {
                self.setTitleView(title: self.parseClass!.name, subtitle: String(results.count) + " Objects")
            })
        }
    }
    
    func addObject() {
        let alertController = UIAlertController(title: "Create Object", message: nil, preferredStyle: .alert)
        alertController.view.tintColor = Color.Default.Tint.View
        
        let saveAction = UIAlertAction(title: "Create", style: .default, handler: {
            alert -> Void in
            
            let body = alertController.textFields?[0].text
            Parse.post(endpoint: "/classes/" + self.parseClass!.name!, body: body, completion: { (response, json, success) in
                DispatchQueue.main.async {
                    NTToast(text: response, color: UIColor(r: 114, g: 111, b: 133), height: 50).show(duration: 2.0)
                    if success {
                        print(json)
                        let object = ParseObject(json)
                        self.objects.insert(object, at: 0)
                        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    }
                }
            })
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "POST Body"
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func sendPushNotification() {
        let alertController = UIAlertController(title: "Push Notification", message: "To current query results", preferredStyle: .alert)
        alertController.view.tintColor = Color.Default.Tint.View
        
        let saveAction = UIAlertAction(title: "Send", style: .default, handler: {
            alert -> Void in
            
            let message = alertController.textFields![0].text!
            
            let userIds = self.objects.map({ (object) -> String in
                let dict = object.json
                guard let user = dict["user"] as? [String : AnyObject] else {
                    return String()
                }
                return user["objectId"] as! String
            })
            // where={"user":{"$inQuery":{"className":"_User","where":{"objectId":{"$in":["zaAqYBP8X9"]}}}}}
            
            let body = "{\"where\":{\"user\":{\"$inQuery\":{\"className\":\"_User\",\"where\":{\"objectId\":{\"$in\":\(userIds)}}}}},\"data\":{\"title\":\"Message from Server\",\"alert\":\"\(message)\"}}"
            print(body)
            Parse.post(endpoint: "/push", body: body) { (response, json, success) in
                DispatchQueue.main.async {
                    NTToast(text: response, color: UIColor(r: 114, g: 111, b: 133), height: 44).show(duration: 2.0)
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
    
    func setPreferredCellLabels(sender: AnyObject) {
        
        let queryVC = QuerySelectionViewController(parseClass!, selectedKeys: previewKeys, query: query)
        queryVC.delegate = self
        
        let navVC = NTNavigationController(rootViewController: queryVC)
        navVC.modalPresentationStyle = .popover
        navVC.popoverPresentationController?.permittedArrowDirections = .up
        navVC.popoverPresentationController?.delegate = self
        navVC.popoverPresentationController?.sourceView = navigationItem.titleView
        navVC.popoverPresentationController?.sourceRect = navigationItem.titleView!.bounds
        
        present(navVC, animated: true, completion: nil)
    }

    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectPreviewCell", for: indexPath) as! ObjectPreviewCell
        cell.previewKeys = previewKeys
        cell.object = objects[indexPath.row]
        cell.backgroundColor = ((indexPath.row % 2) == 0) ? UIColor(r: 102, g: 99, b: 122) : UIColor(r: 114, g: 111, b: 133)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ObjectViewController(objects[indexPath.row], parseClass: parseClass!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexpath in
            let alert = NTAlertViewController(title: "Are you sure?", subtitle: "This cannot be undone", type: .isDanger)
            alert.onConfirm = {
                Parse.delete(endpoint: "/classes/" + self.parseClass!.name! + "/" + self.objects[indexPath.row].id, completion: { (response, code, success) in
                    DispatchQueue.main.async {
                        NTToast(text: response, color: UIColor(r: 114, g: 111, b: 133), height: 50).show(duration: 2.0)
                        if success {
                            self.objects.remove(at: indexPath.row)
                            self.setTitleView(title: self.parseClass!.name, subtitle: String(self.objects.count) + " Objects")
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    }
                })
            }
            alert.show(self, sender: nil)
        })
        deleteAction.backgroundColor = Color.Default.Status.Danger
        
        return [deleteAction]
    }
}

extension ClassViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension ClassViewController: TableQueryDelegate {
    
    // MARK: - TableQueryDelegate
    
    func parseQuery(didChangeWith query: String, previewKeys: [String]) {
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

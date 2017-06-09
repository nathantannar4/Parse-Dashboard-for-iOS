//
//  ServerViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 2/28/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit
import NTComponents
import CoreData
import QuartzCore

class ServerViewController: UITableViewController {
    
    var servers: [ParseServer] = []
    var indexPathForSelectedRow: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "Logo")?.scale(to: 40))
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 10
        tableView.backgroundColor = UIColor(r: 30, g: 59, b: 77)
        tableView.separatorStyle = .none
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addServer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Info"), style: .plain, target: self, action: #selector(showAppInfo))
        navigationController?.navigationBar.setDefaultShadow()
        
        getServers()
    }
    
    func getServers() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<ParseServer> = ParseServer.fetchRequest()
        do {
            servers = try context.fetch(request)
        } catch {
            NTToast(text: "Could not load servers from Core Data").show(duration: 1.0)
        }
        tableView.reloadData()
    }
    
    func showAppInfo() {
        let navVC = NTNavigationController(rootViewController: AppInfoViewController())
        navVC.modalPresentationStyle = .custom
        let delegate = NTSwipeableTransitioningDelegate(fromViewController: self, toViewController: navVC)
        navVC.transitioningDelegate = delegate
        navVC.view.layer.cornerRadius = 12
        navVC.view.clipsToBounds = true
        present(navVC, animated: true, completion: nil)
    }

    // MARK: - User Actions
    
    func addServer() {
        let alertController = UIAlertController(title: "Add Server", message: nil, preferredStyle: .alert)
        alertController.view.tintColor = Color.Default.Tint.View
        
        let saveAction = UIAlertAction(title: "Add", style: .default, handler: {
            alert -> Void in
        
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let parseServerObject = NSManagedObject(entity: ParseServer.entity(), insertInto: context)
            parseServerObject.setValue(alertController.textFields![0].text, forKey: "name")
            parseServerObject.setValue(alertController.textFields![1].text, forKey: "applicationId")
            parseServerObject.setValue(alertController.textFields![2].text, forKey: "masterKey")
            parseServerObject.setValue(alertController.textFields![3].text, forKey: "serverUrl")
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.servers.append(parseServerObject as! ParseServer)
            self.tableView.insertRows(at: [IndexPath(row: self.servers.count - 1, section: 0)], with: .fade)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "App Name"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Application ID"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Master Key"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Server URL"
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func editServer(_ indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Configuration", message: "Edit", preferredStyle: .alert)
        alertController.view.tintColor = Color.Default.Tint.View
        
        let parseServerObject = self.servers[indexPath.row]
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            parseServerObject.setValue(alertController.textFields![0].text, forKey: "name")
            parseServerObject.setValue(alertController.textFields![1].text, forKey: "applicationId")
            parseServerObject.setValue(alertController.textFields![2].text, forKey: "masterKey")
            parseServerObject.setValue(alertController.textFields![3].text, forKey: "serverUrl")
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.tableView.reloadRows(at: [indexPath], with: .none)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "App Name"
            textField.text = parseServerObject.name
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Application ID"
            textField.text = parseServerObject.applicationId
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Master Key"
            textField.text = parseServerObject.masterKey
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "http://<url>:<port>/<parse mount>"
            textField.text = parseServerObject.serverUrl
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func toggleSwitch(sender: UISwitch) {
        
    }
    
    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ServerCell()
        cell.server = servers[indexPath.row]
        return cell
  
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let server = servers[indexPath.row]
        Parse.initialize(with: server)
        let vc = SchemaViewController(server: server)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .default, title: " Edit ", handler: { action, indexpath in
            
            var actions = [NTActionSheetItem]()
            actions.append(
                NTActionSheetItem(title: "Configuration", action: {
                    self.editServer(indexPath)
                })
            )
            actions.append(
                NTActionSheetItem(title: "Icon", action: {
                    self.indexPathForSelectedRow = indexPath
                    self.presentImagePicker()
                })
            )
            actions.append(
                NTActionSheetItem(title: "Dismiss", action: nil)
            )
            let actionSheet = NTActionSheetViewController(title: "Edit Server", subtitle: nil, actions: actions)
            actionSheet.show(self, sender: nil)
        })
        editAction.backgroundColor = Color.Default.Tint.View
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { action, indexpath in
            
            let alert = NTAlertViewController(title: "Are you sure?", subtitle: "This cannot be undone", type: .isDanger)
            alert.onConfirm = {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                context.delete(self.servers[indexPath.row])
                do {
                    try context.save()
                } catch {
                    NTToast(text: "Could not delete server from core data").show(duration: 2.0)
                }

                self.servers.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            alert.show(self, sender: nil)
        })
        deleteAction.backgroundColor = Color.Default.Status.Danger
        
        return [deleteAction, editAction]
    }
}

extension ServerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: UIImagePickerControllerDelegate
    
    func presentImagePicker() {
        let picker = NTImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let indexPath = indexPathForSelectedRow else { return }
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let imageData = UIImageJPEGRepresentation(image, 1)
            self.servers[indexPath.row].setValue(imageData, forKey: "icon")
            do {
                try context.save()
            } catch {
                NTToast(text: "Could not save icon to core data").show(duration: 2.0)
            }
            picker.dismiss(animated: true, completion: {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            })
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//
//  ServerViewController.swift
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
import CoreData
import NTComponents
import Fabric
import Crashlytics

class ServerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
//    
//    private let supportButton: NTButton = {
//        let button = NTButton()
//        button.title = "  Support"
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            button.titleFont = Font.Roboto.Medium.withSize(36)
//        } else {
//            button.titleFont = Font.Roboto.Medium.withSize(18)
//        }
//        button.backgroundColor = .darkBlueAccent
//        button.tintColor = .white
//        button.image = UIImage(named: "Applause")?.scale(to: 36)
//        return button
//    }()
    
    private let tableView = UITableView()
    
    private var servers = [ParseServerConfig]()
    private var indexPathForSelectedRow: IndexPath?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
//        setupSupportButton()
        loadServers()
        checkIfAppIsNew()
    }
    
    // MARK: - Data Refresh
    
    func loadServers() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        let request: NSFetchRequest<ParseServerConfig> = ParseServerConfig.fetchRequest()
        do {
            servers = try context.fetch(request)
        } catch {}
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    private func checkIfAppIsNew() {
        
        let appIsNew = (UserDefaults.standard.value(forKey: .appIsNew) as? Bool) ?? true
        if appIsNew {
            let alert = UIAlertController(title: nil, message: "Tap the Parse logo to read about how your privacy is protected and where to find this Open Source project.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { alert in
                UserDefaults.standard.set(false, forKey: .appIsNew)
            }))
            alert.view.tintColor = .darkBlueBackground
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func setupTableView() {
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 90
        tableView.backgroundColor = .darkBlueBackground
        tableView.separatorStyle = .none
        tableView.register(ServerCell.self, forCellReuseIdentifier: ServerCell.reuseIdentifier)
    }
    
    private func setupNavigationBar() {
        
        setTitleView(title: "Parse Dashboard for iOS", subtitle: nil, titleColor: .black, subtitleColor: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Logo")?.scale(to: 30),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(ServerViewController.showAppInfo))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(ServerViewController.addServer))
    }
    
//    private func setupSupportButton() {
//
//        view.addSubview(supportButton)
//        supportButton.addTarget(self, action: #selector(ServerViewController.showDonateInfo), for: .touchUpInside)
//
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            supportButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, heightConstant: 120)
//        } else {
//            supportButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, heightConstant: 60)
//        }
//    }
    
    // MARK: - User Actions
    
    @objc func showAppInfo() {
        
        let navVC = NTNavigationController(rootViewController: AppInfoViewController())
        navVC.view.backgroundColor = .white
        navVC.modalPresentationStyle = .formSheet
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func showDonateInfo() {
        
        let navVC = NTNavigationController(rootViewController: SupportViewController())
        navVC.view.backgroundColor = .white
        navVC.modalPresentationStyle = .formSheet
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func addServer() {
        let alertController = UIAlertController(title: "Add Server", message: nil, preferredStyle: .alert)
        alertController.view.tintColor = Color.Default.Tint.View
        
        let saveAction = UIAlertAction(title: "Add", style: .default, handler: {
            alert -> Void in
            
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                return
            }
            let parseServerObject = NSManagedObject(entity: ParseServerConfig.entity(), insertInto: context)
            parseServerObject.setValue(alertController.textFields![0].text, forKey: "name")
            parseServerObject.setValue(alertController.textFields![1].text, forKey: "applicationId")
            parseServerObject.setValue(alertController.textFields![2].text, forKey: "masterKey")
            parseServerObject.setValue(alertController.textFields![3].text, forKey: "serverUrl")
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            if let config = parseServerObject as? ParseServerConfig {
                self.servers.append(config)
                self.tableView.insertRows(at: [IndexPath(row: self.servers.count - 1, section: 0)], with: .fade)
                Answers.logContentView(withName: "Server Added", contentType: nil, contentId: nil, customAttributes: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        for placeholder in ["App Name", "Application ID", "Master Key", "Server URL"] {
            alertController.addTextField { $0.placeholder = placeholder }
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func editServer(at indexPath: IndexPath) {
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
    
    // MARK: - UITableViewDatasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ServerCell.reuseIdentifier, for: indexPath) as! ServerCell
        cell.server = servers[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let config = servers[indexPath.row]
        Parse.initialize(config)
        
        let vc = SchemaViewController(config)
        vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        
        let nav = NTNavigationController(rootViewController: vc)
        
        let container = UIControllerContainer(viewControllers: [nav])
        container.tabBar.backgroundColor = .darkBlueBackground
        container.tabBar.activeTintColor = .white
        container.tabBar.scrollIndicator.backgroundColor = .white
        container.tabBarSizeLayout = .fixed(120)
        Parse.container = container
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            vc.addDismissalBarButtonItem()
            present(vc, animated: true, completion: nil)
        } else {
            splitViewController?.showDetailViewController(container, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let duplicateAction = UITableViewRowAction(style: .default, title: " Copy ", handler: { action, indexpath in
            
            self.tableView.setEditing(false, animated: true)
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                return
            }
            let parseServerObject = NSManagedObject(entity: ParseServerConfig.entity(), insertInto: context)
            parseServerObject.setValue(self.servers[indexPath.row].name, forKey: "name")
            parseServerObject.setValue(self.servers[indexPath.row].applicationId, forKey: "applicationId")
            parseServerObject.setValue(self.servers[indexPath.row].masterKey, forKey: "masterKey")
            parseServerObject.setValue(self.servers[indexPath.row].serverUrl, forKey: "serverUrl")
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.servers.append(parseServerObject as! ParseServerConfig)
            self.tableView.insertRows(at: [IndexPath(row: self.servers.count - 1, section: 0)], with: .fade)
        })
        duplicateAction.backgroundColor = .lightBlueAccent
        
        let editAction = UITableViewRowAction(style: .default, title: " Edit ", handler: { action, indexpath in
            self.tableView.setEditing(false, animated: true)
            
            let actionSheetController = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
            let actions = [
                UIAlertAction(title: "Configuration", style: .default, handler: { _ in
                    self.editServer(at: indexPath)
                }),
                UIAlertAction(title: "Icon", style: .default, handler: { _ in
                    self.indexPathForSelectedRow = indexPath
                    self.presentImagePicker()
                }),
                UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
            ]
            actions.forEach { actionSheetController.addAction($0) }
            actionSheetController.popoverPresentationController?.sourceView = self.navigationItem.titleView
            self.present(actionSheetController, animated: true, completion: nil)
        })
        editAction.backgroundColor = .lightBlueBackground
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { action, indexpath in
            
            let alertController = UIAlertController(title: "Are you sure?", message: "This cannot be undone", preferredStyle: .alert)
            let actions = [
                UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                        return
                    }
                    context.delete(self.servers[indexPath.row])
                    do {
                        try context.save()
                    } catch {
                        NTToast(text: "Could not delete server from core data").show(duration: 2.0)
                    }
                    
                    self.servers.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }),
                UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
            ]
            actions.forEach { alertController.addAction($0) }
            self.present(alertController, animated: true, completion: nil)
        })
        deleteAction.backgroundColor = Color.Default.Status.Danger
        
        return [deleteAction, editAction, duplicateAction]
    }
    
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
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                return
            }
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

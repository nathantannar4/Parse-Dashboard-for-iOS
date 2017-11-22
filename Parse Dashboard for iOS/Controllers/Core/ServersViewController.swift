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

class ServersViewController: PFCollectionViewController {
    
    // MARK: - Properties
    
    private var servers = [ParseServerConfig]()
    private var selectedIndexPath: IndexPath?
    private var context: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkBlueBackground
        fetchServersFromCoreData()
    }
    
    // MARK: - Override Setup
    
    override func setupCollectionView() {
        super.setupCollectionView()
        
        collectionView?.backgroundColor = .darkBlueBackground
        collectionView?.register(ServerCell.self, forCellWithReuseIdentifier: ServerCell.reuseIdentifier)
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "Parse Dashboard for iOS"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Logo")?.scale(to: 30),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(showInfo))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addServer))
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return servers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ServerCell.reuseIdentifier, for: indexPath) as! ServerCell
        cell.server = servers[indexPath.row]
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let config = servers[indexPath.row]
        Parse.shared.initialize(with: config)
        navigationController?.pushViewController(SchemaViewController(), animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didLongSelectItemAt indexPath: IndexPath) {
        presentActions(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let insets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let size = CGSize(width: collectionView.bounds.width, height: 100)
        return CGSize(width: size.width - insets.left - insets.right, height: size.height - insets.top - insets.bottom)
    }
    
    // MARK: - CoreData Refresh
    
    func fetchServersFromCoreData() {
        guard let context = context else { return }
        let request: NSFetchRequest<ParseServerConfig> = ParseServerConfig.fetchRequest()
        do {
            servers = try context.fetch(request)
        } catch let error {
            handleError(error.localizedDescription)
        }
    }
    
    // MARK: - User Actions
    
    @objc
    func showInfo() {
        let navigationController = UINavigationController(rootViewController: AppInfoViewController())
        navigationController.navigationBar.isTranslucent = false
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = .logoTint
        present(navigationController, animated: true, completion: nil)
    }
    
    func presentActions(for indexPath: IndexPath) {
        
        let actionSheet = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)
        let actions = [
            UIAlertAction(title: "Copy", style: .default, handler: { [weak self] _ in
                self?.duplicateServer(at: indexPath)
            }),
            UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
                self?.editServer(at: indexPath)
            }),
            UIAlertAction(title: "Edit Icon", style: .default, handler: { [weak self] _ in
                self?.editIcon(at: indexPath)
            }),
            UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                self?.deleteServer(at: indexPath)
            }),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ]
        
        actions.forEach { actionSheet.addAction($0) }
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc
    func addServer() {
        
        let alertController = UIAlertController(title: "Add Server", message: nil, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Add", style: .default, handler: {
            alert -> Void in
            
            guard let context = self.context else { return }
            let server = NSManagedObject(entity: ParseServerConfig.entity(), insertInto: context)
            server.setValue(alertController.textFields![0].text, forKey: "name")
            server.setValue(alertController.textFields![1].text, forKey: "applicationId")
            server.setValue(alertController.textFields![2].text, forKey: "masterKey")
            server.setValue(alertController.textFields![3].text, forKey: "serverUrl")
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            if let config = server as? ParseServerConfig {
                self.servers.append(config)
                let indexPath = IndexPath(row: self.servers.count - 1, section: 0)
                self.collectionView?.insertItems(at: [indexPath])
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
        let server = servers[indexPath.row]
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            server.setValue(alertController.textFields![0].text, forKey: "name")
            server.setValue(alertController.textFields![1].text, forKey: "applicationId")
            server.setValue(alertController.textFields![2].text, forKey: "masterKey")
            server.setValue(alertController.textFields![3].text, forKey: "serverUrl")
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            self.collectionView?.reloadItems(at: [indexPath])
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "App Name"
            textField.text = server.name
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Application ID"
            textField.text = server.applicationId
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Master Key"
            textField.text = server.masterKey
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "http://<url>:<port>/<path>"
            textField.text = server.serverUrl
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func duplicateServer(at indexPath: IndexPath) {
        guard let context = context else { return }
        let server = NSManagedObject(entity: ParseServerConfig.entity(), insertInto: context)
        server.setValue(self.servers[indexPath.row].name, forKey: "name")
        server.setValue(self.servers[indexPath.row].applicationId, forKey: "applicationId")
        server.setValue(self.servers[indexPath.row].masterKey, forKey: "masterKey")
        server.setValue(self.servers[indexPath.row].serverUrl, forKey: "serverUrl")
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        if let server = server as? ParseServerConfig {
            servers.append(server)
            let indexPath = IndexPath(row: servers.count - 1, section: 0)
            collectionView?.insertItems(at: [indexPath])
        }
    }
    
    func deleteServer(at indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "This cannot be undone", preferredStyle: .alert)
        let actions = [
            UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                guard let context = self?.context, let server = self?.servers[indexPath.row] else { return }
                context.delete(server)
                do {
                    try context.save()
                    self?.servers.remove(at: indexPath.row)
                    self?.collectionView?.deleteItems(at: [indexPath])
                    self?.handleSuccess("Server Deleted")
                } catch let error {
                    self?.handleError(error.localizedDescription)
                }
            }),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ]
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true, completion: nil)
    }
}

extension ServersViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: UIImagePickerControllerDelegate
    
    func editIcon(at indexPath: IndexPath) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        selectedIndexPath = indexPath
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let indexPath = selectedIndexPath else { return }
        guard let context = context, let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        let imageData = UIImageJPEGRepresentation(image, 1)
        servers[indexPath.row].setValue(imageData, forKey: "icon")
        do {
            try context.save()
        } catch let error {
            handleError(error.localizedDescription)
        }
        
        defer {
            picker.dismiss(animated: true, completion: { [weak self] in
                self?.collectionView?.reloadItems(at: [indexPath])
                self?.selectedIndexPath = nil
            })
        }
    }
    
}

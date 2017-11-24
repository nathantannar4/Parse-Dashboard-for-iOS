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
import DKImagePickerController

class ServersViewController: PFCollectionViewController {
    
    // MARK: - Properties
    
    private var servers = [ParseServerConfig]()
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
        title = "Parse Dashboard"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Logo")?.scale(to: 30),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(showInfo))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(addServer))
//            UIBarButtonItem(image: UIImage(named: "ic_lock")?.scale(to: 30),
//                            style: .plain,
//                            target: self,
//                            action: #selector(toggleAuthRequired))
        ]
    }
    
    // MARK: - Auth
    
//    private func authenticateUser() {
//
//        guard let isProtected = UserDefaults.standard.value(forKey: .isProtected) as? Bool else {
//            promptAuthSetup(completion: { enabled in
//                if enabled {
//                    self.authenticateWithPassword(completion: { _ in })
//                } else {
//                    self.fetchServersFromCoreData()
//                }
//            })
//            return
//        }
//        if isProtected {
//            // Auth required
//            if BioMetricAuthenticator.canAuthenticate() {
//                authenticateWithBiometrics()
//            } else {
//                authenticateWithPassword(completion: { success in
//                    if success {
//                        self.fetchServersFromCoreData()
//                    } else {
//                        self.handleError("Incorrect Password")
//                    }
//                })
//            }
//        } else {
//            // Auth not required
//            fetchServersFromCoreData()
//        }
//    }
//
//    private func authenticateWithBiometrics() {
//        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "", success: {
//            self.fetchServersFromCoreData()
//        }) { error in
//            if error == .fallback || error == .biometryLockedout {
//                self.au
//            }
//            self.handleError(error.message())
//        }
//    }
//
//    private func authenticateWithPassword(completion: @escaping (Bool)->Void) {
//        let alert = UIAlertController(title: "Authentication", message: "Please enter your password", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//            let password = alert.textFields?.first?.text
//            completion(self.canAuthenticate(with: password))
//        }))
//        alert.addTextField {
//            $0.placeholder = "Password"
//            $0.isSecureTextEntry = true
//        }
//        present(alert, animated: true, completion: nil)
//    }
//
//    private func promptAuthSetup(completion: ((Bool)->Void)?) {
//        let alert = UIAlertController(title: "Security", message: "Do you want to enable server access authentication", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Disable", style: .destructive, handler: { _ in
//            UserDefaults.standard.set(false, forKey: .isProtected)
//            UserDefaults.standard.set(nil, forKey: .password)
//            completion?(false)
//        }))
//        alert.addAction(UIAlertAction(title: "Enable", style: .default, handler: { _ in
//            UserDefaults.standard.set(true, forKey: .isProtected)
//            completion?(true)
//        }))
//        present(alert, animated: true, completion: nil)
//    }
//
//    private func canAuthenticate(with password: String?) -> Bool {
//        guard let password = password else { return false }
//        guard let savedPassword = UserDefaults.standard.value(forKey: .password) as? String else {
//            UserDefaults.standard.set(password, forKey: .password) // Set the initial password
//            return canAuthenticate(with: password)
//        }
//        return password == savedPassword
//    }
//
//    @objc
//    private func toggleAuthRequired() {
//        guard let isProtected = UserDefaults.standard.value(forKey: .isProtected) as? Bool else {
//            authenticateUser()
//            return
//        }
//        if isProtected {
//            authenticateWithPassword(completion: { success in
//                if success {
//                    self.fetchServersFromCoreData()
//                    self.promptAuthSetup(completion: nil)
//                } else {
//                    self.handleError("Incorrect Password")
//                }
//            })
//        } else {
//            if BioMetricAuthenticator.canAuthenticate() {
//                authenticateWithBiometrics()
//            } else {
//                authenticateWithPassword(completion: { _ in })
//            }
//        }
//    }
    
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
            collectionView?.reloadData()
        } catch let error {
            handleError(error.localizedDescription)
        }
    }
    
    // MARK: - User Actions
    
    @objc
    func showInfo() {
        let navigationController = UINavigationController(rootViewController: AppInfoViewController())
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = .logoTint
        navigationController.navigationBar.isTranslucent = false
        present(navigationController, animated: true, completion: nil)
    }
    
    func presentActions(for indexPath: IndexPath) {
        
        let actionSheet = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)
        actionSheet.configureView()
        
        let actions = [
            UIAlertAction(title: "Duplicate", style: .default, handler: { [weak self] _ in
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
        
        let alert = UIAlertController(title: "Add Server", message: nil, preferredStyle: .alert)
        alert.configureView()
        
        let saveAction = UIAlertAction(title: "Add", style: .default, handler: { _ in
            
            guard let context = self.context else { return }
            let server = NSManagedObject(entity: ParseServerConfig.entity(), insertInto: context)
            server.setValue(alert.textFields![0].text, forKey: "name")
            server.setValue(alert.textFields![1].text, forKey: "applicationId")
            server.setValue(alert.textFields![2].text, forKey: "masterKey")
            server.setValue(alert.textFields![3].text, forKey: "serverUrl")
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            if let config = server as? ParseServerConfig {
                self.servers.append(config)
                let indexPath = IndexPath(row: self.servers.count - 1, section: 0)
                self.collectionView?.insertItems(at: [indexPath])
                self.handleSuccess("Server Added")
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.addAction(saveAction)
        
        for placeholder in ["App Name", "Application ID", "Master Key", "Server URL"] {
            alert.addTextField { $0.placeholder = placeholder }
        }
        present(alert, animated: true, completion: nil)
    }
    
    func editServer(at indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Configuration", message: "Edit", preferredStyle: .alert)
        alert.configureView()
        
        let server = servers[indexPath.row]
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { _ in
            
            server.setValue(alert.textFields![0].text, forKey: "name")
            server.setValue(alert.textFields![1].text, forKey: "applicationId")
            server.setValue(alert.textFields![2].text, forKey: "masterKey")
            server.setValue(alert.textFields![3].text, forKey: "serverUrl")
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            self.collectionView?.reloadItems(at: [indexPath])
            self.handleSuccess("Server Updated")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.addAction(saveAction)
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "App Name"
            textField.text = server.name
        }
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Application ID"
            textField.text = server.applicationId
        }
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Master Key"
            textField.text = server.masterKey
        }
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "http://<url>:<port>/<path>"
            textField.text = server.serverUrl
        }
        
        present(alert, animated: true, completion: nil)
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
            self.handleSuccess("Server Duplicated")
        }
    }
    
    func deleteServer(at indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "This cannot be undone", preferredStyle: .alert)
        alert.configureView()
        
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
    
    func editIcon(at indexPath: IndexPath) {
        
        func saveSelection(of image: UIImage?) {
            
            guard let context = self.context else { return }
            let imageData = image != nil ? UIImageJPEGRepresentation(image!, 1) : nil
            self.servers[indexPath.row].setValue(imageData, forKey: "icon")
            do {
                try context.save()
                self.collectionView?.reloadItems(at: [indexPath])
            } catch let error {
                self.handleError(error.localizedDescription)
            }
        }
        
        let picker = DKImagePickerController()
        picker.assetType = .allPhotos
        picker.singleSelect = true
        picker.autoCloseOnSingleSelect = false
        picker.didSelectAssets = { assets in
            guard let asset = assets.first else {
                saveSelection(of: nil)
                return
            }
            asset.fetchOriginalImageWithCompleteBlock({ image, _ in
                saveSelection(of: image)
            })
        }
        picker.navigationBar.isTranslucent = false
        picker.navigationBar.tintColor = .logoTint
        present(picker, animated: true, completion: nil)
    }
}

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
    
    var shouldAnimateFirstLoad = false
    
    private var servers = [ParseServerConfig]()
    private var context: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkBlueBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldAnimateFirstLoad {
            collectionView?.transform = CGAffineTransform(translationX: 0, y: -view.frame.height)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchServersFromCoreData()
        
        if shouldAnimateFirstLoad {
            shouldAnimateFirstLoad = false
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveLinear, animations: {
                self.collectionView?.transform = .identity
            }, completion: nil)
        }
        
        let isNew = UserDefaults.standard.value(forKey: .isNew) as? Bool ?? true
        if isNew {
            setupTutorial()
        }
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Logo")?.scale(to: 30), style: .plain, target: self, action: #selector(showMore))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addServer))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Servers", style: .plain, target: nil, action: nil)
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
        showSchemasForConfig(servers[indexPath.row])
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
    
    func showSchemasForConfig(_ config: ParseServerConfig) {
        Parse.shared.initialize(with: config)
        let schemaViewController = SchemaViewController()
        schemaViewController.title = config.name
        navigationController?.pushViewController(schemaViewController, animated: true)
    }
    
    @objc
    func showMore(atIndex index: Int = 0) {
        
        let viewControllers = [
            UINavigationController(rootViewController: AppInfoViewController()),
            UINavigationController(rootViewController: SupportViewController()),
            UINavigationController(rootViewController: SettingsViewController())
        ]
        let moreController = MoreViewController(viewControllers: viewControllers)
        moreController.modalPresentationStyle = .formSheet
        moreController.displayViewController(at: index, animated: false)
        present(moreController, animated: true, completion: nil)
    }
    
    func presentActions(for indexPath: IndexPath) {
        
        let actionSheet = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)
        actionSheet.configureView()
        
        let actions = [
            UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
                self?.editServer(at: indexPath)
            }),
            UIAlertAction(title: "Duplicate", style: .default, handler: { [weak self] _ in
                self?.duplicateServer(at: indexPath)
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
        let navigationController = UINavigationController(rootViewController: ServerConfigViewController())
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = .logoTint
        navigationController.navigationBar.isTranslucent = false
        present(navigationController, animated: true, completion: nil)
    }
    
    func editServer(at indexPath: IndexPath) {
        let navigationController = UINavigationController(rootViewController: ServerConfigViewController(config: servers[indexPath.row]))
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = .logoTint
        navigationController.navigationBar.isTranslucent = false
        present(navigationController, animated: true, completion: nil)
    }
    
    func duplicateServer(at indexPath: IndexPath) {
        guard let context = context else { return }
        let server = ParseServerConfig(entity: ParseServerConfig.entity(), insertInto: context)
        server.name = servers[indexPath.row].name
        server.applicationId = servers[indexPath.row].applicationId
        server.masterKey = servers[indexPath.row].masterKey
        server.serverUrl = servers[indexPath.row].serverUrl
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        servers.append(server)
        let indexPath = IndexPath(row: servers.count - 1, section: 0)
        collectionView?.insertItems(at: [indexPath])
        self.handleSuccess("Server Duplicated")
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
    
    // MARK: - Tutorial
    
    private func setupTutorial() {
        
        let actionsStack = [
            TutorialAction(text: "Learn more about Parse Dashboard for iOS! See how your data is stored securely, where to find the GitHub repo and how to show your support", sourceItem: navigationItem.leftBarButtonItem),
            TutorialAction(text: "Long press on a cell to edit, duplicate or delete the configuration", sourceView: collectionView),
            TutorialAction(text: "Add a new Parse Server configuration profile", sourceItem: navigationItem.rightBarButtonItem)
        ]
        presentTutorial(for: actionsStack)
    }
    
    func presentTutorial(for actionsStack: [TutorialAction]) {
        var actionsStack = actionsStack
        guard let action = actionsStack.popLast() else {
            UserDefaults.standard.set(false, forKey: .isNew) // Completed Tutorial
            return
        }
        let tutorial = TutorialViewController(action: action)
        tutorial.onContinue = {
            self.presentTutorial(for: actionsStack)
        }
        present(tutorial, animated: true, completion: nil)
    }
}

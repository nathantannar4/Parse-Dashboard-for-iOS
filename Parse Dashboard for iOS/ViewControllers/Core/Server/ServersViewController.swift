//
//  ServersViewController.swift
//  Parse Dashboard for iOS
//
//  Copyright © 2018 Nathan Tannar.
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
//  Created by Nathan Tannar on 4/30/18.
//

import UIKit
import IGListKit
import DynamicTabBarController
import WhatsNew
import EggRating
import CoreData

final class ServersViewController: ListSearchViewController {
    
    // MARK: - Properties
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    private var context: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    // MARK: - Subviews
    
    private lazy var supportButton: RippleButton = {
        let button = RippleButton()
        button.setImage(#imageLiteral(resourceName: "Support"), for: .normal)
        button.setTitle(Localizable.support.localized, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.backgroundColor = .logoTint
        button.addTarget(self, action: #selector(presentSupportViewController), for: .touchUpInside)
        return button
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkBlueBackground
        view.addSubview(supportButton)
        supportButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: UserDefaults.standard.bool(forKey: .isConsoleHidden) ? 80 : 44)
        collectionView.contentInset.bottom = 120
        setupNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadObjectsInBackground()
        if WhatsNew.shouldPresent() {
            let whatsNew = WhatsNewViewController(items: WhatsNewViewController.items)
            whatsNew.applyStyling()
            whatsNew.presentIfNeeded(on: self)
        } else {
            EggRating.promptRateUsIfNeeded(in: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isNew = UserDefaults.standard.value(forKey: .isNew) as? Bool ?? true
        if isNew {
            setupTutorial()
        }
        DispatchQueue.main.async {
            self.adjustConsoleView()
        }
    }
    
    
    func adjustConsoleView() {
        
        let isConsoleHidden = UserDefaults.standard.bool(forKey: .isConsoleHidden)
        if isConsoleHidden && dynamicTabBarController != nil {
            
            // Remove for later possible use
            ConsoleView.shared.removeFromSuperview()
            
            // Switch to no container
            let serversViewController = ServersViewController()
            UIApplication.shared.presentedWindow?.switchRootViewController(
                NavigationController(rootViewController: serversViewController),
                animated: true,
                duration: 0.3,
                options: .transitionCrossDissolve,
                completion: nil)
            
        } else if dynamicTabBarController == nil && !isConsoleHidden {
            
            // Switch to DynamicTabBarController which supports a bottom tray view
            let serversViewController = ServersViewController()
            let container = DynamicTabBarController(viewControllers: [NavigationController(rootViewController: serversViewController)])
            container.tabBar.scrollIndicatorHeight = 0
            container.updateTabBarHeight(to: 0, animated: false)
            
            UIApplication.shared.presentedWindow?.switchRootViewController(
                container,
                animated: true,
                duration: 0.3,
                options: .transitionCrossDissolve,
                completion: nil)
            
        } else if let container = dynamicTabBarController {
            
            container.tabBar.backgroundColor = .black
            container.trayView.backgroundColor = .black
            guard ConsoleView.shared.superview == nil else { return }
            container.trayView.addSubview(ConsoleView.shared)
            ConsoleView.shared.fillSuperview()
            container.showTrayView(withHeight: view.frame.height / 5, withDuration: 0.3, completion: nil)
        }
    }
    
    // MARK: - Networking
    
    override func loadObjectsInBackground() {
        super.loadObjectsInBackground()
        
        defer {
            isLoading = false
            adapter.reloadData(completion: nil)
        }
        
        guard let context = context else { return }
        let request: NSFetchRequest<ParseServerConfig> = ParseServerConfig.fetchRequest()
        do {
            objects = try context.fetch(request)
        } catch let error {
            handleError(error.localizedDescription)
        }
    }
    
    // MARK: - Search Filtering
    
    override func filteredObjects(for text: String) -> [ListDiffable] {
        guard let servers = objects as? [ParseServerConfig] else { return [] }
        return servers.filter {
            let name = $0.name?.lowercased().contains(text.lowercased()) ?? false
            let url = $0.exportableURL?.absoluteString.lowercased().contains(text.lowercased()) ?? false
            return name || url
        }
    }
    
    // MARK: - Setup
    
    private func setupNavigationItem() {
        
        title = "Parse Dashboard for iOS"
        subtitle = "Servers"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Logo")?.scale(to: 30), style: .plain, target: self, action: #selector(presentMoreViewController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewServer))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: Localizable.servers.localized, style: .plain, target: nil, action: nil)
    }

    // MARK: - User Actions
    
    override func presentActions(for object: ListDiffable) {
        guard let config = object as? ParseServerConfig else { return }
        let actions = [
            ActionSheetAction(title: Localizable.edit.localized, image: #imageLiteral(resourceName: "Edit"), style: .default, callback: { [weak self] _ in
                self?.editServer(config: config)
            }),
            ActionSheetAction(title: Localizable.duplicate.localized, image: #imageLiteral(resourceName: "Copy"), style: .default, callback: { [weak self] _ in
                self?.duplicateServer(config: config)
            }),
            ActionSheetAction(title: Localizable.export.localized, image: #imageLiteral(resourceName: "Share"), style: .default, callback: { [weak self] _ in
                self?.exportServer(config: config)
            }),
            ActionSheetAction(title: Localizable.delete.localized, image: #imageLiteral(resourceName: "Delete"), style: .destructive, callback: { [weak self] _ in
                self?.deleteServer(config: config)
            })
        ]
        let actionSheetController = ActionSheetController(title: Localizable.actions.localized, message: config.name, actions: actions)
        present(actionSheetController, animated: true, completion: nil)
    }
    
    @objc
    func presentMoreViewController() {
        let viewControllers = [AppInfoViewController(), SupportViewController(), SettingsViewController()]
        let tabBarController = TabBarController(viewControllers: viewControllers)
        let navigationController = NavigationController(rootViewController: tabBarController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc
    func presentSupportViewController() {
        let viewControllers = [SupportViewController()]
        let tabBarController = TabBarController(viewControllers: viewControllers)
        let navigationController = NavigationController(rootViewController: tabBarController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc
    func addNewServer() {
        let navigationController = NavigationController(rootViewController: ServerConfigViewController())
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - ParseServerConfig Management
    
    private func editServer(config: ParseServerConfig) {
        let navigationController = NavigationController(rootViewController: ServerConfigViewController(editing: config))
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
    
    private func duplicateServer(config: ParseServerConfig) {
        guard let context = context else { return }
        let server = ParseServerConfig(entity: ParseServerConfig.entity(), insertInto: context)
        server.name = config.name
        server.applicationId = config.applicationId
        server.masterKey = config.masterKey
        server.serverUrl = config.serverUrl
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        loadObjectsInBackground()
        handleSuccess("Server Duplicated")
    }
    
    private func exportServer(config: ParseServerConfig) {
        
        // Expected Format for config import
        // parsedashboard://<applicationId>:<masterKey>@<url>:<port>/<path>
        
        guard let cell = adapter.sectionController(for: config)?.cellForItem(at: 0) else { return }

        guard let url = config.exportableURL else {
            handleError("Sorry, that configuration is invalid and cannot be exported")
            return
        }
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activity.popoverPresentationController?.canOverlapSourceViewRect = true
        activity.popoverPresentationController?.sourceView = cell
        activity.popoverPresentationController?.sourceRect = cell.bounds
        present(activity, animated: true, completion: nil)
    }
    
    private func deleteServer(config: ParseServerConfig) {
        
        guard let context = context else { return }
        context.delete(config)
        do {
            try context.save()
            loadObjectsInBackground()
            handleSuccess("Server Deleted")
        } catch let error {
            handleError(error.localizedDescription)
        }
    }
    
    // MARK: - Tutorial
    
    private func setupTutorial() {
        
        let actionsStack = [
            TutorialAction(text: "Learn more about Parse Dashboard for iOS! See how your data is stored securely, where to find the GitHub repo and how to show your support", sourceItem: navigationItem.leftBarButtonItem),
            TutorialAction(text: "If you enjoy this app please consider making a donation!", sourceItem: navigationItem.leftBarButtonItem),
            TutorialAction(text: "Long press on a cell for additional actions", sourceView: collectionView),
            TutorialAction(text: "Add a new Parse Server configuration", sourceItem: navigationItem.rightBarButtonItem)
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
        tutorial.onContinue = { [weak self] in
            self?.presentTutorial(for: actionsStack)
        }
        present(tutorial, animated: true, completion: nil)
    }
    
}

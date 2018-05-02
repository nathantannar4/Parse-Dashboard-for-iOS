//
//  SchemaViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 4/29/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit
import IGListKit

final class SchemaViewController: ListSearchViewController {
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightBlueBackground
        setupNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupToolbar()
        navigationController?.setToolbarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    // MARK: - Networking
    
    override func loadObjectsInBackground() {
        super.loadObjectsInBackground()
        
        ParseLite.shared.get("/schemas") { [weak self] (result, json) in
            defer { self?.isLoading = false }
            guard result.success else {
                self?.handleError(result.error)
                return
            }
            guard let results = json?["results"] as? [[String: AnyObject]] else {
                return
            }
            self?.objects = results.map { return PFSchema($0) }
        }
    }
    
    // MARK: - Search Filtering
    
    override func filteredObjects(for text: String) -> [ListDiffable] {
        guard let schemas = objects as? [PFSchema] else { return [] }
        return schemas.filter { $0.name.lowercased().contains(text.lowercased()) }
    }
    
    // MARK: - Setup
    
    private func setupNavigationItem() {
    
        title = ParseLite.shared.currentConfiguration?.name ?? "Current Configuration"
        subtitle = "Classes"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(createNewSchema)),
            UIBarButtonItem(image: UIImage(named: "Info")?.scale(to: 30),
                            style: .plain,
                            target: self,
                            action: #selector(presentServerInfoController))
        ]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Classes", style: .plain, target: nil, action: nil)
    }
    
    private func setupToolbar() {
        
        navigationController?.toolbar.isTranslucent = false
        navigationController?.toolbar.barTintColor = .white
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil), UIBarButtonItem(customView: CloudCodeItemView(target: self, action: #selector(presentCloudCodeController)))]
    }
    
    // MARK: - User Actions
    
    @objc
    func createNewSchema() {
        
        let action = ActionSheetAction(title: "Create", style: .default) { [weak self] classname in
            guard let classname = (classname as? String)?.replacingOccurrences(of: " ", with: "_") else { return }
            self?.isLoading = true
            ParseLite.shared.post("/schemas/" + classname, completion: { (result, json) in
                
                guard result.success else {
                    self?.handleError(result.error)
                    self?.isLoading = false
                    return
                }
                self?.handleSuccess("Class Created")
                self?.loadObjectsInBackground()
            })
        }
        let alertPromptViewController = AlertPromptViewController(title: "Create Class", initialValue: nil, placeholder: "Classname", action: action)
        present(alertPromptViewController, animated: true, completion: nil)
    }
    
    @objc
    func presentServerInfoController() {
        
        ParseLite.shared.get("/serverInfo") { [weak self] (result, json) in
            guard result.success, let json = json else {
                self?.handleError(result.error)
                return
            }
            let server = PFServer(json)
            let viewController = ServerDetailViewController(server)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc
    func presentCloudCodeController() {
        
        let navigationController = NavigationController(rootViewController: CloudCodeViewController())
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
    
    override func presentActions(for object: ListDiffable) {
        
        guard let schema = object as? PFSchema else { return }
        let actions = [
            ActionSheetAction(title: "Details", image: #imageLiteral(resourceName: "Details"), style: .default, callback: { [weak self] _ in
                self?.presentDetails(of: schema)
            }),
            ActionSheetAction(title: Localizable.delete.localized, image: #imageLiteral(resourceName: "Delete"), style: .destructive, callback: { [weak self] _ in
                self?.deleteSchema(schema)
            })
        ]
        let actionSheetController = ActionSheetController(title: Localizable.actions.localized, message: schema.name, actions: actions)
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func presentDetails(of schema: PFSchema) {
        let detailViewController = SchemaDetailViewController(schema)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func deleteSchema(_ schema: PFSchema) {
        
        isLoading = true
        ParseLite.shared.delete("/schemas/" + schema.name) { [weak self] (result, json) in
            if result.success {
                if let index = self?.objects.index(where: {
                    return $0.isEqual(toDiffableObject: schema)
                }) {
                    self?.objects.remove(at: index)
                    self?.isLoading = false
                } else {
                    self?.loadObjectsInBackground()
                }
            } else {
                let errorCode = json?["code"] as? Int ?? -1
                if errorCode == 255 {
                    // Objects Still Exist in Schema
                    self?.promtToDeleteAllObjects(in: schema)
                } else {
                    self?.handleError(result.error)
                    self?.isLoading = false
                }
            }
        }
    }
    
    func promtToDeleteAllObjects(in schema: PFSchema) {
        
        let action = ActionSheetAction(title: Localizable.delete.localized, style: .destructive) { _ in
            ParseLite.shared.get("/classes/" + schema.name, completion: { [weak self] (result, json) in
                
                guard result.success, let results = json?["results"] as? [[String: AnyObject]] else {
                    self?.handleError(result.error)
                    return
                }
                self?.handleSuccess("Deleting objects in \(schema.name)")
                var remainingDeletions = results.count
                for result in results {
                    if let id = result[.objectId] as? String {
                        ParseLite.shared.delete("/classes/\(schema.name)/\(id)", completion: { [weak self] (result, json) in
                            if result.success {
                                remainingDeletions -= 1
                                if remainingDeletions == 0 {
                                    // Retry to delete the schema
                                    self?.deleteSchema(schema)
                                }
                            } else {
                                self?.handleError(result.error)
                            }
                        })
                    }
                }
            })
        }
        let alertViewController = AlertViewController(title: "WARNING: \(schema.name) contains objects", message: "Delete ALL objects and class?", action: action)
        present(alertViewController, animated: true, completion: nil)
    }
    
}

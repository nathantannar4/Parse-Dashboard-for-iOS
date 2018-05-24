//
//  ClassViewController.swift
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
//  Created by Nathan Tannar on 4/29/18.
//

import UIKit
import IGListKit

final class ClassViewController: ListSearchViewController {
    
    // MARK: - Properties
    
    let schema: PFSchema
    
    var query = "limit=1000&order=-updatedAt"
    
    fileprivate var searchKey: String = .objectId
    
    // MARK: - Initialization
    
    init(for schema: PFSchema) {
        self.schema = schema
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkPurpleBackground
        setupNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if schema.name == "_User" {
            setupToolbar()
            navigationController?.setToolbarHidden(false, animated: animated)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.viewControllers.last == self {
            navigationController?.setToolbarHidden(true, animated: animated)
        }
    }
    
    // MARK: - Networking
    
    override func loadObjectsInBackground() {
        super.loadObjectsInBackground()
        
        ParseLite.shared.get("/classes/" + schema.name, query: "?" + query) { [weak self] (result, json) in
            defer { self?.isLoading = false }
            
            guard result.success else {
                self?.handleError(result.error)
                return
            }
            guard let results = json?["results"] as? [[String: AnyObject]] else { return }
            if results.count == 1 {
                self?.subtitle = "1 Objects"
            } else {
                self?.subtitle = "\(results.count) Objects"
            }
            self?.objects = results.map {
                let object = ParseLiteObject($0, schema: self?.schema)
                object.displayKey = self?.searchKey ?? .objectId
                return object
            }
        }
    }
    
    // MARK: - Search Filtering
    
    override func filteredObjects(for text: String) -> [ListDiffable] {
        guard let objects = objects as? [ParseLiteObject] else { return [] }
        return objects.filter {
            var contains = $0.id.lowercased().contains(text.lowercased())
            contains = $0.createdAt.lowercased().contains(text.lowercased()) || contains
            contains = $0.updatedAt.lowercased().contains(text.lowercased()) || contains
            if contains { return true }
            for key in $0.keys {
                if let value = $0.value(forKey: key) as? String {
                    let contains = value.lowercased().contains(text.lowercased())
                    if contains { return true }
                }
            }
            return false
        }
    }
    
    // MARK: - Setup
    
    func setupNavigationItem() {
        
        title = schema.name
        subtitle = "0 Objects"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(createNewObject)),
            UIBarButtonItem(image: UIImage(named: "Filter"),
                            style: .plain,
                            target: self,
                            action: #selector(presentQueryFilterController(sender:)))
        ]
    }
    
    func setupToolbar() {
        
        navigationController?.toolbar.isTranslucent = false
        navigationController?.toolbar.barTintColor = .darkPurpleAccent
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil), UIBarButtonItem(customView: PushNotificationItemView(target: self, action: #selector(presentPushNotificationController)))]
    }
    
    // MARK: - User Actions
    
    @objc
    func createNewObject() {
        let viewController = ObjectBuilderViewController(for: schema)
        let navigationController = NavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc
    func presentQueryFilterController(sender: AnyObject) {
        let queryVC = QueryViewController(schema, searchKey: searchKey, query: query)
        queryVC.delegate = self
        let navVC = NavigationController(rootViewController: queryVC)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navVC.modalPresentationStyle = .popover
            navVC.popoverPresentationController?.permittedArrowDirections = .up
            navVC.popoverPresentationController?.delegate = self
            navVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.last
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            navVC.modalPresentationStyle = .formSheet
        }
        present(navVC, animated: true, completion: nil)
    }
    
    @objc
    func presentPushNotificationController() {
        let objects = adapter.objects().compactMap { return $0 as? ParseLiteObject }
        let pushNotificationController = PushNotificationController(for: objects)
        present(pushNotificationController, animated: true, completion: nil)
    }
    
    override func presentActions(for object: ListDiffable) {
        
        guard let parseObject = object as? ParseLiteObject else { return }
        let actions = [
            ActionSheetAction(title: Localizable.delete.localized, image: #imageLiteral(resourceName: "Delete"), style: .destructive, callback: { [weak self] _ in
                self?.deleteObject(parseObject)
            })
        ]
        let actionSheetController = ActionSheetController(title: Localizable.actions.localized, message: schema.name, actions: actions)
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func deleteObject(_ object: ParseLiteObject) {
        
        isLoading = true
        ParseLite.shared.delete("/classes/\(schema.name)/\(object.id)", completion: { [weak self] (result, json) in
            
            guard result.success else {
                self?.handleError(result.error)
                self?.isLoading = false
                return
            }
            self?.handleSuccess("Object \(object.id) deleted")
            if let index = self?.objects.index(where: {
                return $0.isEqual(toDiffableObject: object)
            }) {
                self?.objects.remove(at: index)
                self?.isLoading = false
            } else {
                self?.loadObjectsInBackground()
            }
        })
    }

}

// MARK: - UIPopoverPresentationControllerDelegate
extension ClassViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - QueryDelegate
extension ClassViewController: QueryDelegate {
    
    func query(didChangeWith query: String, searchKey: String) {
        if self.query != query {
            self.query = query
            self.searchKey = searchKey
            loadObjectsInBackground()
        } else {
            self.searchKey = searchKey
            guard let parseObjects = objects as? [ParseLiteObject] else { return }
            parseObjects.forEach { $0.displayKey = searchKey }
            adapter.reloadData(completion: nil)
        }
    }
    
}

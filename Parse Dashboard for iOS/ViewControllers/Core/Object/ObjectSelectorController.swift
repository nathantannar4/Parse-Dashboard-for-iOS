//
//  ObjectSelectorViewController.swift
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
//  Created by Nathan Tannar on 12/17/17.
//

import UIKit
import IGListKit
import AlertHUDKit

protocol ObjectSelectorViewControllerDelegate: AnyObject {
    
    func objectSelector(_ viewController: ObjectSelectorViewController, didSelect object: ParseLiteObject, for key: String)
}

final class ObjectSelectorViewController: ListSearchViewController, UICollectionViewDelegate {
    
    // MARK: - Properties
    
    let schema: PFSchema
    
    var query = "limit=1000&order=-updatedAt"
    
    weak var delegate: ObjectSelectorViewControllerDelegate?
    
    fileprivate var searchKey: String = .objectId
    
    private let selectionKey: String
    
    private weak var previousViewController: UIViewController?
    
    // MARK: - Initialization
    
    init(selecting key: String, in schema: PFSchema) {
        self.schema = schema
        self.selectionKey = key
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkPurpleBackground
        setupNavigationItem()
        title = schema.name
        adapter.collectionViewDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Toast(text: "Select an object to assign to key `\(selectionKey)`").present(self, animated: true, duration: 5)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        if let controllers = (parent as? UINavigationController)?.viewControllers {
            previousViewController = controllers[controllers.count - 2]
        } else {
            if previousViewController is ObjectViewController {
                navigationController?.navigationBar.tintColor = .logoTint
                navigationController?.navigationBar.barTintColor = .white
            } else if previousViewController is ObjectBuilderViewController {
                navigationController?.navigationBar.tintColor = .white
                navigationController?.navigationBar.barTintColor = .darkPurpleBackground
            }
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
            self?.objects = results.map {
                let object = ParseLiteObject($0, schema: self?.schema)
                object.displayKey = self?.searchKey ?? .objectId
                return object
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sectionController = super.listAdapter(listAdapter, sectionControllerFor: object)
        if let classSectionController = sectionController as? ClassSectionController {
            classSectionController.presentOnSelection = false
        }
        return sectionController
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let object = adapter.object(atSection: indexPath.section) as? ParseLiteObject else { return }
        delegate?.objectSelector(self, didSelect: object, for: selectionKey)
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
        
        navigationController?.navigationBar.tintColor = .logoTint
        navigationController?.navigationBar.barTintColor = .white
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "Filter"),
                            style: .plain,
                            target: self,
                            action: #selector(presentQueryFilterController(sender:)))
        ]
    }
    
    // MARK: - User Actions
    
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
    
}

// MARK: - UIPopoverPresentationControllerDelegate
extension ObjectSelectorViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - QueryDelegate
extension ObjectSelectorViewController: QueryDelegate {
    
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

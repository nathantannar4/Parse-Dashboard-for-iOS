//
//  ClassViewController.swift
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
//  Created by Nathan Tannar on 8/31/17.
//

import UIKit

class ClassViewController: PFCollectionViewController, QueryDelegate {
    
    // MARK: - Properties
    
    var query = "limit=1000&order=-updatedAt"
    
    private var schema: PFSchema
    
    private var objects = [PFObject]()
    private var filteredObjects = [PFObject]()
    
    fileprivate var searchKey: String = .objectId
    
    private lazy var searchController: UISearchController = { [weak self] in
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.tintColor = .logoTint
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        return searchController
    }()
    
    
    // MARK: - Initialization
    
    init(_ schema: PFSchema) {
        self.schema = schema
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleRefresh()
    }
    
    // MARK: - Data Refresh
    
    @objc
    override func handleRefresh() {
        
        guard !isFiltering() else { return refreshControl.endRefreshing() }
        objects.removeAll()
        if collectionView?.numberOfSections != 0 {
            collectionView?.deleteSections([0])
        }
        Parse.shared.get("/classes/" + schema.name, query: "?" + query) { [weak self] (result, json) in
            guard result.success else {
                self?.handleError(result.error)
                self?.refreshControl.endRefreshing()
                return
            }
            guard let results = json?["results"] as? [[String: AnyObject]] else {
                self?.refreshControl.endRefreshing()
                return
            }
            self?.objects = results.map {
                let newObject = PFObject($0)
                newObject.schema = self?.schema
                return newObject
            }
            if results.count > 0 {
                self?.collectionView?.insertSections([0])
            }
            self?.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Setup
    
    override func setupCollectionView() {
        super.setupCollectionView()
        
        collectionView?.backgroundColor = .darkPurpleBackground
        collectionView?.register(ClassCell.self, forCellWithReuseIdentifier: ClassCell.reuseIdentifier)
        addRefreshControl()
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        title = schema.name
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(addObject)),
            UIBarButtonItem(image: UIImage(named: "Filter"),
                            style: .plain,
                            target: self,
                            action: #selector(modifyQuery(sender:)))
        ]
    }
    
    // MARK: - User Actions
    
    @objc
    func addObject() {
        
        let alert = UIAlertController(title: "Create Object", message: nil, preferredStyle: .alert)
        alert.configureView()
        
        let saveAction = UIAlertAction(title: "Create", style: .default, handler: { [weak self] _ in
            
            guard let classname = self?.schema.name, let body = alert.textFields?.first?.text else { return }
            Parse.shared.post("/classes/" + classname, body: body, completion: { [weak self] (result, json) in
                guard result.success, let json = json else {
                    self?.handleError(result.error)
                    return
                }
                let newObject = PFObject(json)
                newObject.schema = self?.schema
                self?.objects.insert(newObject, at: 0)
                self?.handleSuccess("Object Created")
                if self?.collectionView?.numberOfSections == 0 {
                    self?.collectionView?.insertSections([0])
                } else {
                    self?.collectionView?.insertItems(at: [IndexPath(row: 0, section: 0)])
                }
            })
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.addAction(saveAction)
        alert.addTextField { $0.placeholder = "POST Body" }
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    func modifyQuery(sender: AnyObject) {
        
        let queryVC = QueryViewController(schema, searchKey: searchKey, query: query)
        queryVC.delegate = self
        
        let navVC = UINavigationController(rootViewController: queryVC)
        navVC.navigationBar.isTranslucent = false
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
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = isFiltering() ? filteredObjects.count : objects.count
        return count > 0 ? 1 : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFiltering() ? filteredObjects.count : objects.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClassCell.reuseIdentifier, for: indexPath) as! ClassCell
        cell.object = isFiltering() ? filteredObjects[indexPath.row] : objects[indexPath.row]
        cell.searchKey = searchKey
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let insets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let size = CGSize(width: collectionView.bounds.width, height: 80)
        return CGSize(width: size.width - insets.left - insets.right, height: size.height - insets.top - insets.bottom)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = ObjectViewController(objects[indexPath.row])
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didLongSelectItemAt indexPath: IndexPath) {
        presentActions(for: indexPath)
    }
  
    // MARK: - User Actions
    
    func presentActions(for indexPath: IndexPath) {
        
        let actionSheet = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)
        actionSheet.configureView()
        
        let actions = [
            UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                self?.deleteObject(at: indexPath)
            }),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ]
        
        actions.forEach { actionSheet.addAction($0) }
        present(actionSheet, animated: true, completion: nil)
    }
        
    func deleteObject(at indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "This cannot be undone", preferredStyle: .alert)
        alert.configureView()
        
        let actions = [
            UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                
                guard let classname = self?.schema.name, let id = self?.objects[indexPath.row].id else { return }
                Parse.shared.delete("/classes/\(classname)/\(id)", completion: { [weak self] (result, json) in
                    guard result.success else {
                        self?.handleError(result.error)
                        return
                    }
                    self?.handleSuccess("Object \(id) deleted")
                    self?.objects.remove(at: indexPath.row)
                    if self?.objects.count == 0 {
                        self?.collectionView?.deleteSections([0])
                    } else {
                        self?.collectionView?.deleteItems(at: [indexPath])
                    }
                })
            }),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
            ]
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true, completion: nil)
    }
   
    // MARK: - QueryDelegate
    
    func query(didChangeWith query: String, searchKey: String) {
        if self.query != query {
            self.query = query
            self.searchKey = searchKey
            handleRefresh()
        } else {
            self.searchKey = searchKey
            collectionView?.reloadData()
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ClassViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension ClassViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    
    // MARK: - UISearchResultsUpdating
    
    open func updateSearchResults(for searchController: UISearchController) {
        filterObjects(for: searchController.searchBar.text)
    }
    
    private func isFiltering() -> Bool {
        return !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    open func filterObjects(for searchText: String?) {
        guard let searchText = searchText else { return }
        filteredObjects = objects.filter {
            guard let key = $0.value(forKey: searchKey) as? String else { return true }
            return key.lowercased().contains(searchText.lowercased()) || searchText.isEmpty
        }
        collectionView?.reloadData()
    }
}


//
//  SchemaViewController.swift
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

class SchemaViewController: PFCollectionViewController {
    
    // MARK: - Properties
    
    private var schemas = [PFSchema]()
    private var filteredSchemas = [PFSchema]()
    
    private lazy var searchController: UISearchController = { [weak self] in
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.placeholder = Localizable.search.localized + " Classes"
        searchController.searchBar.tintColor = .logoTint
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        return searchController
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightBlueBackground
        handleRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
        setupToolbar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    // MARK: - Data Refresh
    
    @objc
    override func handleRefresh() {
    
        guard !isFiltering() else { return refreshControl.endRefreshing() }
        schemas.removeAll()
        if collectionView?.numberOfSections != 0 {
            collectionView?.deleteSections([0])
        }
        ParseLite.shared.get("/schemas") { [weak self] (result, json) in
            guard result.success else {
                self?.handleError(result.error)
                self?.refreshControl.endRefreshing()
                return
            }
            guard let results = json?["results"] as? [[String: AnyObject]] else {
                self?.refreshControl.endRefreshing()
                return
            }
            self?.refreshControl.endRefreshing()
            self?.schemas = results.map { return PFSchema($0) }
            if results.count > 0 {
                self?.collectionView?.insertSections([0])
            }
        }
    }
    
    // MARK: - Override Setup
    
    override func setupCollectionView() {
        super.setupCollectionView()
        
        collectionView?.backgroundColor = .lightBlueBackground
        collectionView?.register(SchemaCell.self, forCellWithReuseIdentifier: SchemaCell.reuseIdentifier)
        addRefreshControl()
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(addSchema)),
            UIBarButtonItem(image: UIImage(named: "Info")?.scale(to: 30),
                            style: .plain,
                            target: self,
                            action: #selector(showServerInfo))
        ]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Classes", style: .plain, target: nil, action: nil)
    }
    
    private func setupToolbar() {
        
        navigationController?.toolbar.isTranslucent = false
        navigationController?.toolbar.barTintColor = .white
        var items = [UIBarButtonItem]()
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        )
        let codeItem: UIBarButtonItem = {
            let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
            label.text = "Execute Cloud Code"
            label.textColor = .logoTint
            label.font = UIFont.boldSystemFont(ofSize: 12)
            label.textAlignment = .right
            contentView.addSubview(label)
            let imageView = UIImageView(frame: CGRect(x: 150, y: 5, width: 50, height: 30))
            imageView.image = UIImage(named: "CloudCode")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .logoTint
            imageView.contentMode = .scaleAspectFit
            contentView.addSubview(imageView)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showCloudCodeController))
            contentView.addGestureRecognizer(tapGesture)
            return UIBarButtonItem(customView: contentView)
        }()
        items.append(codeItem)
        toolbarItems = items
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = isFiltering() ? filteredSchemas.count : schemas.count
        return count > 0 ? 1 : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFiltering() ? filteredSchemas.count : schemas.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SchemaCell.reuseIdentifier, for: indexPath) as! SchemaCell
        cell.schema = isFiltering() ? filteredSchemas[indexPath.row] : schemas[indexPath.row]
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = isFiltering() ? filteredSchemas[indexPath.row] : schemas[indexPath.row]
        let viewController = ClassViewController(object)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didLongSelectItemAt indexPath: IndexPath) {
        presentActions(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let insets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let size = CGSize(width: collectionView.bounds.width, height: 48)
        return CGSize(width: size.width - insets.left - insets.right, height: size.height - insets.top - insets.bottom)
    }
    
    // MARK: - User Actions
    
    @objc
    func showServerInfo() {
        ParseLite.shared.get("/serverInfo") { [weak self] (result, json) in
            guard result.success, let json = json else {
                self?.handleError(result.error)
                return
            }
            
            let server = PFServer(json)
            let viewController = ServerDetailViewController(server)
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .formSheet
            self?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @objc
    func showCloudCodeController() {
        
        let navigationController = UINavigationController(rootViewController: CloudCodeViewController())
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - User Actions
    
    func presentActions(for indexPath: IndexPath) {
        
        guard let cell = collectionView?.cellForItem(at: indexPath) else { return }
        
        let actionSheet = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)
        actionSheet.configureView()
        
        let actions = [
            UIAlertAction(title: "Details", style: .default, handler: { [weak self] _ in
                self?.showSchemaDetails(at: indexPath)
            }),
            UIAlertAction(title: Localizable.delete.localized, style: .destructive, handler: { [weak self] _ in
                self?.promptDeleteSchema(at: indexPath)
            }),
            UIAlertAction(title: Localizable.cancel.localized, style: .cancel, handler: nil)
        ]
        
        actions.forEach { actionSheet.addAction($0) }
        actionSheet.popoverPresentationController?.canOverlapSourceViewRect = true
        actionSheet.popoverPresentationController?.sourceView = cell
        actionSheet.popoverPresentationController?.sourceRect = cell.bounds
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc
    func addSchema() {
        
        let alert = UIAlertController(title: "Create Class", message: nil, preferredStyle: .alert)
        alert.configureView()
        
        let createAction = UIAlertAction(title: "Create", style: .default, handler: { [weak self] _ in
            
            guard let classname = alert.textFields?.first?.text?.replacingOccurrences(of: " ", with: "_") else { return }
            ParseLite.shared.post("/schemas/" + classname, completion: { (result, json) in
                guard result.success, let json = json else {
                    self?.handleError(result.error)
                    return
                }
                self?.schemas.insert(PFSchema(json), at: 0)
                self?.handleSuccess("Class Created")
                if self?.schemas.count == 1 {
                    self?.collectionView?.insertSections([0])
                } else {
                    self?.collectionView?.insertItems(at: [IndexPath(row: 0, section: 0)])
                }
            })
        })
        
        alert.addAction(UIAlertAction(title: Localizable.cancel.localized, style: .destructive, handler: nil))
        alert.addAction(createAction)
        alert.addTextField { $0.placeholder = "Classname" }
        present(alert, animated: true, completion: nil)
    }
    
    func showSchemaDetails(at indexPath: IndexPath) {
        let schema = isFiltering() ? filteredSchemas[indexPath.row] : schemas[indexPath.row]
        let viewController = SchemaDetailViewController(schema)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func promptDeleteSchema(at indexPath: IndexPath) {
        
        let schema = isFiltering() ? filteredSchemas[indexPath.row] : schemas[indexPath.row]
        
        let alert = UIAlertController(title: "Delete \(schema.name)?", message: "This cannot be undone", preferredStyle: .alert)
        alert.configureView()
        
        let actions = [
            UIAlertAction(title: Localizable.delete.localized, style: .destructive, handler: { [weak self] _ in
                self?.deleteSchema(at: indexPath)
            }),
            UIAlertAction(title: Localizable.cancel.localized, style: .cancel, handler: nil)
            ]
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true, completion: nil)
        
    }
    
    func deleteSchema(at indexPath: IndexPath) {
        
        let schema = isFiltering() ? filteredSchemas[indexPath.row] : schemas[indexPath.row]
        ParseLite.shared.delete("/schemas/" + schema.name) { [weak self] (result, json) in
            if result.success {
                self?.handleSuccess("Class `\(schema.name)` deleted")
                if self?.isFiltering() == true {
                    self?.filteredSchemas.remove(at: indexPath.row)
                    if self?.filteredSchemas.count == 0 {
                        self?.collectionView?.deleteSections([indexPath.section])
                    } else {
                        self?.collectionView?.deleteItems(at: [indexPath])
                    }
                } else {
                    self?.schemas.remove(at: indexPath.row)
                    if self?.schemas.count == 0 {
                        self?.collectionView?.deleteSections([indexPath.section])
                    } else {
                        self?.collectionView?.deleteItems(at: [indexPath])
                    }
                }
            } else {
                let errorCode = json?["code"] as? Int ?? -1
                if errorCode == 255 {
                    // Objects Still Exist in Schema
                    self?.deleteAllObjectsInSchema(at: indexPath)
                } else {
                    self?.handleError(result.error)
                }
            }
        }
    }
        
    func deleteAllObjectsInSchema(at indexPath: IndexPath) {
        
        let schema = isFiltering() ? filteredSchemas[indexPath.row] : schemas[indexPath.row]
        
        let alert = UIAlertController(title: "WARNING: \(schema.name) contains objects", message: "Delete ALL objects and class?", preferredStyle: .alert)
        alert.configureView()
        
        let deleteAction = UIAlertAction(title: Localizable.delete.localized, style: .destructive, handler: { [weak self] _ in
            
            ParseLite.shared.get("/classes/" + schema.name, completion: { [weak self] (result, json) in
                
                guard result.success, let results = json?["results"] as? [[String: AnyObject]] else {
                    self?.handleError(result.error)
                    return
                }
                self?.handleSuccess("Deleting objects in \(schema.name)")
                for result in results {
                    if let id = result[.objectId] as? String {
                        ParseLite.shared.delete("/classes/\(schema.name)/\(id)", completion: { _,_  in })
                    }
                }
                // Retry to delete the schema after a delay
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                    self?.deleteSchema(at: indexPath)
                })
            })
        })
        
        alert.addAction(UIAlertAction(title: Localizable.cancel.localized, style: .default, handler: nil))
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
    
}

extension SchemaViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    
    // MARK: - UISearchResultsUpdating
    
    open func updateSearchResults(for searchController: UISearchController) {
        filterObjects(for: searchController.searchBar.text)
    }
    
    private func isFiltering() -> Bool {
        return !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    open func filterObjects(for searchText: String?) {
        guard let searchText = searchText else { return }
        filteredSchemas = schemas.filter {
            let text = $0.name.lowercased()
            return text.contains(searchText.lowercased()) || searchText.isEmpty
        }
        collectionView?.reloadData()
    }
}

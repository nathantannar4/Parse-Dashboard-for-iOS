//
//  IGListViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 3/8/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit
import IGListKit
import AlertHUDKit

class ListSearchViewController: ViewController, ListAdapterDataSource, SearchSectionControllerDelegate, UIScrollViewDelegate {
    
    // MARK: - Properties
    
    var objects: [ListDiffable] = []
    
    private var filteredObjects: [ListDiffable] = []
    
    private(set) var filterText: String = ""
    
    var isLoading: Bool = true {
        didSet {
            adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
    var isFiltering: Bool = false {
        didSet {
            adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private let searchToken: NSNumber = 10
    
    private let spinnerToken: NSNumber = 20
    
    // MARK: - Subviews
    
    let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.contentInset.bottom = 60
        view.backgroundColor = .clear
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        
        let rc = UIRefreshControl()
        rc.tintColor = .black
        rc.attributedTitle = NSAttributedString(string: "Pull to Refresh", attributes: [.foregroundColor : UIColor.darkGray, .font: UIFont.boldSystemFont(ofSize: 12)])
        rc.addTarget(self, action: #selector(loadObjectsInBackground), for: .valueChanged)
        collectionView.refreshControl = rc
        
        NotificationCenter.default.addObserver(self, selector: #selector(invalidateLayout), name: .UIDeviceOrientationDidChange, object: nil)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(for:)))
        longPress.minimumPressDuration = 0.75
        collectionView.addGestureRecognizer(longPress)
        
        loadObjectsInBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.backgroundColor = view.backgroundColor
        if collectionView.contentOffset.y > 0 {
            applyShadowToNavigationBar()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearShadowFromNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @objc
    final func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc
    final func handleLongPress(for gesture : UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            if let object = adapter.object(atSection: indexPath.section) as? ListDiffable {
                generateFeedback()
                presentActions(for: object)
            }
        }
    }
    
    func presentActions(for object: ListDiffable) {
        // Should be overridden
    }
    
    // MARK: - Networking
    
    @objc
    func loadObjectsInBackground() {
        collectionView.refreshControl?.endRefreshing()
        isLoading = true
    }
    
    // MARK: - Search
    
    func filteredObjects(for text: String) -> [ListDiffable] {
        // Should be overridden
        return []
    }
    
    // MARK: - ListAdapterDataSource
    
    final func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        if isLoading {
            return [searchToken, spinnerToken]
        } else if isFiltering {
            return [searchToken] + filteredObjects
        }
        return [searchToken] + objects
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let num = object as? NSNumber, num == searchToken {
            let sectionController = SearchSectionController()
            sectionController.delegate = self
            return sectionController
        } else if let num = object as? NSNumber, num == spinnerToken {
            return SpinnerSectionController()
        } else if object is ParseServerConfig {
            return ServerSectionController()
        } else if object is PFSchema {
            return SchemaSectionController()
        } else if object is ParseLiteObject {
            return ClassSectionController()
        }
        fatalError()
    }
    
    final func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    // MARK: - SearchSectionControllerDelegate
    
    func searchSectionController(_ sectionController: SearchSectionController, didChangeText text: String) {
        filteredObjects = filteredObjects(for: text)
        isFiltering = !text.isEmpty
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            clearShadowFromNavigationBar()
        } else {
            applyShadowToNavigationBar()
        }
    }
    
    private func applyShadowToNavigationBar() {
        navigationController?.navigationBar.layer.shadowOpacity = 0.5
        navigationController?.navigationBar.layer.shadowRadius = 5
        navigationController?.navigationBar.layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    private func clearShadowFromNavigationBar() {
        navigationController?.navigationBar.layer.shadowOpacity = 0
    }

    // MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

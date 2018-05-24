//
//  ActionSheetController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 5/1/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit
import IGListKit

final class ActionSheetController: UIViewController, ListAdapterDataSource, ListSingleSectionControllerDelegate {
    
    // MARK: - Properties
    
    var message: String?
    
    private var actions: [ActionSheetAction] = [] {
        didSet {
            adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
    private let cancelToken = ActionSheetAction(title: Localizable.cancel.localized, image: #imageLiteral(resourceName: "Cancel"), style: .cancel, callback: nil)
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private let cellHeight: CGFloat = 44
    
    // MARK: - Subviews
    
    private let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .white
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private var topConstraint: NSLayoutConstraint?
    
    private var requiredHeight: CGFloat {
        return cellHeight * CGFloat(actions.count + 1)
    }
    
    // MARK: - Initialization
    
    init(title: String?, message: String?, actions: [ActionSheetAction]) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        self.title = title
        self.message = message
        self.actions = actions
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        topConstraint = collectionView.anchor(view.layoutMarginsGuide.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: requiredHeight + 40).first
        
        NotificationCenter.default.addObserver(self, selector: #selector(invalidateLayout), name: .UIDeviceOrientationDidChange, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showActionList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideActionList()
    }
    
    @objc
    func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Layout Animation
    
    private func showActionList() {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 3, options: .curveEaseOut, animations: { [weak self] in
            self?.topConstraint?.constant = -(self?.requiredHeight ?? 0)
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func hideActionList() {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 3, options: .curveEaseOut, animations: { [weak self] in
            self?.topConstraint?.constant = 40
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return actions + [cancelToken]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let configBlock: ListSingleSectionCellConfigureBlock = { (object, cell) in
            guard let actionCell = cell as? ActionSheetCell, let action = object as? ActionSheetAction else { return }
            actionCell.title = action.title
            actionCell.image = action.image
            actionCell.style = action.style
        }
        let sizeBlock: ListSingleSectionCellSizeBlock = { [weak self] (_, collectionContext) -> CGSize in
            return CGSize(width: collectionContext?.containerSize.width ?? 0, height: self?.cellHeight ?? 44)
        }
        let sectionController = ListSingleSectionController(cellClass: ActionSheetCell.self, configureBlock: configBlock, sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        return sectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    // MARK: - ListSingleSectionControllerDelegate
    
    func didSelect(_ sectionController: ListSingleSectionController, with object: Any) {
        if let action = object as? ActionSheetAction {
            if action.style == .destructive {
                let alertViewController = AlertViewController(title: "Are you sure?", message: "This action cannot be undone", action: action)
                dismiss(animated: true) {
                    UIApplication.shared.presentedController?.present(alertViewController, animated: true, completion: nil)
                }
            } else {
                dismiss(animated: true, completion: {
                    action.callback?(nil)
                })
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
        
    }
    
}

extension ActionSheetController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: view)
        return !collectionView.frame.contains(point)
    }
    
}

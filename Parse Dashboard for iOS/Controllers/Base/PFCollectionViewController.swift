//
//  PFCollectionViewController.swift
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
//  Created by Nathan Tannar on 11/20/17.
//

import UIKit
import AlertHUDKit

class PFCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var refreshControl = UIRefreshControl()
    
    // MARK: - Initialization
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        configure()
        setupCollectionView()
        setupNavigationBar()
        NotificationCenter.default.addObserver(self, selector: #selector(handleRotate), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    // MARK: - Setup
    
    func setupNavigationBar() {
        
    }
    
    func setupCollectionView() {
        collectionView?.contentInset.top = 10
        collectionView?.contentInset.bottom = 30
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(for:)))
        collectionView?.addGestureRecognizer(longPress)
    }
    
    // MARK: - Universal Helper Methods
    
    func setTitleView(title: String, subtitle: String) {
        let label = UILabel()
        label.text = title + subtitle
        navigationItem.titleView = label
    }
    
    func handleError(_ error: String?) {
        let error = error ?? Localizable.unknownError.localized
        print(error)
        Ping(text: error, style: .danger).show(animated: true, duration: 3)
    }
    
    func handleSuccess(_ message: String?) {
        let message = message ?? Localizable.success.localized
        print(message)
        Ping(text: message, style: .info).show(animated: true, duration: 3)
    }
    
    func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    @objc
    func handleRotate() {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    @objc
    func handleRefresh() {
        
    }
    
    @objc
    func handleLongPress(for gesture : UILongPressGestureRecognizer) {
        guard let collectionView = collectionView, gesture.state == .began else { return }
        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            self.collectionView(collectionView, didLongSelectItemAt: indexPath)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didLongSelectItemAt indexPath: IndexPath) {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PFCollectionViewCell else { return }
        UIView.animate(withDuration: 0.3) {
            cell.contentView.backgroundColor = cell.highlightedBackgroundColor
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PFCollectionViewCell else { return }
        UIView.animate(withDuration: 0.3) {
            cell.contentView.backgroundColor = cell.backgroundColor
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        var safeInsets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            safeInsets = view.safeAreaInsets
        }
        return UIEdgeInsets(top: 4, left: 12 + safeInsets.left, bottom: 4, right: 12 + safeInsets.right)
    }
}

//
//  DynamicTabBarController.swift
//  DynamicTabBarController
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
//  Created by Nathan Tannar on 10/28/17.
//

import UIKit

open class DynamicTabBarController: UIViewController {
    
    public enum TabBarSizeLayout {
        case fixed(CGFloat)
        case automatic
    }
    
    public enum TabBarPosition {
        case top, bottom
    }
    
    // MARK: - Properties [Public]
    
    public var currentIndex: Int {
        guard let currentViewController = pageViewController.viewControllers?.first else { return -1 }
        return viewControllers.index(of: currentViewController) ?? -1
    }
    
    open var isScrollEnabled: Bool {
        get {
            return pageScrollView?.isScrollEnabled ?? false
        }
        set {
            pageScrollView?.isScrollEnabled = newValue
        }
    }
    
    public fileprivate(set) var viewControllers: [UIViewController]
    
    public fileprivate(set) var pageScrollView: UIScrollView?
    
    public var tabBarSizeLayout: TabBarSizeLayout = .automatic {
        didSet {
            tabBar.collectionView.collectionViewLayout.invalidateLayout()
            tabBar.moveCurrentBarView(to: currentIndex, animated: false, shouldScroll: true)
            switch tabBarSizeLayout {
            case .fixed(let size):
                tabBar.scrollIndicatorWidth = size
            case .automatic:
                tabBar.scrollIndicatorWidth = tabBar.bounds.width / CGFloat(viewControllers.count)
            }
        }
    }
    
    public var tabBarPosition: TabBarPosition = .bottom {
        didSet {
            updateTabBarPosition()
        }
    }
    
    public fileprivate(set) var tabBarHeight: CGFloat = 60
    
    public var isTabBarTranslucent: Bool = false {
        didSet {
            tabBar.isTranslucent = isTabBarTranslucent
            updateTabBarPosition()
        }
    }
    
    // MARK: - Subviews [Public]
    
    public lazy var tabBar: DynamicTabBar = { [weak self] in
        let tabBar = DynamicTabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.backgroundColor = .white
        tabBar.collectionView.dataSource = self
        tabBar.collectionView.delegate = self
        tabBar.collectionView.register(DynamicTabBarCell.self, forCellWithReuseIdentifier: DynamicTabBarCell.reuseIdentifier)
        return tabBar
    }()
    
    public let trayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var pageViewController: UIPageViewController = { [weak self] in
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageScrollView = pageViewController.view.subviews.flatMap { $0 as? UIScrollView }.first
        pageScrollView?.scrollsToTop = false
        pageScrollView?.delegate = self
        return pageViewController
    }()
    
    // MARK: - Properties [Private]
    
    fileprivate var shouldScrollIndicator = true
    fileprivate var previousIndex = 0
    
    fileprivate var tabBarConstraints: NSLayoutConstraintSet?
    fileprivate var pageViewControllerConstraints: NSLayoutConstraintSet?
    fileprivate var trayViewConstraints: NSLayoutConstraintSet?
    
    // MARK: - Initialization [Public]
    
    required public init(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.viewControllers = [UIViewController()]
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup [Private]
    
    fileprivate func setup() {
        
        view.backgroundColor = .white
        setupSubviews()
        setupConstraints()
        setupPageViewController()
    }
    
    fileprivate func setupSubviews() {
        view.addSubview(pageViewController.view)
        view.addSubview(tabBar)
        view.addSubview(trayView)
    }
    
    fileprivate func setupConstraints() {
        
        switch tabBarPosition {
        case .top:
            
            let pageViewTop = isTabBarTranslucent ? view.topAnchor : tabBar.bottomAnchor
            pageViewControllerConstraints = NSLayoutConstraintSet(
                top:    pageViewController.view.topAnchor.constraint(equalTo: pageViewTop),
                bottom: pageViewController.view.bottomAnchor.constraint(equalTo: trayView.topAnchor),
                left:   pageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
                right:  pageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
            ).activate()
            
            tabBarConstraints = NSLayoutConstraintSet(
                top:    tabBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                left:   tabBar.leftAnchor.constraint(equalTo: view.leftAnchor),
                right:  tabBar.rightAnchor.constraint(equalTo: view.rightAnchor),
                height: tabBar.heightAnchor.constraint(equalToConstant: tabBarHeight)
            ).activate()
            
            trayViewConstraints = NSLayoutConstraintSet(
                bottom: trayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                left:   trayView.leftAnchor.constraint(equalTo: view.leftAnchor),
                right:  trayView.rightAnchor.constraint(equalTo: view.rightAnchor),
                height: trayView.heightAnchor.constraint(equalToConstant: 0)
            ).activate()
            
        case .bottom:
            
            let pageViewBottom = isTabBarTranslucent ? view.bottomAnchor : tabBar.topAnchor
            pageViewControllerConstraints = NSLayoutConstraintSet(
                top:    pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
                bottom: pageViewController.view.bottomAnchor.constraint(equalTo: pageViewBottom),
                left:   pageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
                right:  pageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
            ).activate()
            
            tabBarConstraints = NSLayoutConstraintSet(
                top:    tabBar.bufferView.topAnchor.constraint(equalTo: trayView.topAnchor),
                bottom: tabBar.bufferView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                left:   tabBar.leftAnchor.constraint(equalTo: view.leftAnchor),
                right:  tabBar.rightAnchor.constraint(equalTo: view.rightAnchor),
                height: tabBar.collectionView.heightAnchor.constraint(equalToConstant: tabBarHeight)
            ).activate()
            
            trayViewConstraints = NSLayoutConstraintSet(
                bottom: trayView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
                left:   trayView.leftAnchor.constraint(equalTo: view.leftAnchor),
                right:  trayView.rightAnchor.constraint(equalTo: view.rightAnchor),
                height: trayView.heightAnchor.constraint(equalToConstant: 0)
            ).activate()
            
        }
    }
    
    fileprivate func setupPageViewController() {
        setupChildViewController(pageViewController)
        viewControllers.forEach {
            $0.loadViewIfNeeded()
            setupChildViewController($0)
        }
        pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
        pageScrollView?.isScrollEnabled = viewControllers.count > 1
        tabBar.moveCurrentBarView(to: currentIndex, animated: false, shouldScroll: true)
    }
    
    fileprivate func setupChildViewController(_ viewController: UIViewController) {
        viewController.willMove(toParentViewController: self)
        addChildViewController(pageViewController)
        viewController.didMove(toParentViewController: self)
    }
    
    fileprivate func removeChildViewController(_ viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
        viewController.didMove(toParentViewController: nil)
    }
    
    // MARK: - View Life Cycle [Public]
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Tray View Methods [Public]
    
    open func toastAlert(text: String, font: UIFont = .systemFont(ofSize: 15), duration: TimeInterval? = nil, completion: ((Bool)->Void)? = nil) {
        let label = UILabel()
        label.font = font
        label.textAlignment = .center
        label.text = text
        label.textColor = .white
        let maxSize = CGSize(width: trayView.bounds.width, height: .greatestFiniteMagnitude)
        let heightToFit = label.sizeThatFits(maxSize).height.rounded() + 4
        trayView.subviews.forEach { $0.removeFromSuperview() }
        trayView.addSubview(label)
        label.fillSuperview()
        showTrayView(withHeight: heightToFit) { success in
            guard let duration = duration else {
                completion?(success)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration, execute: {
                self.closeTrayView(completion: completion)
            })
        }
    }
    
    open func showTrayView(withHeight height: CGFloat, withDuration duration: TimeInterval = 0.3, completion: ((Bool)->Void)? = nil) {
        let bottomConstant = UIScreen.main.nativeBounds.height == 2436 && tabBarPosition == .top ? view.layoutMargins.bottom : 0
        UIView.animate(withDuration: duration, animations: {
            self.trayViewConstraints?.height?.constant = height
            self.trayViewConstraints?.bottom?.constant = -bottomConstant
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
    
    open func closeTrayView(withDuration duration: TimeInterval = 0.3, completion: ((Bool)->Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.trayViewConstraints?.height?.constant = 0
            self.trayViewConstraints?.bottom?.constant = 0
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
    
    // MARK: - Size Transition Methods [Public]
    
    public func updateTabBarHeight(to newValue: CGFloat, animated: Bool, duration: TimeInterval = 0.3) {
        let marginInset = isTabBarTranslucent ? view.layoutMargins.bottom : 0
        tabBarHeight = newValue + marginInset
        let adjustments = {
            self.tabBarConstraints?.height?.constant = self.tabBarHeight
            self.view.layoutIfNeeded()
        }
        if animated { UIView.animate(withDuration: duration, animations: adjustments) }
        else { adjustments() }
        tabBar.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15) {
            self.tabBar.collectionView.collectionViewLayout.invalidateLayout()
            self.tabBar.setNeedsDisplay()
            self.tabBar.moveCurrentBarView(to: self.currentIndex, animated: false, shouldScroll: true)
        }
    }
    
    // MARK: - View Controller Array Methods [Public]
    
    public func addViewController(_ viewController: UIViewController, animated: Bool) {
        insertViewController(viewController, at: viewControllers.count, animated: animated)
    }
    
    public func insertViewController(_ viewController: UIViewController, at index: Int, animated: Bool) {
        guard index <= viewControllers.count else { return }
        viewControllers.insert(viewController, at: index)
        if animated {
            tabBar.collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
        } else {
            tabBar.collectionView.reloadData()
        }
        displayViewController(at: currentIndex, animated: animated)
        pageViewController.dataSource = nil
        pageViewController.dataSource = self
    }
    
    public func removeViewController(_ viewController: UIViewController, animated: Bool) {
        guard let index = viewControllers.index(of: viewController) else { return }
        removeViewController(at: index, animated: animated)
    }
    
    public func removeViewController(at index: Int, animated: Bool) {
        guard viewControllers.count > 1 else { return }
        if index == currentIndex {
            let adjustment = currentIndex == (viewControllers.count - 1) ? -1 : 1
            displayViewController(at: currentIndex + adjustment, animated: animated)
        }
        viewControllers.remove(at: index)
        if animated {
            self.pageViewController.view.isUserInteractionEnabled = false
            tabBar.collectionView.performBatchUpdates({
                self.tabBar.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
            }, completion: { _ in
                self.pageViewController.view.isUserInteractionEnabled = true
            })
        } else {
            self.tabBar.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        }
        tabBar.moveCurrentBarView(to: currentIndex, animated: animated, shouldScroll: true)
        previousIndex = currentIndex
    }
    
    public func displayViewController(_ viewController: UIViewController, animated: Bool) {
        guard let index = viewControllers.index(of: viewController) else { return }
        displayViewController(at: index, animated: animated)
    }
    
    public func displayViewController(at index: Int, animated: Bool) {
        guard index < viewControllers.count else { return }
        previousIndex = index
        shouldScrollIndicator = false
        let direction: UIPageViewControllerNavigationDirection = index > currentIndex ? .forward : .reverse
        pageViewController.setViewControllers([viewControllers[index]], direction: direction, animated: animated) { [weak self] _ in
            self?.shouldScrollIndicator = true
        }
        tabBar.moveCurrentBarView(to: currentIndex, animated: animated, shouldScroll: true)
    }
    
    // MARK: - Methods [Private]
    
    fileprivate func updateTabBarPosition() {
        pageViewControllerConstraints?.deactivate()
        tabBarConstraints?.deactivate()
        trayViewConstraints?.deactivate()
        setupConstraints()
        tabBar.collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

// MARK: - UIPageViewControllerDataSource
extension DynamicTabBarController: UIPageViewControllerDataSource {
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: true)
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: false)
    }
    
    // MARK: - UIPageViewControllerDataSource Helper
    
    fileprivate func nextViewController(_ viewController: UIViewController, isAfter: Bool) -> UIViewController? {
        guard var index = viewControllers.index(of: viewController) else { return nil }
        index += isAfter ? 1 : -1
        guard index >= 0 && index < viewControllers.count else { return nil }
        return viewControllers[index]
    }
    
}

// MARK: - UIPageViewControllerDataSource
extension DynamicTabBarController: UIPageViewControllerDelegate {
    
    open func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        shouldScrollIndicator = true
        tabBar.updateUserInteraction(isEnabled: false)
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            tabBar.moveCurrentBarView(to: currentIndex, animated: true, shouldScroll: true)
            previousIndex = currentIndex
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension DynamicTabBarController: UICollectionViewDataSource {
    
    final public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    final public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DynamicTabBarCell.reuseIdentifier, for: indexPath) as? DynamicTabBarCell else {
            fatalError("DynamicTabBarCell has not been registered as a reusable cell")
        }
        let isCurrent = indexPath.row == (currentIndex % viewControllers.count)
        cell.activeTintColor = tabBar.activeTintColor
        cell.inactiveTintColor = tabBar.inactiveTintColor
        cell.isActive = isCurrent
        let image = isCurrent ? viewControllers[indexPath.row].tabBarItem.selectedImage : viewControllers[indexPath.row].tabBarItem.image
        cell.iconView.image = image
        cell.stackView.distribution = image != nil ? .fillEqually : .fillProportionally
        cell.label.text = viewControllers[indexPath.row].title
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension DynamicTabBarController: UICollectionViewDelegate {
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        defer { displayViewController(at: indexPath.row, animated: true) }
        
        tabBar.updateUserInteraction(isEnabled: false)
        tabBar.moveCurrentBarView(to: indexPath.row, animated: true, shouldScroll: true)
        
        // If the currentIndex is selected try to pop to a UINav root
        guard currentIndex == indexPath.row, let navigationController = viewControllers[indexPath.row] as? UINavigationController else { return }
        navigationController.popToRootViewController(animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DynamicTabBarController: UICollectionViewDelegateFlowLayout {
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat
        switch tabBarSizeLayout {
        case .fixed(let val):
            width = val
        case .automatic:
            width = collectionView.frame.width / CGFloat(viewControllers.count)
        }
        let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        switch tabBar.scrollIndicatorPosition {
        case .top:
            return CGSize(width: width, height: collectionView.frame.height - inset.top - inset.bottom)
        case .bottom:
            return CGSize(width: width, height: collectionView.frame.height - inset.top - inset.bottom)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let constant: CGFloat = 4
        switch tabBar.scrollIndicatorPosition {
        case .top:
            return UIEdgeInsets(top: tabBar.scrollIndicatorHeight + constant, left: 0, bottom: constant, right: 0)
        case .bottom:
            return UIEdgeInsets(top: constant, left: 0, bottom: tabBar.scrollIndicatorHeight + constant, right: 0)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension DynamicTabBarController: UIScrollViewDelegate {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == pageScrollView {
            guard scrollView.contentOffset.x != view.bounds.width, shouldScrollIndicator else { return }
            let index = previousIndex + (scrollView.contentOffset.x > view.bounds.width ? 1 : -1)
            guard index >= 0, index < viewControllers.count else { return }
            let scrollOffsetX = scrollView.contentOffset.x - view.frame.width
            tabBar.scrollCurrentBarView(from: previousIndex, to: index, with: scrollOffsetX)
        } else if scrollView == tabBar.collectionView {
            switch tabBarSizeLayout {
            case .automatic:
                scrollView.contentOffset.x = 0
            case .fixed(_):
                break
            }
        }
    }

}

extension UIViewController {
    
    public var dynamicTabBarController: DynamicTabBarController? {
        var parentViewController = parent
        while parentViewController != nil {
            if let superViewController = parentViewController as? DynamicTabBarController {
                return superViewController
            }
            parentViewController = parentViewController!.parent
        }
        return nil
    }
}

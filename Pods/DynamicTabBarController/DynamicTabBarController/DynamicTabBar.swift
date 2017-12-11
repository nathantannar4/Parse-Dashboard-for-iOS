//
//  DynamicTabBar.swift
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

final public class DynamicTabBar: UIView {
    
    public enum ScrollIndicatorPosition {
        case top, bottom
    }
    
    // MARK: - Properties [Public]
    
    public var activeTintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1) {
        didSet {
            scrollIndicator.backgroundColor = activeTintColor
            collectionView.reloadData()
        }
    }
    
    public var inactiveTintColor = UIColor.lightGray {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public var scrollIndicatorPosition: ScrollIndicatorPosition = .top {
        didSet {
            updateScrollIndicatorPosition()
        }
    }
    
    public var scrollIndicatorHeight: CGFloat = 5 {
        didSet {
            scrollIndicatorConstraints?.height?.constant = scrollIndicatorHeight
        }
    }
    
    public let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    public let scrollIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public let bufferView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open var isTranslucent: Bool = false {
        didSet {
            if isTranslucent && blurView.superview == nil {
                insertSubview(blurView, at: 0)
                blurView.fillSuperview()
            }
            blurView.isHidden = !isTranslucent
            backgroundColor = isTranslucent ? (backgroundColor?.withAlphaComponent(0.75) ?? UIColor.white.withAlphaComponent(0.75)) : .white
        }
    }
    
    // MARK: - Properties [Private]
    
    public var scrollIndicatorWidth: CGFloat = 0 {
        didSet {
            scrollIndicatorConstraints?.width?.constant = scrollIndicatorWidth
        }
    }
    
    fileprivate var scrollIndicatorConstraints: NSLayoutConstraintSet?
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup [Private]
    
    fileprivate func setup() {
        backgroundColor = .white
        setupSubviews()
        setupConstraints()
    }
    
    fileprivate func setupSubviews() {
        addSubview(bufferView)
        addSubview(collectionView)
        collectionView.addSubview(scrollIndicator)
    }
    
    fileprivate func setupConstraints() {
        
        collectionView.addConstraints(topAnchor, left: leftAnchor, bottom: bufferView.topAnchor, right: rightAnchor)
        bufferView.addConstraints(collectionView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        switch scrollIndicatorPosition {
        case .top:
            
            scrollIndicatorConstraints = NSLayoutConstraintSet(
                top:    scrollIndicator.topAnchor.constraint(equalTo: topAnchor),
                left:   scrollIndicator.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
                width:  scrollIndicator.widthAnchor.constraint(equalToConstant: scrollIndicatorWidth),
                height: scrollIndicator.heightAnchor.constraint(equalToConstant: scrollIndicatorHeight)
            ).activate()
            
        case .bottom:
            
            scrollIndicatorConstraints = NSLayoutConstraintSet(
                bottom: scrollIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
                left:   scrollIndicator.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
                width:  scrollIndicator.widthAnchor.constraint(equalToConstant: scrollIndicatorWidth),
                height: scrollIndicator.heightAnchor.constraint(equalToConstant: scrollIndicatorHeight)
            ).activate()
            
        }
    }
    
    // MARK: - Methods [Public]
    
    open func scrollCurrentBarView(from oldIndex: Int, to newIndex: Int, with offset: CGFloat) {
        
        deselectVisibleCells()
        let currentIndexPath = IndexPath(row: oldIndex, section: 0)
        let nextIndexPath = IndexPath(row: newIndex, section: 0)
        guard let currentCell = collectionView.cellForItem(at: currentIndexPath) as? DynamicTabBarCell, let nextCell = collectionView.cellForItem(at: nextIndexPath) as? DynamicTabBarCell else { return }
        let scrollRate = offset / frame.width
        let width = fabs(scrollRate) * (nextCell.frame.width - currentCell.frame.width)
        let newOffset = currentCell.frame.minX + scrollRate * (scrollRate > 0 ? currentCell.frame.width : nextCell.frame.width)
        scrollIndicatorConstraints?.left?.constant = newOffset
        scrollIndicatorWidth = currentCell.frame.width + width
        collectionView.layoutIfNeeded()
    }
    
    open func moveCurrentBarView(to index: Int, animated: Bool, shouldScroll: Bool) {
        
        let indexPath = IndexPath(item: index, section: 0)
        if shouldScroll {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            layoutIfNeeded()
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? DynamicTabBarCell else { return }
        scrollIndicatorWidth = cell.frame.width
        scrollIndicatorConstraints?.left?.constant = cell.frame.origin.x
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                self.updateUserInteraction(isEnabled: true)
                cell.isActive = true
                self.collectionView.reloadData()
            })
            
        } else {
            layoutIfNeeded()
            cell.isActive = true
            collectionView.reloadData()
            updateUserInteraction(isEnabled: true)
        }
    }
    
    open func updateUserInteraction(isEnabled: Bool) {
        collectionView.isUserInteractionEnabled = isEnabled
    }
    
    // MARK: - Methods [Private]
    
    fileprivate func updateScrollIndicatorPosition() {
        scrollIndicatorConstraints?.deactivate()
        setupConstraints()
    }
    
    /// Updates the visible cells to their inactive state
    private func deselectVisibleCells() {
        collectionView.visibleCells.flatMap { $0 as? DynamicTabBarCell }.forEach { $0.tintColor = inactiveTintColor }
    }
}

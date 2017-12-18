//
//  LaunchScreenViewController.swift
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

class LaunchScreenViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - View Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        beginTransition()
    }
    
    // MARK: - Animation Methods
    
    func beginTransition() {
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        // largeTitleNavBarHeight = 96
        // standardNavBarHeight = 44
        let isPortrait = view.frame.height > view.frame.width
        let newHeight = isPortrait ? (96 + statusBarHeight) : 44
        if isPortrait {
            titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        } else {
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        }
        
        let delay: TimeInterval = 0.25
        
        UIView.animate(withDuration: 0.25, delay: 0.25 + delay, options: .curveEaseIn, animations: {
            self.titleLabel.alpha = 1
            self.authorImageView.alpha = 0
            self.authorLabel.alpha = 0
        })
        
        let xOrigin: CGFloat = UIDevice.current.model == .iPhoneX ? 18 : 20
        
        UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseIn, animations: {
            self.titleLabel.alpha = 1
            self.logoViewWidthConstraint.constant = 30
            self.logoViewHeightConstraint.constant = 30
            self.headerViewHeightConstraint.constant = newHeight
            self.view.layoutIfNeeded()
            self.logoView.frame.origin = CGPoint(x: xOrigin, y: statusBarHeight + 7)
            if !isPortrait {
                // Hacky solution to match destination frame
                self.titleLabel.transform = CGAffineTransform(translationX: 0, y: -1)
            }
        }) { _ in
            self.endTransition()
        }
    }
    
    func endTransition() {
        let serversViewController = ServersViewController()
        serversViewController.shouldAnimateFirstLoad = true
        let rootViewController = UINavigationController(rootViewController: serversViewController)
        UIApplication.shared.presentedWindow?.switchRootViewController(
            rootViewController,
            animated: true,
            duration: 0.3,
            options: .transitionCrossDissolve,
            completion: nil)
    }
}

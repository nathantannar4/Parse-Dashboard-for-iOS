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
import DynamicTabBarController

class LaunchScreenViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - View Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let isNew = UserDefaults.standard.value(forKey: .isNew) as? Bool ?? true
        if isNew {
            beginTransitionForNewLaunch()
        } else {
            beginTransition()
        }
    }
    
    // MARK: - Animation Methods
    
    func beginTransitionForNewLaunch() {
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let isPortrait = view.frame.height > view.frame.width
        let navigationHeight: CGFloat = isPortrait ? (44 + statusBarHeight) : 44
        var newHeight = (UIDevice.current.userInterfaceIdiom == .pad ? 244 : 144) + navigationHeight
        
        var yTranslation = navigationHeight / 2
        
        if (UIDevice.current.model == .iPhoneX && !isPortrait) || (UIDevice.current.model == .iPhone6 && !isPortrait) {
            // Hardcoded hack
            newHeight -= 12
            yTranslation -= 6
        }
        
        logoView.tintColor = .white
        
        let delay: TimeInterval = 0.25
        
        UIView.animate(withDuration: 0.25, delay: 0.25 + delay, options: .curveEaseIn, animations: {
            self.logoView.image = UIImage(named: "Logo")?.withRenderingMode(.alwaysTemplate)
        })
        
        UIView.animate(withDuration: 0.5) {
            self.headerView.backgroundColor = .logoTint
        }
        
        UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseIn, animations: {
            self.authorImageView.alpha = 0
            self.authorLabel.alpha = 0
            self.logoViewWidthConstraint.constant = 100
            self.logoViewHeightConstraint.constant = 100
            self.logoView.transform = CGAffineTransform(translationX: 0, y: yTranslation)
            self.headerViewHeightConstraint.constant = newHeight
            self.view.layoutIfNeeded()
        }) { _ in
            self.endTransition()
        }
    }
    
    func beginTransition() {
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let isPortrait = view.frame.height > view.frame.width
        var newHeight = isPortrait ? (104 + statusBarHeight) : 44
        
        if (UIDevice.current.model == .iPhone6 || UIDevice.current.model == .iPhoneX) && !isPortrait {
            // Hardcoded hack
            newHeight -= 12
        } else if UIDevice.current.model == .iPhone5 {
            newHeight -= 2
        }
        
        let delay: TimeInterval = 0.25
        
        UIView.animate(withDuration: 0.25, delay: 0.25 + delay, options: .curveEaseIn, animations: {
            self.authorImageView.alpha = 0
            self.authorLabel.alpha = 0
        })
        
        let xOrigin: CGFloat = UIDevice.current.model == .iPhoneX ? 16 : 20
        
        UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseIn, animations: {
            self.logoViewWidthConstraint.constant = 30
            self.logoViewHeightConstraint.constant = 30
            self.headerViewHeightConstraint.constant = newHeight
            self.view.layoutIfNeeded()
            
            if UIDevice.current.model == .iPhone6 && !isPortrait {
                self.logoView.frame.origin = CGPoint(x: xOrigin, y: 0)
            } else if UIDevice.current.model == .iPhoneX && !isPortrait {
                if #available(iOS 11.0, *) {
                    self.logoView.frame.origin = CGPoint(x: self.view.safeAreaInsets.left + xOrigin + 4, y: 0)
                }
            } else if UIDevice.current.model == .iPhone5 {
                if isPortrait {
                    self.logoView.frame.origin = CGPoint(x: xOrigin - 4, y: statusBarHeight + 7)
                } else {
                    self.logoView.frame.origin = CGPoint(x: xOrigin - 4, y: statusBarHeight + 7)
                }
            } else {
                self.logoView.frame.origin = CGPoint(x: xOrigin, y: statusBarHeight + 7)
            }
            
        }) { _ in
            self.endTransition()
        }
    }
    
    func endTransition() {
        
        var rootViewController: UIViewController
        
        let isNew = UserDefaults.standard.value(forKey: .isNew) as? Bool ?? true
        if isNew {
            rootViewController = NavigationController(rootViewController: WelcomeViewController())
        } else {
            let serversVC = ServersViewController()
            rootViewController = NavigationController(rootViewController: serversVC)
        }
        
        UIApplication.shared.presentedWindow?.switchRootViewController(
            rootViewController,
            animated: true,
            duration: 0.3,
            options: .transitionCrossDissolve,
            completion: nil)
    }
}

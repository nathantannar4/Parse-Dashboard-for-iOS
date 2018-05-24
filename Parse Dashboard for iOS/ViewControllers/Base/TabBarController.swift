//
//  TabBarController.swift
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
//  Created by Nathan Tannar on 12/11/17.
//

import UIKit
import Social
import DynamicTabBarController

final class TabBarController: DynamicTabBarController {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .groupTableViewBackground
        tabBar.activeTintColor = .logoTint
        tabBar.layer.shadowRadius = 5
        tabBar.layer.shadowColor = UIColor.darkGray.cgColor
        tabBar.layer.shadowOpacity = 0.5
        setupNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarPosition = .top
        tabBar.scrollIndicatorPosition = .bottom
        updateTabBarHeight(to: 36, animated: false)
    }
    
    private func setupNavigationItem() {
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "Share")?.scale(to: 30),
                            style: .plain,
                            target: self,
                            action: #selector(shareApp(sender:))),
            UIBarButtonItem(image: UIImage(named: "ic_github")?.scale(to: 30),
                            style: .plain,
                            target: self,
                            action: #selector(openGitHubRepo))
        ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: CloseButton(target: self, action: #selector(dismissViewController)))
    }
    
    // MARK: - User Actions
    
    @objc
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func openGitHubRepo() {
        
        guard let url = URL(string: "https://github.com/nathantannar4/Parse-Dashboard-for-iOS") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc
    func shareApp(sender: UIBarButtonItem) {
        
        let shareText = Localizable.shareCaption.localized + " https://itunes.apple.com/ca/app/parse-dashboard/id1212141622"
        
        let actions = [
            ActionSheetAction(title: "Facebook", image: #imageLiteral(resourceName: "Facebook"), style: .default, callback: { [weak self] _ in
                guard let facebookSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook) else { return }
                facebookSheet.setInitialText(shareText)
                self?.present(facebookSheet, animated: true, completion: nil)
            }),
            ActionSheetAction(title: "Twitter", image: #imageLiteral(resourceName: "Twitter"), style: .default, callback: { [weak self] _ in
                guard let twitterSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else { return }
                twitterSheet.setInitialText(shareText)
                self?.present(twitterSheet, animated: true, completion: nil)
            }),
            ActionSheetAction(title: Localizable.moreOptions.localized, image: #imageLiteral(resourceName: "Info"), style: .default, callback: { [weak self] _ in
                let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                activityVC.excludedActivityTypes = [
                    UIActivityType.print,
                    UIActivityType.assignToContact,
                    UIActivityType.addToReadingList,
                    UIActivityType.postToFlickr,
                    UIActivityType.postToVimeo,
                    UIActivityType.postToTencentWeibo
                ]
                activityVC.popoverPresentationController?.permittedArrowDirections = .up
                activityVC.popoverPresentationController?.canOverlapSourceViewRect = true
                activityVC.popoverPresentationController?.barButtonItem = sender
                self?.present(activityVC, animated: true, completion: nil)
            })
        ]
        let actionSheetController = ActionSheetController(title: Localizable.share.localized, message: nil, actions: actions)
        present(actionSheetController, animated: true, completion: nil)
    }
    
}

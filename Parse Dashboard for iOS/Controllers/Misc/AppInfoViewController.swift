//
//  AppInfoViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 3/4/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit
import Social

class AppInfoViewController: UITableViewController {
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupTableView()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 60
        tableView.contentInset.bottom = 30
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
    }
    
    private func setupNavigationBar() {
        
        title = "About"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "Share"),
                            style: .plain,
                            target: self,
                            action: #selector(shareApp(sender:))),
            UIBarButtonItem(image: UIImage(named: "ic_github")?.scale(to: 30),
                            style: .plain,
                            target: self,
                            action: #selector(openGitHubRepo))
        ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(dismissInfo))
    }
    
    // MARK: - User Actions
    
    @objc
    func dismissInfo() {
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
        
        let shareText = "Hey! Check out this awesome mobile Parse Dashboard client for iOS! https://itunes.apple.com/ca/app/parse-dashboard/id1212141622"
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actions = [
            UIAlertAction(title: "Share on Facebook", style: .default, handler: { _ in
                
                guard let facebookSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook) else { return }
                facebookSheet.setInitialText(shareText)
                self.present(facebookSheet, animated: true, completion: nil)
            }),
            UIAlertAction(title: "Share on Twitter", style: .default, handler: { _ in
                
                guard let twitterSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else { return }
                twitterSheet.setInitialText(shareText)
                self.present(twitterSheet, animated: true, completion: nil)
            }),
            UIAlertAction(title: "More Options", style: .default, handler: { _ in
                
                let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                activityVC.excludedActivityTypes = [
                    UIActivityType.print,
                    UIActivityType.assignToContact,
                    UIActivityType.addToReadingList,
                    UIActivityType.postToFlickr,
                    UIActivityType.postToVimeo,
                    UIActivityType.postToTencentWeibo
                ]
                self.present(activityVC, animated: true, completion: nil)
            }),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ]
        actions.forEach { actionSheet.addAction($0) }
        actionSheet.modalPresentationStyle = .popover
        actionSheet.popoverPresentationController?.permittedArrowDirections = .up
        actionSheet.popoverPresentationController?.barButtonItem = sender
        present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDatasource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        
        switch indexPath.row {
        case 0:
            let imageView = UIImageView(image: UIImage(named: "Dashboard"))
            imageView.contentMode = .scaleToFill
            cell.contentView.addSubview(imageView)
            imageView.fillSuperview()
        case 1:
            cell.textLabel?.text = "Parse Dashboard for iOS"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            cell.imageView?.image = UIImage(named: "Logo")?.scale(to: 44)
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            cell.contentView.addSubview(separatorView)
            separatorView.anchor(cell.contentView.bottomAnchor, left: cell.contentView.leftAnchor, right: cell.contentView.rightAnchor, heightConstant: 0.5)
        case 2:
            cell.textLabel?.text = "A beautiful moile client for managing your Parse apps while you are on the go! Now you can easily view and modify your data in the same way you would on the offical desktop client."
            cell.textLabel?.textColor = .darkGray
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        case 3:
            cell.textLabel?.text = "Data Security"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            cell.contentView.addSubview(separatorView)
            separatorView.anchor(cell.contentView.bottomAnchor, left: cell.contentView.leftAnchor, right: cell.contentView.rightAnchor, heightConstant: 0.5)
        case 4:
            cell.textLabel?.text = "Privacy and data protection is important. Know that your Parse Server's application ID and master key are only stored on your devices core data."
            cell.textLabel?.textColor = .darkGray
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        case 5:
            cell.textLabel?.text = "Open Source"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            cell.contentView.addSubview(separatorView)
            separatorView.anchor(cell.contentView.bottomAnchor, left: cell.contentView.leftAnchor, right: cell.contentView.rightAnchor, heightConstant: 0.5)
        case 6:
            cell.textLabel?.text = "Interested in viewing the code for this app? This app is open source! Tap the GitHub logo to view the repo."
            cell.textLabel?.textColor = .darkGray
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        default:
            break
        }
        return cell
    }
}

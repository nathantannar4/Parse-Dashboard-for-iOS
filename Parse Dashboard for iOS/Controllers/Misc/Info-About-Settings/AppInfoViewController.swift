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
    
    // MARK: - Initialization
    
    init() {
        super.init(style: .plain)
        title = Localizable.about.localized
        tabBarItem = UITabBarItem(title: title, image: UIImage(named: Localizable.about.rawValue)?.withRenderingMode(.alwaysTemplate), selectedImage: UIImage(named: Localizable.about.rawValue))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        
        tableView.backgroundColor = .groupTableViewBackground
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 60
        tableView.contentInset.bottom = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
    }
    
    private func setupNavigationBar() {
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .logoTint
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 24),
                NSAttributedStringKey.foregroundColor : UIColor.white
            ]
        }
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: Localizable.share.rawValue),
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
        cell.backgroundColor = .groupTableViewBackground
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
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            cell.contentView.addSubview(separatorView)
            separatorView.anchor(cell.contentView.bottomAnchor, left: cell.contentView.leftAnchor, right: cell.contentView.rightAnchor, heightConstant: 0.5)
        case 2:
            cell.textLabel?.text = Localizable.appDescription.localized
            cell.textLabel?.textColor = .darkGray
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        case 3:
            cell.textLabel?.text = Localizable.dataSecurity.localized
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            cell.contentView.addSubview(separatorView)
            separatorView.anchor(cell.contentView.bottomAnchor, left: cell.contentView.leftAnchor, right: cell.contentView.rightAnchor, heightConstant: 0.5)
        case 4:
            cell.textLabel?.text = Localizable.dataSecurityInfo.localized
            cell.textLabel?.textColor = .darkGray
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        case 5:
            cell.textLabel?.text = Localizable.openSource.localized
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            cell.contentView.addSubview(separatorView)
            separatorView.anchor(cell.contentView.bottomAnchor, left: cell.contentView.leftAnchor, right: cell.contentView.rightAnchor, heightConstant: 0.5)
        case 6:
            cell.textLabel?.text = Localizable.openSourceInfo.localized
            cell.textLabel?.textColor = .darkGray
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        default:
            break
        }
        return cell
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
        
        let shareText = Localizable.shareCaption.localized + " https://itunes.apple.com/ca/app/parse-dashboard/id1212141622"
        
        let actionSheet = UIAlertController(title: Localizable.share.localized, message: nil, preferredStyle: .actionSheet)
        actionSheet.configureView()
        
        let actions = [
            UIAlertAction(title: "Facebook", style: .default, handler: { _ in
                
                guard let facebookSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook) else { return }
                facebookSheet.setInitialText(shareText)
                self.present(facebookSheet, animated: true, completion: nil)
            }),
            UIAlertAction(title: "Twitter", style: .default, handler: { _ in
                
                guard let twitterSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else { return }
                twitterSheet.setInitialText(shareText)
                self.present(twitterSheet, animated: true, completion: nil)
            }),
            UIAlertAction(title: Localizable.moreOptions.localized, style: .default, handler: { _ in
                
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
                self.present(activityVC, animated: true, completion: nil)
            }),
            UIAlertAction(title: Localizable.cancel.localized, style: .cancel, handler: nil)
        ]
        actions.forEach { actionSheet.addAction($0) }
        actionSheet.modalPresentationStyle = .popover
        actionSheet.popoverPresentationController?.permittedArrowDirections = .up
        actionSheet.popoverPresentationController?.barButtonItem = sender
        present(actionSheet, animated: true, completion: nil)
    }
}

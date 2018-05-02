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
        title = Localizable.about.localized
        setupTableView()
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
    
}

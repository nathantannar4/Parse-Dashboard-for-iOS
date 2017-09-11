//
//  DonateViewController.swift
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
//  Created by Nathan Tannar on 9/9/17.
//

import UIKit
import NTComponents
import StoreKit
import EggRating

class DonateViewController: UITableViewController {
    
    // MARK: - Properties

    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tableView.contentInset.top = 10 
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 60
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        
        setTitleView(title: "Donate", subtitle: "To the Developer")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(AppInfoViewController.dismissInfo))
    }
    
    // MARK: - User Actions
    
    func dismissInfo() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 6:
            EggRating.promptRateUs(viewController: self)
        case 7:
            guard let url = URL(string: "https://github.com/nathantannar4/Parse-Dashboard-for-iOS") else {
                return
            }
            let webController = UIWebViewController(url: url)
            navigationController?.pushViewController(webController, animated: true)
        default:
            break
        }
    }
    
    // MARK: - UITableViewDatasource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= 2 && indexPath.row <= 4 {
            return 60
        }
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.numberOfLines = 0
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Thank you for using Parse Dashboard! Like you I was developing apps that used Parse Server. I wanted an easy way to view my database on my phone so I developed my own mobile dashboard. I released this app for free with no ads. So please, if you enjoy it please donate and or leave a star on the Github Repo to show your support!"
            cell.textLabel?.textColor = .darkGray
            cell.textLabel?.font = Font.Default.Body.withSize(16)
            cell.selectionStyle = .none
        case 1:
            cell.textLabel?.text = "Donation Tiers"
            cell.textLabel?.font = Font.Default.Subtitle.withSize(24)
            cell.selectionStyle = .none
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            cell.addSubview(separatorView)
            separatorView.anchor(cell.textLabel?.bottomAnchor, left: cell.textLabel?.leftAnchor, right: cell.textLabel?.rightAnchor, heightConstant: 0.5)
        case 2:
            cell.imageView?.image = UIImage(named: "Coffee")?.withRenderingMode(.alwaysTemplate)
            cell.textLabel?.text = "Coffee"
            cell.detailTextLabel?.text = "$2.99"
            cell.imageView?.tintColor = .logoTint
            cell.textLabel?.font = Font.Default.Subtitle.withSize(18)
            cell.detailTextLabel?.font = Font.Default.Body.withSize(15)
            cell.accessoryType = .disclosureIndicator
        case 3:
            cell.imageView?.image = UIImage(named: "Beer")?.withRenderingMode(.alwaysTemplate)
            cell.textLabel?.text = "Beer"
            cell.detailTextLabel?.text = "$5.99"
            cell.imageView?.tintColor = .darkPurpleAccent
            cell.textLabel?.font = Font.Default.Subtitle.withSize(18)
            cell.detailTextLabel?.font = Font.Default.Body.withSize(15)
            cell.accessoryType = .disclosureIndicator
        case 4:
            cell.imageView?.image = UIImage(named: "Meal")?.withRenderingMode(.alwaysTemplate)
            cell.textLabel?.text = "Coffee"
            cell.detailTextLabel?.text = "$9.99"
            cell.imageView?.tintColor = .darkPurpleBackground
            cell.textLabel?.font = Font.Default.Subtitle.withSize(18)
            cell.detailTextLabel?.font = Font.Default.Body.withSize(15)
            cell.accessoryType = .disclosureIndicator
        case 5:
            cell.textLabel?.text = "Other Ways to Support"
            cell.textLabel?.font = Font.Default.Subtitle.withSize(24)
            cell.selectionStyle = .none
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            cell.addSubview(separatorView)
            separatorView.anchor(cell.textLabel?.bottomAnchor, left: cell.textLabel?.leftAnchor, right: cell.textLabel?.rightAnchor, heightConstant: 0.5)
        case 6:
            cell.textLabel?.text = "Rate on the App Store"
            cell.textLabel?.font = Font.Default.Subtitle.withSize(16)
            cell.accessoryType = .disclosureIndicator
        case 7:
            cell.textLabel?.text = "Star GitHub Repo"
            cell.textLabel?.font = Font.Default.Subtitle.withSize(16)
            cell.accessoryType = .disclosureIndicator
        default:
            break
        }
        return cell
    }
}

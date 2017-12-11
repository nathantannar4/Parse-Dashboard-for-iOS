//
//  SupportViewController.swift
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
import StoreKit

class SupportViewController: UITableViewController {
    
    // MARK: - Properties

    let itunesID = "1212141622"
    
    // MARK: - Initialization
    
    init() {
        super.init(style: .plain)
        title = "Support"
        tabBarItem = UITabBarItem(title: "Support", image: UIImage(named: "Clap")?.withRenderingMode(.alwaysTemplate), selectedImage: UIImage(named: "Clap"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        
        IAPHandler.shared.fetchAvailableProducts(delegate: self)
    }
    
    private func setupTableView() {
        
        tableView.backgroundColor = .groupTableViewBackground
        tableView.contentInset.bottom = 60
        tableView.contentInset.top = 20
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 60
    }
    
    private func setupNavigationBar() {
        configure()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(dismissInfo))
    }
    
    // MARK: - User Actions
    
    @objc
    func dismissInfo() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            IAPHandler.shared.purchase(atIndex: indexPath.row - 1)
        } else if indexPath.section == 2 {
            if indexPath.row == 1 {
                guard let url = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(itunesID)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software") else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                guard let url = URL(string: "https://github.com/nathantannar4/Parse-Dashboard-for-iOS") else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // MARK: - UITableViewDatasource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section >= 1 ) && indexPath.row == 0 {
            return 60
        }
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return IAPHandler.shared.iapProducts.count > 0 ? IAPHandler.shared.iapProducts.count + 1 : 2
        } else if section == 2 {
            return 3
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = .groupTableViewBackground
        cell.textLabel?.numberOfLines = 0
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Thank you for using Parse Dashboard for iOS! Like you I was developing apps that used Parse Server. I wanted an easy way to view my database on my phone so I developed my own mobile dashboard. I released this app for free with no ads. So please, if you enjoy it please donate and or leave a star on the Github Repo to show your support!"
            cell.textLabel?.textColor = .darkGray
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            cell.selectionStyle = .none
        case 1:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Make a Donation"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 24)
                cell.selectionStyle = .none
                cell.imageView?.image = UIImage(named: "Money")?.scale(to: 30)
                let separatorView = UIView()
                separatorView.backgroundColor = .lightGray
                cell.contentView.addSubview(separatorView)
                separatorView.anchor(cell.textLabel?.bottomAnchor, left: cell.contentView.leftAnchor, right: cell.contentView.rightAnchor, heightConstant: 0.5)
            } else if IAPHandler.shared.iapProducts.count > 0 {
                switch indexPath.row {
                case 1:
                    cell.imageView?.image = UIImage(named: "Coffee")
                    cell.textLabel?.text = "Buy me a Coffee"
                    cell.detailTextLabel?.text = IAPHandler.shared.iapPrices[0]
                    cell.imageView?.tintColor = .logoTint
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
                    cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .body)
                    cell.accessoryType = .disclosureIndicator
                case 2:
                    cell.imageView?.image = UIImage(named: "Beer")
                    cell.textLabel?.text = "Buy me a Beer"
                    cell.detailTextLabel?.text = IAPHandler.shared.iapPrices[1]
                    cell.imageView?.tintColor = .darkPurpleAccent
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
                    cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .body)
                    cell.accessoryType = .disclosureIndicator
                case 3:
                    cell.imageView?.image = UIImage(named: "Meal")
                    cell.textLabel?.text = "By me lunch"
                    cell.detailTextLabel?.text = IAPHandler.shared.iapPrices[2]
                    cell.imageView?.tintColor = .darkPurpleBackground
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
                    cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .body)
                    cell.accessoryType = .disclosureIndicator
                default:
                    break
                }
            } else {
                cell.textLabel?.text = "In-App Purchases Unavailable"
                cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Show You're a Fan"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 24)
                cell.selectionStyle = .none
                cell.imageView?.image = UIImage(named: "Support")?.scale(to: 30)
                let separatorView = UIView()
                separatorView.backgroundColor = .lightGray
                cell.contentView.addSubview(separatorView)
                separatorView.anchor(cell.textLabel?.bottomAnchor, left: cell.contentView.leftAnchor, right: cell.contentView.rightAnchor, heightConstant: 0.5)
            case 1:
                cell.textLabel?.text = "Rate on the App Store"
                cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
                cell.detailTextLabel?.text = "Currently Unavailable"
                cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                cell.imageView?.image = UIImage(named: "Rating")
                cell.accessoryType = .disclosureIndicator
            case 2:
                cell.textLabel?.text = "Star GitHub Repo"
                cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
                cell.imageView?.image = UIImage(named: "Star")
                cell.accessoryType = .disclosureIndicator
            default:
                break
            }
        default:
            break
        }
        return cell
    }
}

extension SupportViewController: SKProductsRequestDelegate {

    // MARK: - SKProductsRequestDelegate
    
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        IAPHandler.shared.iapProducts.removeAll()
        IAPHandler.shared.iapPrices.removeAll()
        
        let products = response.products.sorted { (a, b) -> Bool in
            return a.price.decimalValue < b.price.decimalValue
        }
        
        for product in products {
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = product.priceLocale
            if let price1Str = numberFormatter.string(from: product.price) {
                IAPHandler.shared.iapProducts.append(product)
                IAPHandler.shared.iapPrices.append(price1Str)
                print(product.localizedDescription + "\nfor just \(price1Str)")
            }
        }
        tableView.reloadSections([1], with: .none)
    }
}

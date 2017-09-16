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

class SupportViewController: UITableViewController, SKProductsRequestDelegate {
    
    // MARK: - Properties

    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupTableView()
        setupNavigationBar()
        
        IAPHandler.shared.fetchAvailableProducts(delegate: self)
    }
    
    private func setupTableView() {
        
        tableView.contentInset.top = 10
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 60
    }
    
    private func setupNavigationBar() {
        
        setTitleView(title: "Support", subtitle: "and Donations")
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
        case 2, 3, 4:
            IAPHandler.shared.purchase(atIndex: indexPath.row - 2)
        case 6:
            guard let url = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(EggRating.itunesId)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software") else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
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
            cell.textLabel?.text = "Make a Donation"
            cell.textLabel?.font = Font.Default.Subtitle.withSize(24)
            cell.selectionStyle = .none
            cell.imageView?.image = UIImage(named: "Coins")?.scale(to: 30)
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            cell.contentView.addSubview(separatorView)
            separatorView.anchor(cell.textLabel?.bottomAnchor, left: cell.contentView.leftAnchor, right: cell.contentView.rightAnchor, heightConstant: 0.5)
        case 2:
            cell.imageView?.image = UIImage(named: "Coffee")?.withRenderingMode(.alwaysTemplate)
            cell.textLabel?.text = "Buy me a Coffee"
            cell.detailTextLabel?.text = IAPHandler.shared.iapPrices.count > 0 ? IAPHandler.shared.iapPrices[0] : nil
            cell.imageView?.tintColor = .logoTint
            cell.textLabel?.font = Font.Default.Subtitle.withSize(18)
            cell.detailTextLabel?.font = Font.Default.Body.withSize(15)
            cell.accessoryType = .disclosureIndicator
        case 3:
            cell.imageView?.image = UIImage(named: "Beer")?.withRenderingMode(.alwaysTemplate)
            cell.textLabel?.text = "Buy me a Beer"
            cell.detailTextLabel?.text = IAPHandler.shared.iapPrices.count > 1 ? IAPHandler.shared.iapPrices[1] : nil
            cell.imageView?.tintColor = .darkPurpleAccent
            cell.textLabel?.font = Font.Default.Subtitle.withSize(18)
            cell.detailTextLabel?.font = Font.Default.Body.withSize(15)
            cell.accessoryType = .disclosureIndicator
        case 4:
            cell.imageView?.image = UIImage(named: "Meal")?.withRenderingMode(.alwaysTemplate)
            cell.textLabel?.text = "By me dinner"
            cell.detailTextLabel?.text = IAPHandler.shared.iapPrices.count > 2 ? IAPHandler.shared.iapPrices[2] : nil
            cell.imageView?.tintColor = .darkPurpleBackground
            cell.textLabel?.font = Font.Default.Subtitle.withSize(18)
            cell.detailTextLabel?.font = Font.Default.Body.withSize(15)
            cell.accessoryType = .disclosureIndicator
        case 5:
            cell.textLabel?.text = "Other Ways to Support"
            cell.textLabel?.font = Font.Default.Subtitle.withSize(24)
            cell.selectionStyle = .none
            cell.imageView?.image = UIImage(named: "Support")?.scale(to: 30)
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            cell.contentView.addSubview(separatorView)
            separatorView.anchor(cell.textLabel?.bottomAnchor, left: cell.contentView.leftAnchor, right: cell.contentView.rightAnchor, heightConstant: 0.5)
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
        
        let indexPaths = [IndexPath(row: 2, section: 0), IndexPath(row: 3, section: 0), IndexPath(row: 4, section: 0)]
        tableView.reloadRows(at: indexPaths, with: .none)
    }
}

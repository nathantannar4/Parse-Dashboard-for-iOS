//
//  CloudCodeBuilderViewController.swift
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
//  Created by Nathan Tannar on 12/20/17.
//

import UIKit
import AlertHUDKit
import Former

protocol CloudCodeBuilderDelegate: AnyObject {
    func cloudCode(didEnterNew cloudCode: CloudCode)
}

final class CloudCodeBuilderViewController: FormViewController {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let cloudCode: CloudCode
    
    weak var delegate: CloudCodeBuilderDelegate?
    
    private lazy var formerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    init(for cloudCode: CloudCode) {
        self.cloudCode = cloudCode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        buildForm()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        
        tableView.transform = CGAffineTransform(translationX: 0, y: -10)
        tableView.tableFooterView = UIView()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor(white: 0.1, alpha: 1).cgColor, UIColor(white: 0.25, alpha: 1).cgColor]
        gradient.locations = [0.0 , 1]
        gradient.frame = view.bounds
        tableView.backgroundView = UIView()
        tableView.backgroundView?.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupNavigationBar() {
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15),
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Save"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didSaveCloudCodeEntry))
    }
    
    // MARK: - User Actions
    
    @objc
    func didSaveCloudCodeEntry() {
        
        guard cloudCode.name != nil, cloudCode.name?.isEmpty == false else {
            Ping(text: "Please complete the form", style: .warning).show()
            return
        }
        delegate?.cloudCode(didEnterNew: cloudCode)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Form Setup
    
    private func buildForm() {
        
        let endpointRow = InlinePickerRowFormer<FormInlinePickerCell, Any>() {
                $0.titleLabel.text = "Endpoint"
                $0.titleLabel.textColor = .darkPurpleBackground
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                $0.displayLabel.textColor = .darkGray
            }.configure {
                if cloudCode.isFunction {
                    title = "Cloud Function"
                    $0.pickerItems = ["/functions", "/jobs"].map { return InlinePickerItem(title: $0) }
                } else {
                    title = "Cloud Function"
                    $0.pickerItems = ["/jobs", "/functions"].map { return InlinePickerItem(title: $0) }
                }
            }.onValueChanged { [weak self] item in
                // Update
                if item.title == "/functions" {
                    self?.title = "Cloud Function"
                    self?.cloudCode.isFunction = true
                } else {
                    self?.title = "Background Job"
                    self?.cloudCode.isFunction = false
                }
                self?.cloudCode.endpoint = item.title
        }
        endpointRow.update()
        
        let nameRow = TextFieldRowFormer<FormerFieldCell>(instantiateType: .Nib(nibName: "FormerFieldCell")) { [weak self] in
                $0.titleLabel.text = "Name"
                $0.titleLabel.textColor = .darkPurpleBackground
                $0.textField.textAlignment = .right
                $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "ex. HelloWorld"
                $0.text = cloudCode.name
            }.onTextChanged { [weak self] newValue in
                // Update
                self?.cloudCode.name = newValue
        }
        
        let bodyRow = TextViewRowFormer<FormTextViewCell> { [weak self] in
                $0.titleLabel.text = "Body"
                $0.titleLabel.textColor = .darkPurpleBackground
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "{\"foo\":\"bar\"}"
                $0.text = cloudCode.body
                $0.rowHeight = 200
            }.onTextChanged { [weak self] newValue in
                // Update
                self?.cloudCode.body = newValue
        }
        
        let section = SectionFormer(rowFormer: endpointRow, nameRow, bodyRow)
        former.append(sectionFormer: section)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
    }
}

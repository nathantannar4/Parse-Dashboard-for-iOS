//
//  ServerConfigViewController.swift
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
//  Created by Nathan Tannar on 12/10/17.
//

import UIKit
import CoreData
import Former
import DKImagePickerController

class ServerConfigViewController: FormViewController {
    
    // MARK: - Properties
    
    private var config: ParseServerConfig
    
    private var name: String?
    private var applicationId: String?
    private var masterKey: String?
    private var serverUrl: String?
    private var imageData: Data?
    
    private lazy var formerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    private var context: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    // MARK: - Initialization
    
    init(config: ParseServerConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        title = "Edit Configuration"
        name = config.name
        applicationId = config.applicationId
        masterKey = config.masterKey
        serverUrl = config.serverUrl
        imageData = config.icon
    }
    
    init() {
        self.config = ParseServerConfig(entity: ParseServerConfig.entity(), insertInto: nil)
        super.init(nibName: nil, bundle: nil)
        title = "New Configuration"
        name = config.name
        applicationId = config.applicationId
        masterKey = config.masterKey
        serverUrl = config.serverUrl
        imageData = config.icon
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        buildForm()
    }
    
    private func setupTableView() {
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor : UIColor.black
        ]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 24),
                NSAttributedStringKey.foregroundColor : UIColor.black
            ]
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancelEdit))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(saveContext))
    }
    
    private func buildForm() {
        
        // Create RowFomers
        
        let nameRow = TextFieldRowFormer<FormerFieldCell>(instantiateType: .Nib(nibName: "FormerFieldCell")) { [weak self] in
            $0.titleLabel.text = "App Name"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Descriptor"
                $0.text = self.name
            }.onTextChanged { [weak self] in
                self?.name = $0
        }
        
        let appIdRow = TextFieldRowFormer<FormerFieldCell>(instantiateType: .Nib(nibName: "FormerFieldCell")) { [weak self] in
            $0.titleLabel.text = "Application ID"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "X-Parse-Application-ID"
                $0.text = self.applicationId
            }.onTextChanged { [weak self] in
                self?.applicationId = $0
        }
        
        let masterKeyRow = TextFieldRowFormer<FormerFieldCell>(instantiateType: .Nib(nibName: "FormerFieldCell")) { [weak self] in
            $0.titleLabel.text = "Master Key"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "X-Parse-Master-Key"
                $0.text = self.masterKey
            }.onTextChanged { [weak self] in
                self?.masterKey = $0
        }
        
        let serverUrlRow = TextFieldRowFormer<FormerFieldCell>(instantiateType: .Nib(nibName: "FormerFieldCell")) { [weak self] in
            $0.titleLabel.text = "Server URL"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "http://<url>:<port>/<path>"
                $0.text = self.serverUrl
            }.onTextChanged { [weak self] in
                self?.serverUrl = $0
        }
        
        // Create Headers
        
        let createHeader: ((String) -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 40
                    $0.text = text

            }
        }
        
        // Create SectionFormers
        
        let requiredSecion = SectionFormer(rowFormer: nameRow, appIdRow, masterKeyRow, serverUrlRow)
            .set(headerViewFormer: createHeader("Required"))
        
        let optionalSection = SectionFormer(rowFormer: imageRow)
            .set(headerViewFormer: createHeader("Optional"))
        
        former.append(sectionFormer: requiredSecion, optionalSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
    }
    
    fileprivate lazy var imageRow: LabelRowFormer<FormerImageCell> = {
        LabelRowFormer<FormerImageCell>(instantiateType: .Nib(nibName: "FormerImageCell")) {
            if let data = self.imageData {
                $0.iconView.image = UIImage(data: data)
            }
            }.configure {
                $0.text = "Choose icon image from library"
                $0.rowHeight = 60
            }.onSelected { [weak self] _ in
                self?.former.deselect(animated: true)
                self?.presentImagePicker()
        }
    }()
    
    private func isValid() -> Bool {
        
        guard let name = name, let id = applicationId, let key = masterKey, let url = serverUrl else { return handleError() }
        
        guard !name.isEmpty else { return handleError("Empty Name") }
        guard !id.isEmpty else { return handleError("Empty Application ID") }
        guard !key.isEmpty else { return handleError("Empty Master Key") }
        guard !url.isEmpty else { return handleError("Empty URL") }
        
        return true
    }
    
    func handleError(_ error: String = "Invalid Configuration") -> Bool {
        Ping(text: error, style: .danger).show()
        return false
    }
    
    // MARK: - User Actions
    
    @objc
    func cancelEdit() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func saveContext() {
        guard isValid() else { return }
        config.name = name
        config.applicationId = applicationId
        config.masterKey = masterKey
        config.serverUrl = serverUrl
        config.icon = imageData
        if config.managedObjectContext == nil {
            context?.insert(config)
        }
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        dismiss(animated: true, completion: nil)
    }
    
    func presentImagePicker() {
        
        let picker = DKImagePickerController()
        picker.assetType = .allPhotos
        picker.singleSelect = true
        picker.autoCloseOnSingleSelect = false
        picker.didSelectAssets = { assets in
            guard let asset = assets.first else {
                self.imageData = nil
                self.imageRow.cellUpdate { $0.iconView.image = nil }
                return
            }
            asset.fetchOriginalImageWithCompleteBlock({ image, _ in
                self.imageData = UIImageJPEGRepresentation(image!, 1)
                self.imageRow.cellUpdate { $0.iconView.image = image }
            })
        }
        picker.navigationBar.isTranslucent = false
        picker.navigationBar.tintColor = .logoTint
        present(picker, animated: true, completion: nil)
    }
}

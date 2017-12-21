//
//  FileViewController.swift
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
//  Created by Nathan Tannar on 8/31/17.
//

import UIKit
import Photos
import AlertHUDKit
import PDFReader

class FileViewController: UIViewController {
    
    // MARK: - Properties
    
    private var schema: PFSchema
    private var key: String
    private var url: URL?
    private var filename: String
    private var objectId: String
    
    fileprivate var currentFileData: Data? {
        didSet {
            if let data = currentFileData {
                if let image = UIImage(data: data) {
                    imageView.image = image
                    imageView.contentMode = .scaleAspectFill
                    actionButton.setTitle("Export Image", for: .normal)
                } else {
                    if filename.components(separatedBy: ".").last == "pdf" {
                        imageView.image = UIImage(named: "PDF")
                        actionButton.setTitle("View File", for: .normal)
                    } else {
                        imageView.image = UIImage(named: "File")
                        actionButton.setTitle("Export File", for: .normal)
                    }
                    imageView.contentMode = .center
                }
            } else {
                imageView.image = UIImage(named: "File")
                actionButton.setTitle("Download File", for: .normal)
            }
        }
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "File")
        imageView.contentMode = .center
        return imageView
    }()
    
    lazy var actionButton: UIButton = { [weak self] in
        let button = UIButton()
        button.setTitle("Download File", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .highlighted)
        button.backgroundColor = .logoTint
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(accessFile(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    
    init(url: URL?, filename: String, schema: PFSchema, key: String, objectId: String) {
        self.url = url
        self.filename = filename
        self.schema = schema
        self.key = key
        self.objectId = objectId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        
        view.backgroundColor = .darkPurpleAccent
        view.addSubview(imageView)
        view.addSubview(actionButton)
        imageView.fillSuperview()
        actionButton.anchorCenterXToSuperview()
        actionButton.anchor(widthConstant: 44*3, heightConstant: 44)
        actionButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 100).isActive = true
    }
    
    private func setupNavigationBar() {
        
        title = "File View"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(dismissInfo))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "Upload"),
                            style: .plain,
                            target: self,
                            action: #selector(uploadNewFile))
        ]
    }
    
    // MARK: - Data Refresh
    
    @objc
    func accessFile(_ sender: UIButton) {
        
        sender.isEnabled = false
        if currentFileData == nil {
            loadDataFromUrl()
        } else {
            exportFile()
        }
        sender.isEnabled = true
    }
    
    func loadDataFromUrl() {
        
        guard let url = url else {
            handleError("File does not exist")
            return
        }
        actionButton.isHidden = true
        let progressWheel = DownloadWheel()
        print("Download: ", url)
        progressWheel.downloadFile(from: url) { [weak self] (view, data, error) in
            self?.currentFileData = data
            guard error == nil else {
                self?.handleError(error?.localizedDescription)
                return
            }
            view.currentState = .active
            self?.actionButton.isHidden = false
        }.present(self)
    }
    
    func exportFile() {
        
        guard let data = currentFileData else { return }
        do {
            let directory = FileManager.default.temporaryDirectory
            let type = filename.components(separatedBy: ".").last!
            let path = directory.appendingPathComponent(filename)
            print("Writing to: ", path)
            try data.write(to: path, options: .completeFileProtection)
            
            // Try to render the file as a PDF
            if type == "pdf", let pdf = PDFDocument(url: path) {
                let readerController = PDFViewController.createNew(with: pdf, actionButtonImage: UIImage(named: "Share")?.withRenderingMode(.alwaysTemplate), actionStyle: .activitySheet)
                readerController.backgroundColor = .groupTableViewBackground
                navigationController?.pushViewController(readerController, animated: true)
            } else if let image = UIImage(data: data) {
                let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                present(activity, animated: true, completion: nil)
            } else {
                // Fallback on system to recognize file
                let activity = UIActivityViewController(activityItems: [path], applicationActivities: nil)
                present(activity, animated: true, completion: nil)
            }
            
        } catch let error {
            handleError(error.localizedDescription)
        }
    }
    
    // MARK: - User Actions
    
    @objc
    func dismissInfo() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func uploadNewFile() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.configureView()
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentImagePicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Document", style: .default, handler: { [weak self] _ in
            self?.presentDocumentPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    func deleteOldFile() {
        
        if let appId = Parse.shared.currentConfiguration?.applicationId,
           let urlString = url?.absoluteString.replacingOccurrences(of: "\(appId)/", with: ""),
           let url = URL(string: urlString) {
            // Delete the old file
            Parse.shared.delete(url: url, completion: { _, _ in
                Toast(text: "Deleted Old File").present(self)
            })
        }
        
        // Update the current url
        Parse.shared.get("/classes/\(schema.name)/\(objectId)") { [weak self] result, json in
            guard let json = json, let key = self?.key else { return }
            let updatedObject = PFObject(json)
            if let urlString = (updatedObject.value(forKey: key) as? [String:String])?["url"] {
                self?.url = URL(string: urlString)
            }
        }
    }
    
    func presentDocumentPicker() {
        
        if #available(iOS 11.0, *) {
            let documentBrowser = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: nil)
            documentBrowser.delegate = self
            documentBrowser.allowsDocumentCreation = false
            documentBrowser.allowsPickingMultipleItems = false
            documentBrowser.additionalLeadingNavigationBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelDocumentPicker))
            ]
            present(documentBrowser, animated: false, completion: nil)
        } else {
            handleError("Sorry, this is only available on iOS 11")
        }
    }
    
    @objc
    func cancelDocumentPicker() {
        if #available(iOS 11.0, *) {
            // Assume the presented controller is the UIDocumentBrowserViewController
            if let documentBrowser = UIApplication.shared.presentedController as? UIDocumentBrowserViewController {
                documentBrowser.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // MARK: - Image Picker
    
    func presentImagePicker() {
        
        let imagePicker = PFImagePickerController()
        imagePicker.onImageSelection { [weak self] image in
            guard let image = image else { return }
            guard let imageData = UIImageJPEGRepresentation(image, 1) else {
                self?.handleError("Invalid Image Data")
                return
            }
            self?.uploadFile(data: imageData, for: "jpg")
        }
        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - Error Handling
    
    func handleError(_ error: String?) {
        let error = error ?? "Unexpected Error"
        print(error)
        Ping(text: error, style: .danger).show(animated: true, duration: 3)
    }
    
    func handleSuccess(_ message: String?) {
        let message = message ?? "Success"
        print(message)
        Ping(text: message, style: .info).show(animated: true, duration: 3)
    }
}

extension FileViewController: UIDocumentBrowserViewControllerDelegate {
    
    // MARK: Document Picker Helpers
    
    private func openFile(at url: URL, completion: @escaping (Bool)->Void) {
        
        let file = File(fileURL: url)
        file.open { [weak self] success in
            completion(success)
            if success {
                guard let data = FileManager.default.contents(atPath: file.fileURL.path) else {
                    self?.handleError("Sorry, access to that file is unavailable")
                    return
                }
                let fileType = url.absoluteString.components(separatedBy: ".").last!.lowercased()
                self?.uploadFile(data: data, for: fileType)
            } else {
                self?.handleError("Failed to open file")
            }
        }
    }
    
    private func uploadFile(data: Data, for fileType: String) {
        
        Toast(text: "Uploading").present(self, animated: true, duration: 1)
        Parse.shared.post(filename: self.filename , classname:  self.schema.name, key: self.key,
                          objectId: self.objectId, data: data, fileType: fileType, contentType: "application/\(fileType)",
                          completion: { [weak self] (result, json) in
            guard result.success else {
                self?.handleError(result.error)
                return
            }
            self?.handleSuccess("application/\(fileType) File Uploaded")
            self?.currentFileData = data
            self?.deleteOldFile()
        })
    }
    
    // MARK: UIDocumentBrowserViewControllerDelegate Helpers
    
    @available(iOS 11.0, *)
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {

        guard let url = documentURLs.first else { return }
        openFile(at: url) { success in
            if success {
                controller.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    @available(iOS 11.0, *)
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        openFile(at: destinationURL) { success in
            if success {
                controller.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    @available(iOS 11.0, *)
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        self.handleError(error?.localizedDescription)
    }
    
    @available(iOS 11.0, *)
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        // Not currently supported, but having this silences warnings
    }
}


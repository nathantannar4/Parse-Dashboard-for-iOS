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

import NTComponents
import Photos

class FileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    private var schema: PFSchema
    private var key: String
    private var url: String
    private var filename: String
    private var objectId: String
    
    let imageView: NTImageView = {
        let imageView = NTImageView()
        imageView.image = UIImage(named: "File")
        imageView.contentMode = .center
        return imageView
    }()
    
    // MARK: - Initialization
    
    init(_ _url: String, _filename: String, _schema: PFSchema, _key: String, _objectId: String) {
        url = _url
        filename = _filename
        schema = _schema
        key = _key
        objectId = _objectId
        super.init(nibName: nil, bundle: nil)
        self.imageView.loadImage(urlString: url) {
            if self.imageView.image != nil {
                self.imageView.contentMode = .scaleAspectFit
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .darkBlueBackground
        navigationController?.navigationBar.barTintColor = .darkBlueAccent
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(FileViewController.dismissInfo))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "Save"),
                            style: .plain,
                            target: self,
                            action: #selector(FileViewController.saveImage)),
            UIBarButtonItem(image: UIImage(named: "Upload"),
                            style: .plain,
                            target: self,
                            action: #selector(FileViewController.presentImagePicker))
        ]
        
        
        view.addSubview(imageView)
        imageView.fillSuperview()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissInfo))
        tapGesture.delegate = self
        let window = (UIApplication.shared.delegate as! AppDelegate).window
        window?.addGestureRecognizer(tapGesture)
    }
    
    func dismissInfo() {
        dismiss(animated: true, completion: nil)
    }
    
    func saveImage() {
        guard let image = imageView.image else { return }
        if image == UIImage(named: "File") { return }
        PHPhotoLibrary.shared().performChanges( { PHAssetChangeRequest.creationRequestForAsset(from: image) },completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    NTToast(text: "Saved to camera roll", color: .lightBlueBackground, height: 50).show(self.navigationController?.view, duration: 2.0)
                } else {
                    NTToast(text: "Error saving to camera roll", color: .lightBlueBackground, height: 50).show(self.navigationController?.view, duration: 2.0)
                }
            }
        })
        
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func presentImagePicker() {
        self.navigationController?.view.layer.cornerRadius = 0
        let picker = NTImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            guard let imageData = UIImageJPEGRepresentation(image, 1) else {
                NTToast.genericErrorMessage()
                return
            }
            Parse.post(filename: self.filename , classname:  self.schema.name!, key: self.key, objectId: self.objectId, imageData: imageData, completion: { (response, json, success) in
                DispatchQueue.main.async {
                    NTToast(text: response, color: .lightBlueBackground, height: 50).show(self.navigationController?.view, duration: 2.0)
                    print(json)
                    self.imageView.contentMode = .scaleAspectFit
                    self.imageView.image = image
                }
            })
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        let point = touch.location(in: nil)
        guard let frame = navigationController?.view.frame else {
            return true
        }
        return !frame.contains(point)
    }
}

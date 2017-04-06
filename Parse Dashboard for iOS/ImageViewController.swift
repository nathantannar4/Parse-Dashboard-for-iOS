//
//  ImageViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 3/5/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import NTComponents
import Photos

class ImageViewController: UIViewController {
    
    var parseClass: ParseClass!
    var key: String!
    var url: String!
    var filename: String!
    var objectId: String!
    
    let imageView: NTImageView = {
        let imageView = NTImageView()
        imageView.image = UIImage(named: "File")
        imageView.contentMode = .center
        return imageView
    }()
    
    convenience init(_ url: String, filename: String, parseClass: ParseClass, key: String, objectId: String) {
        self.init()
        self.url = url
        self.filename = filename
        self.parseClass = parseClass
        self.key = key
        self.objectId = objectId
        self.imageView.loadImage(urlString: url) {
            if self.imageView.image != nil {
                self.imageView.contentMode = .scaleAspectFit
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color(r: 14, g: 105, b: 160)
        navigationController?.navigationBar.barTintColor = Color(r: 21, g: 156, b: 238)
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .plain, target: self, action: #selector(dismissInfo))
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Save"), style: .plain, target: self, action: #selector(saveImage)), UIBarButtonItem(image: UIImage(named: "Upload"), style: .plain, target: self, action: #selector(presentImagePicker))]

        
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
        PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.creationRequestForAsset(from: image)},completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    Toast(text: "Saved to camera roll", color: Color(r: 21, g: 156, b: 238), height: 50).show(self.navigationController?.view, duration: 2.0)
                } else {
                    Toast(text: "Error saving to camera roll", color: Color(r: 21, g: 156, b: 238), height: 50).show(self.navigationController?.view, duration: 2.0)
                }
            }
        })

    }
}

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: UIImagePickerControllerDelegate
    
    func presentImagePicker() {
        self.navigationController?.view.layer.cornerRadius = 0
        let picker = UIImagePickerController()
        picker.view.tintColor = Color.Defaults.tint
        picker.navigationController?.navigationBar.tintColor = Color.Defaults.navigationBarTint
        picker.navigationController?.navigationBar.barTintColor = Color.Defaults.navigationBarBackground
        picker.navigationController?.navigationBar.isTranslucent = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            guard let imageData = UIImageJPEGRepresentation(image, 1) else {
                Toast.genericErrorMessage()
                return
            }
            Parse.post(filename: filename , classname:  self.parseClass!.name!, key: self.key, objectId: self.objectId, imageData: imageData, completion: { (response, json, success) in
                DispatchQueue.main.async {
                    Toast(text: response, color: Color(r: 21, g: 156, b: 238), height: 50).show(self.navigationController?.view, duration: 2.0)
                    print(json)
                    self.imageView.contentMode = .scaleAspectFit
                    self.imageView.image = image
                }
            })
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension ImageViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        let point = touch.location(in: nil)
        guard let frame = navigationController?.view.frame else {
            return true
        }
        if frame.contains(point) {
            return false
        }
        return true
    }
}

extension ImageViewController: UIViewControllerTransitioningDelegate {
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return PreviewPresentationController(presentedViewController: presented, presenting: presenting)
    }
}


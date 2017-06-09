//
//  AppInfoViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 3/4/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import NTComponents

class AppInfoViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = Color.Default.Tint.View
        navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Share"), style: .plain, target: self, action: #selector(shareApp(sender:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .plain, target: self, action: #selector(dismissInfo))
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.bounces = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissInfo))
        tapGesture.delegate = self
        let window = (UIApplication.shared.delegate as! AppDelegate).window
        window?.addGestureRecognizer(tapGesture)
    }
    
    func dismissInfo() {
        dismiss(animated: true, completion: nil)
    }
    
    func shareApp(sender: UIBarButtonItem) {
        let textItem = "Hey, Check out this awesome mobile Parse Dashboard client for iOS!"
        let activityVC = UIActivityViewController(activityItems: [textItem], applicationActivities: nil)
        activityVC.excludedActivityTypes = [
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]
        present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDatasource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Parse Dashboard for iOS"
            cell.textLabel?.font = Font.Default.Subtitle.withSize(18)
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            cell.addSubview(separatorView)
            separatorView.anchor(cell.textLabel?.bottomAnchor, left: cell.textLabel?.leftAnchor, bottom: nil, right: cell.textLabel?.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
        case 1:
            cell.textLabel?.text = "Parse Dashboard for iOS is a standalone dashboard for managing your Parse apps while you are on the go! Edit, create and delete data from your MongoDB. View and upload new image files.\n\nBased off of the original Parse Dashboard we all know and love."
            cell.textLabel?.textColor = UIColor.darkGray
            cell.textLabel?.font = Font.Default.Body.withSize(15)
        case 2:
            let imageView = UIImageView(image: UIImage(named: "Dashboard"))
            imageView.contentMode = .scaleToFill
            imageView.layer.borderWidth = 10
            imageView.layer.borderColor = UIColor.white.cgColor
            cell.addSubview(imageView)
            imageView.fillSuperview()
        case 3:
            cell.textLabel?.text = "Data Security"
            cell.textLabel?.font = Font.Default.Subtitle.withSize(18)
            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray
            cell.addSubview(separatorView)
            separatorView.anchor(cell.textLabel?.bottomAnchor, left: cell.textLabel?.leftAnchor, bottom: nil, right: cell.textLabel?.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
        case 4:
            cell.textLabel?.text = "Privacy and data protection is important. Know that your Parse Server's application ID and master key are only stored on your devices core data."
            cell.textLabel?.textColor = UIColor.darkGray
            cell.textLabel?.font = Font.Default.Body.withSize(15)
        default:
            break
        }
        return cell
    }
}

extension AppInfoViewController: UIGestureRecognizerDelegate {
    
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

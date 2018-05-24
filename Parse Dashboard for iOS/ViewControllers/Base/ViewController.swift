//
//  ViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 4/30/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit
import AlertHUDKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    override var title: String? {
        didSet {
            updateTitleView()
        }
    }
    
    var subtitle: String? {
        didSet {
            updateTitleView()
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    private func updateTitleView() {
        
        let backgroundColor = navigationController?.navigationBar.barTintColor
        let baseColor: UIColor = (backgroundColor?.isLight ?? false) ? .black : .white
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = baseColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.textColor = baseColor.isDark ? UIColor.darkGray : baseColor.darker()
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        if subtitle != nil {
            titleView.addSubview(subtitleLabel)
        } else {
            titleLabel.frame = titleView.frame
        }
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        navigationItem.titleView = titleView
        
    }
    
    // MARK: - Error/Success HUD
    
    func handleError(_ error: String?) {
        let error = error ?? Localizable.unknownError.localized
        print(error)
        Ping(text: error, style: .danger).show(animated: true, duration: 3)
    }
    
    func handleSuccess(_ message: String?) {
        let message = message ?? Localizable.success.localized
        print(message)
        Ping(text: message, style: .info).show(animated: true, duration: 3)
    }
    
}

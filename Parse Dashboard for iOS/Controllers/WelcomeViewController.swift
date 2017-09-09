//
//  WelcomeViewController.swift
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
//  Created by Nathan Tannar on 9/6/17.
//

import UIKit
import NTComponents

class WelcomeViewController: UIViewController {
    
    // MARK: - Properties
    
    var logoView: UIView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Logo").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        
        let view = UIView()
        view.backgroundColor = .logoTint
        view.addSubview(imageView)
        imageView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 44, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        return view
    }()
    
    var titleLabel: NTLabel = {
        let label = NTLabel()
        label.text = "Parse Dashboard for iOS"
        if UIDevice.current.userInterfaceIdiom == .pad {
            label.font = Font.Default.Title.withSize(40)
        } else {
            label.font = Font.Default.Title.withSize(24)
        }
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    var descriptionLabel: NTLabel = {
        let label = NTLabel()
        label.text = "A beautiful unofficial moile client for managing your Parse apps while you are on the go! Now you can easily view and modify your data in the same way you would on the offical desktop client."
        if UIDevice.current.userInterfaceIdiom == .pad {
            label.font = Font.Default.Body.withSize(30)
        } else {
            label.font = Font.Default.Body.withSize(18)
        }
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var getStartedButton: NTButton = { [weak self] in
        let button = NTButton()
        button.title = "Get Started"
        if UIDevice.current.userInterfaceIdiom == .pad {
            button.titleFont = Font.Roboto.Medium.withSize(36)
        } else {
            button.titleFont = Font.Roboto.Medium.withSize(18)
        }
        button.backgroundColor = .darkBlueAccent
        button.tintColor = .white
        button.addTarget(self, action: #selector(WelcomeViewController.getStarted), for: .touchUpInside)
        return button
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .darkBlueBackground
        UIApplication.shared.statusBarStyle = .lightContent
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.barTintColor = .logoTint
    }
    
    private func setupSubviews() {
        
        view.addSubview(logoView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(getStartedButton)
    }
    
    private func setupConstraints() {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            logoView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 244)
            titleLabel.anchor(logoView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 44, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)
            descriptionLabel.anchor(titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 44, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 200)
            getStartedButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 120)
            
        } else {
            logoView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 144)
            titleLabel.anchor(logoView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 44, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
            descriptionLabel.anchor(titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 44, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 120)
            getStartedButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 60)
        }
    }
    
    // MARK: - User Actions
    
    func getStarted() {
        
        let vc = NTNavigationController(rootViewController: ServerViewController())
        presentViewController(vc, from: .right, completion: nil)
    }
}

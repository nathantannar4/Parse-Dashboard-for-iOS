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

final class WelcomeViewController: ViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    // MARK: - Subviews
    
    private let logoView: UIView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        
        let view = UIView()
        view.backgroundColor = .logoTint
        view.addSubview(imageView)
        imageView.anchorCenterToSuperview()
        imageView.anchor(widthConstant: 100, heightConstant: 100)
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Parse Dashboard for iOS"
        if UIDevice.current.userInterfaceIdiom == .pad {
            label.font = UIFont.boldSystemFont(ofSize: 40)
        } else {
            label.font = UIFont.boldSystemFont(ofSize: 24)
        }
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.appDescription.localized
        if UIDevice.current.userInterfaceIdiom == .pad {
            label.font = UIFont.systemFont(ofSize: 30)
        } else {
            label.font = UIFont.systemFont(ofSize: 14)
        }
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var getStartedButton: RippleButton = { [weak self] in
        let button = RippleButton()
        button.setTitle(Localizable.getStarted.localized, for: .normal)
        if UIDevice.current.userInterfaceIdiom == .pad {
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 36)
        } else {
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        }
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .highlighted)
        button.backgroundColor = .darkBlueAccent
        button.rippleColor = UIColor.darkBlueAccent.lighter()
        button.addTarget(self, action: #selector(WelcomeViewController.getStarted), for: .touchUpInside)
        return button
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: .isConsoleHidden)
        view.backgroundColor = .darkBlueBackground
        navigationController?.navigationBar.barTintColor = .logoTint
        setupSubviews()
        setupConstraints()
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        
        view.addSubview(logoView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(getStartedButton)
    }
    
    private func setupConstraints() {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            logoView.anchor(view.layoutMarginsGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 244)
            titleLabel.anchor(logoView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 44, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 40)
            descriptionLabel.anchor(titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 44, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 200)
            getStartedButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 120)
            
        } else {
            logoView.anchor(view.layoutMarginsGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 144)
            
            let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            view.addSubview(stackView)
            stackView.anchor(logoView.bottomAnchor, left: view.layoutMarginsGuide.leftAnchor, bottom: getStartedButton.topAnchor, right: view.layoutMarginsGuide.rightAnchor, topConstant: 10, bottomConstant: 10)
            
            getStartedButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 80)
        }
    }
    
    // MARK: - User Actions
    
    @objc
    func getStarted() {
        let rootViewController = NavigationController(rootViewController: ServersViewController())
        UIApplication.shared.presentedWindow?.switchRootViewController(
            rootViewController,
            animated: true,
            duration: 0.3,
            options: .transitionFlipFromRight,
            completion: nil)
    }
}

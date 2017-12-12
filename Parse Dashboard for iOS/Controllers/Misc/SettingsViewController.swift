//
//  SettingsViewController.swift
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
//  Created by Nathan Tannar on 12/11/17.
//

import UIKit
import Former

class SettingsViewController: FormViewController {
    
    // MARK: - Properties
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Settings"
        tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "Settings")?.withRenderingMode(.alwaysTemplate), selectedImage: UIImage(named: "Settings"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        configureForm()
    }
    
    private func setupNavigationBar() {
        configure()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(dismissInfo))
    }
    
    private func configureForm() {
        
        let switchRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "Biometric Authorization"
            $0.titleLabel.textColor = .black
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.switchButton.onTintColor = .logoTint
            }.configure {
                $0.switched = Auth.shared.isSetup
            }.onSwitchChanged { newValue in
                if newValue == false {
                    Auth.shared.destroy(completion: { (result) in
                        
                    })
                } else {
                    UserDefaults.standard.set(true, forKey: "isSetup")
                }
        }
        
        let section = SectionFormer(rowFormer: switchRow)
            .set(headerViewFormer: LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 40
                    $0.text = "Security"
        })
        former.append(sectionFormer: section)
    }
    
    // MARK: - User Actions
    
    @objc
    func dismissInfo() {
        dismiss(animated: true, completion: nil)
    }
}

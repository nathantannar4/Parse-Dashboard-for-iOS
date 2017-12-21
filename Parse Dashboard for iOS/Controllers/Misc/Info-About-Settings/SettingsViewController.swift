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
import AlertHUDKit
import AcknowList
import MessageUI

class SettingsViewController: FormViewController {
    
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
        buildForm()
    }
    
    private func setupNavigationBar() {
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .logoTint
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 24),
                NSAttributedStringKey.foregroundColor : UIColor.white
            ]
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(dismissInfo))
    }
    
    private func buildForm() {
        
        let switchRow = SwitchRowFormer<FormSwitchCell>() {
                $0.titleLabel.text = Auth.shared.method()
                $0.titleLabel.textColor = .black
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                $0.switchButton.onTintColor = .logoTint
            }.configure {
                $0.switched = Auth.shared.isSetup
            }.onSwitchChanged { newValue in
                if newValue == false {
                    Auth.shared.destroy(completion: { (result) in
                        if result {
                            UserDefaults.standard.set(false, forKey: .isSetup)
                        }
                    })
                } else {
                    UserDefaults.standard.set(true, forKey: .isSetup)
                }
        }
        
        let bugReportRow = LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                $0.accessoryType = .disclosureIndicator
            }.configure {
                $0.text = "Report a Bug"
            }.onSelected { _ in
                self.former.deselect(animated: true)
                if MFMailComposeViewController.canSendMail() {
                    let vc = MFMailComposeViewController()
                    vc.mailComposeDelegate = self
                    vc.setToRecipients(["nathantannar4@gmail.com"])
                    vc.setSubject("[Parse Dashboard for iOS] - Bug Report")
                    self.present(vc, animated: true, completion: nil)
                } else {
                    Ping(text: "No Mail Accounts Setup", style: .danger).show()
                }
        }
        
        let featureRequestRow = LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                $0.accessoryType = .disclosureIndicator
            }.configure {
                $0.text = "Request a Feature"
            }.onSelected { _ in
                self.former.deselect(animated: true)
                if MFMailComposeViewController.canSendMail() {
                    let vc = MFMailComposeViewController()
                    vc.mailComposeDelegate = self
                    vc.setToRecipients(["nathantannar4@gmail.com"])
                    vc.setSubject("[Parse Dashboard for iOS] - Feature Request")
                    self.present(vc, animated: true, completion: nil)
                } else {
                    Ping(text: "No Mail Accounts Setup", style: .danger).show()
                }
        }
        
        let resetTutorialRow = LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            }.configure {
                $0.text = "Reset Tutorial"
            }.onSelected { _ in
                UserDefaults.standard.set(true, forKey: .isNew)
                let toast = Toast(text: "Tutorial Reset", actionText: "Undo", action: {
                    UserDefaults.standard.set(false, forKey: .isNew)
                })
                toast.backgroundColor = .darkGray
                toast.present(self, animated: true, duration: 3)
                self.former.deselect(animated: true)
        }
        
        let acknowledgementRow = LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                $0.accessoryType = .disclosureIndicator
            }.configure {
                $0.text = "Acknowledgements"
            }.onSelected { _ in
                self.former.deselect(animated: true)
                let path = Bundle.main.path(forResource: "Pods-Parse Dashboard for iOS-acknowledgements", ofType: "plist")!
                let vc = AcknowListViewController(acknowledgementsPlistPath: path)
                vc.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
                self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let createHeader: ((String) -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 40
                    $0.text = text
                    
            }
        }
        
        let securitySection = SectionFormer(rowFormer: switchRow)
            .set(headerViewFormer: createHeader("Security"))
        
        let supportSection = SectionFormer(rowFormer: bugReportRow, featureRequestRow)
            .set(headerViewFormer: createHeader("Support"))
    
        let otherSection = SectionFormer(rowFormer: resetTutorialRow, acknowledgementRow)
            .set(headerViewFormer: createHeader("Other"))
            .set(footerViewFormer: {
                return LabelViewFormer<FormLabelFooterView>()
                    .configure {
                        $0.viewHeight = 32
                        $0.text = "Version " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                }
            }())
            
        former.append(sectionFormer: securitySection, supportSection, otherSection)
    }
    
    // MARK: - User Actions
    
    @objc
    func dismissInfo() {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let error = error {
            Ping(text: error.localizedDescription, style: .danger).show()
        } else {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

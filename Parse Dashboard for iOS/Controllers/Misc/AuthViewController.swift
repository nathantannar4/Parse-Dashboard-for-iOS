//
//  AuthViewController.swift
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
//  Created by Nathan Tannar on 12/4/17.
//

import UIKit
import BiometricAuthentication

class AuthViewController: UIViewController {
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(blurView)
        blurView.fillSuperview()
        view.backgroundColor = .clear
    }
    
    // MARK: - Handlers
    
    func handleError(_ error: String?) {
        let error = error?.capitalized ?? "Unexpected Error"
        let ping = Ping(text: error, style: .danger)
        print(error)
        ping.show(animated: true, duration: 5)
    }
    
    // MARK: - User Actions
    
    @objc
    func dismissAuth() {
        dismiss(animated: true, completion: nil)
    }
    
    func authenticateUser(completion: @escaping (Bool)->Void) {
        
        if BioMetricAuthenticator.canAuthenticate() {
            authenticateWithBiometrics(completion: { success in
                if success {
                    self.dismissAuth()
                    completion(true)
                } else {
                    self.authenticateWithPassword(success: {
                        self.dismissAuth()
                        completion(true)
                    })
                }
            })
        } else {
            self.authenticateWithPassword(success: {
                self.dismissAuth()
                completion(true)
            })
        }
    }

    private func authenticateWithBiometrics(completion: @escaping (Bool)->Void) {
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "", success: {
            completion(true)
        }) { error in
            self.handleError(error.message())
            if error == .fallback || error == .biometryLockedout {
                completion(false)
            }
        }
    }

    private func authenticateWithPassword(success: @escaping ()->Void) {
        BioMetricAuthenticator.authenticateWithPasscode(reason: "", cancelTitle: nil, success: {
            success()
        }) { (error) in
            self.handleError(error.message())
            self.authenticateWithPassword(success: success)
        }
    }
}

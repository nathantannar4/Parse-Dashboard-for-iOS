//
//  Auth.swift
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

class Auth: NSObject {
    
    static var shared = Auth()
    
    // MARK: - Properties
    
    var granted: Bool {
        return isGranted || !isSetup
    }
    
    var isSetup: Bool {
        return UserDefaults.standard.bool(forKey: "isSetup")
    }
    
    private var isGranted: Bool = false
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
    }
    
    // MARK: - Methods
    
    func unlock(over viewController: UIViewController) {
        let authViewController = AuthViewController()
        viewController.present(authViewController, animated: true) {
            authViewController.authenticateUser(completion: { (success) in
                self.isGranted = success
            })
        }
    }
    
    func lock() {
        isGranted = false
    }
    
    func destroy(over viewController: UIViewController) {
        let authViewController = AuthViewController()
        viewController.present(authViewController, animated: true) {
            authViewController.authenticateUser(completion: { (success) in
                self.isGranted = false
                UserDefaults.standard.set(false, forKey: "isSetup")
            })
        }
    }
}

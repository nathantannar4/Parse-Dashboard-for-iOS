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
import BiometricAuthentication

class Auth: NSObject {
    
    static var shared = Auth()
    
    // MARK: - Properties
    
    var granted: Bool {
        return isGranted || !isSetup
    }
    
    var isSetup: Bool {
        return UserDefaults.standard.bool(forKey: .isSetup)
    }
    
    private var isGranted: Bool = false
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
    }
    
    // MARK: - Methods [Public]
    
    func unlock(completion: @escaping (Bool)->Void) {
        authenticateUser { result in
            self.isGranted = result
            completion(result)
        }
    }
    
    func lock() {
        isGranted = false
    }
    
    func destroy(completion: @escaping (Bool)->Void) {
        authenticateUser { result in
            if result {
                self.isGranted = false
                UserDefaults.standard.set(false, forKey: .isSetup)
            }
            completion(result)
        }
    }
    
    // MARK: - Methods [Private]
    
    func authenticateUser(completion: @escaping (Bool)->Void) {
        
        if BioMetricAuthenticator.canAuthenticate() {
            authenticateWithBiometrics(completion: { success in
                if success {
                    completion(true)
                } else {
                    self.authenticateWithPassword(success: {
                        completion(true)
                    })
                }
            })
        } else {
            self.authenticateWithPassword(success: {
                completion(true)
            })
        }
    }
    
    private func authenticateWithBiometrics(completion: @escaping (Bool)->Void) {
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "", cancelTitle: nil, success: {
            completion(true)
        }) { error in
            if error == .fallback || error == .biometryLockedout{
                completion(false)
            }
        }
    }
    
    private func authenticateWithPassword(success: @escaping ()->Void) {
        BioMetricAuthenticator.authenticateWithPasscode(reason: "", cancelTitle: nil, success: {
            success()
        }) { (error) in
            print(error)
        }
    }
}

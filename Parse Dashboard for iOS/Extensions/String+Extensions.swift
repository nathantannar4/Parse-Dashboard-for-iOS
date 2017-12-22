//
//  String+Extensions.swift
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
//  Created by Nathan Tannar on 8/31/17.
//

import UIKit
import Foundation

extension String {
    
    static var configName: String {
        return "name"
    }
    
    static var applicationId: String {
        return "applicationId"
    }
    
    static var masterKey: String {
        return "masterKey"
    }
    
    static var serverUrl: String {
        return "serverUrl"
    }
    
    static var icon: String {
        return "icon"
    }
    
    static var objectId: String {
        return "objectId"
    }
    
    static var createdAt: String {
        return "createdAt"
    }
    
    static var updatedAt: String {
        return "updatedAt"
    }
    
    static var undefined: String {
        return "<undefined>"
    }
    
    static var null: String {
        return "<null>"
    }
    
    static var acl: String {
        return "ACL"
    }
    
    static var relation: String {
        return "Relation"
    }
    
    static var pointer: String {
        return "Pointer"
    }
    
    static var file: String {
        return "File"
    }
    
    static var boolean: String {
        return "Boolean"
    }
    
    static var string: String {
        return "String"
    }
    
    static var array: String {
        return "Array"
    }
    
    static var number: String {
        return "Number"
    }
    
    static var date: String {
        return "Date"
    }
    
    static var object: String {
        return "Object"
    }
    
    static var isNew: String {
        return "isNew"
    }
    
    static var isSetup: String {
        return "isSetup"
    }

    static var recentConfig: String {
        return "recentConfig"
    }
    
    static var isConsoleHidden: String {
        return "isConsoleHidden"
    }

}

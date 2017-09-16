//
//  PFObject.swift
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

import Foundation
import SwiftyJSON

class PFObject {
    
    var id: String
    var createdAt: String
    var updatedAt: String
    
    var keys: [String]
    var values: [Any]
    
    var json: JSON
    
    var schema: PFSchema
    
    init(_ dictionary: [String : AnyObject], _ schma: PFSchema) {
        
        self.json = JSON(dictionary)
        self.schema = schma
        
        self.id = (dictionary["objectId"] as? String) ?? .undefined
        let createdAt = (dictionary["createdAt"] as? String) ?? .undefined
        self.createdAt = createdAt
        self.updatedAt = (dictionary["updatedAt"] as? String) ?? createdAt
        
        self.keys = []
        self.values = []
        
        self.keys.append(.objectId)
        self.values.append(self.id)
        
        self.keys.append(.createdAt)
        self.values.append(createdAt)
        
        self.keys.append(.updatedAt)
        self.values.append(self.updatedAt)
        
        if let fields = schma.fields {
            
            for (key, _) in fields {
                if key != .objectId && key != .createdAt && key != .updatedAt && key != .acl {
                    self.keys.append(key)
                    let value = dictionary[key] ?? String.undefined as AnyObject
                    self.values.append(value)
                }
            }
        }
        
        self.keys.append(.acl)
        self.values.append(dictionary[.acl] ?? String.undefined as AnyObject)
    }
}


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
    
    // MARK: - Properties
    
    var id: String
    var json: JSON
    var createdAt = "createdAt: "
    var updatedAt = "updatedAt: "
    var schema: PFSchema?
    
    var keys: [String] {
        if let schemaKeys = schema?.fields?.keys {
            // Local object will not contain keys for values that are undefined/null
            var keys = Array(schemaKeys)
            if let index = keys.index(of: "className") {
                keys.remove(at: index)
            }
            if let index = keys.index(of: "type") {
                keys.remove(at: index)
            }
            return keys.sorted()
        }
        return Array(json.dictionaryValue.keys).sorted() // Fallback on local keys
    }
    
    // MARK: - Initialization
    
    init(_ dictionary: [String : AnyObject]) {
        
        json = JSON(dictionary)
        id = (dictionary[.objectId] as? String) ?? .undefined
        let createdAtString = (dictionary[.createdAt] as? String) ?? .undefined
        let updatedAtString = (dictionary[.updatedAt] as? String) ?? .undefined
        
        // Date Data Type
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: createdAtString) {
            createdAt += date.string(dateStyle: .medium, timeStyle: .short)
        }
        if let date = dateFormatter.date(from: updatedAtString) {
            updatedAt += date.string(dateStyle: .medium, timeStyle: .short)
        }
    }
    
    // MARK: - Methods
    
    func value(forKey key: String) -> Any? {
        return json.dictionaryObject?[key]
    }
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}


//
//  PFSchema.swift
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

class PFSchema {
    
    var name: String
    var fields: [String : AnyObject]?
    var permissions: [String : AnyObject]?
    
    let json: [String : AnyObject]?
    
    init(name: String) {
        self.name = name
        self.fields = nil
        self.permissions = nil
        self.json = nil
    }
    
    init(_ result: [String : AnyObject]) {
        
        self.json = result
        
        for parseClass in result {
            if parseClass.key == "fields" {
                self.fields = parseClass.value as? [String: AnyObject]
            } else if parseClass.key == "classLevelPermissions" {
                self.permissions = parseClass.value as? [String: AnyObject]
            }
        }
        
        guard let className = result["className"] as? String else {
            fatalError()
        }
        
        name = className
    }
    
    func typeForField(_ field: String?) -> String? {
        guard let field = field else { return nil }
        guard let dict = fields?[field] as? [String : AnyObject] else { return nil }
        return dict["type"] as? String
    }
}

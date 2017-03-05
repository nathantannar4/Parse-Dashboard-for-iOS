//
//  ParseServer.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 2/28/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import NTComponents

class Parse {
    
    private static var config: ParseServer?
    
    class func initialize(with server: ParseServer) {
        self.config = server
    }
    
    class func fetch(endpoint: String, query: String = String(), completion: @escaping ([String : AnyObject]) -> ()) {
        
        let urlString = self.config!.serverUrl! + endpoint
        var filterString = query
        var encodedQuery = String()
        
        if let range = query.range(of: "where=") {
            // Json Encoding required
            filterString = query.substring(to: range.lowerBound)
            let json = query.substring(from: range.upperBound)
            if let encodedJson = json.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                encodedQuery = "where=" + encodedJson
            }
        }
        
        print(urlString + filterString + encodedQuery)
        
        guard let url = URL(string: urlString + filterString + encodedQuery) else {
            Toast(text: "Invalid server URL").show(duration: 1.0)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(self.config?.applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.setValue(self.config?.masterKey, forHTTPHeaderField: "X-Parse-Master-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if error != nil {
                print(error.debugDescription)
                completion([:])
                Toast.genericErrorMessage()
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String : AnyObject] else { return }
                completion(json)
            } catch let error as NSError{
                print(error.debugDescription)
                completion([:])
            }
        }.resume()
    }
}

class ParseClass {
    
    let name: String
    let fields: [String : AnyObject]?
    let permissions: [String : AnyObject]?
    
    
    init(name: String?, fields: [String : AnyObject]?, permissions: [String : AnyObject]?) {
        self.name = name!
        self.fields = fields
        self.permissions = permissions
    }
}

class ParseObject {
    
    var id: String
    var createdAt: String
    var updatedAt: String
    
    var keys: [String]
    var values: [AnyObject]
    
    init(_ dictionary: [String : AnyObject]) {
        
        self.id = dictionary["objectId"] as! String
        
        //let dateFormatter = DateFormatter()
        //dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        //dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        self.createdAt = dictionary["createdAt"] as! String
        self.updatedAt = dictionary["updatedAt"] as! String
        
        self.keys = []
        self.values = []
        
        for dict in dictionary {
            self.keys.append(dict.key)
            self.values.append(dict.value)
        }
    }
}








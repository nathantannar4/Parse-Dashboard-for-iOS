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
    
    class func get(endpoint: String, query: String = String(), completion: @escaping ([String : AnyObject]) -> ()) {
        
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
            DispatchQueue.main.async {
                Toast(text: "Invalid server URL").show(duration: 1.0)
            }
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
    
    class func post(endpoint: String, body: String? = String(), completion: @escaping (String, [String : AnyObject], Bool) -> ()) {
        
        guard let url = URL(string: self.config!.serverUrl! + endpoint) else {
            DispatchQueue.main.async {
                Toast(text: "Invalid server URL").show(duration: 1.0)
            }
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.setValue(self.config?.applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.setValue(self.config?.masterKey, forHTTPHeaderField: "X-Parse-Master-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body?.data(using: .utf8)
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if error != nil {
                print(error.debugDescription)
                completion(error!.localizedDescription, [:], false)
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String : AnyObject] else {
                    completion("Sorry, an unexpected error occurred", [:], false)
                    return
                }
                if let error = json["error"] as? String {
                    completion(error, json, false)
                } else {
                    if let code = json["code"] as? Int {
                        if code == 1 {
                            completion(json["message"] as! String, json, false)
                            return
                        }
                    } else if let result = json["result"] as? Bool {
                        if !result {
                            completion("Faild to send push", json, false)
                            return
                        }
                    } else {
                        completion("Success", json, true)
                    }
                }
            } catch let error as NSError {
                completion(error.debugDescription, [:], false)
            }
        }.resume()
    }
    
    class func post(filename: String, classname: String, key: String, objectId: String, imageData: Data, completion: @escaping (String, [String : AnyObject], Bool) -> ()) {
        
        let name = key + ".jpg"
        guard let url = URL(string: self.config!.serverUrl! + "/files/" + name) else {
            DispatchQueue.main.async {
                Toast(text: "Invalid server URL").show(duration: 1.0)
            }
            return
        }
        print(url)
        DispatchQueue.main.async {
            Toast(text: "Uploading File", color: Color(r: 21, g: 156, b: 238), height: 50).show(duration: 5.0)
        }
        var request = URLRequest(url: url)
        request.setValue(self.config?.applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.setValue(self.config?.masterKey, forHTTPHeaderField: "X-Parse-Master-Key")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = imageData
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if error != nil {
                print(error.debugDescription)
                completion(error!.localizedDescription, [:], false)
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String : AnyObject] else {
                    completion("Sorry, an unexpected error occurred", [:], false)
                    return
                }
                if let error = json["error"] as? String {
                    completion(error, json, false)
                } else {
                    if let code = json["code"] as? Int {
                        if code == 1 {
                            completion(json["message"] as! String, json, false)
                            return
                        }
                    } else if let result = json["result"] as? Bool {
                        if !result {
                            completion("Faild to upload image", json, false)
                            return
                        }
                    } else {
                        var file: [String : String] = [:]
                        file["__type"] = "File"
                        file["name"] = json["name"] as? String
                        file["url"] = json["url"] as? String
                        let jsonObject: [String : [String : String]] = [key : file]
                        do {
                            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                            Parse.put(endpoint: "/classes/" + classname + "/" + objectId, data: data, completion: { (response, json, success) in
                                completion("Success", json, true)
//                                Parse.delete(endpoint: "/files/" + filename, completion: { (response, code, success) in
//                                })
                            })
                        } catch {}
                    }
                }
            } catch let error as NSError {
                completion(error.debugDescription, [:], false)
            }
        }.resume()
    }
    
    class func put(endpoint: String, body: String = String(), data: Data? = nil, completion: @escaping (String, [String : AnyObject], Bool) -> ()) {
        
        guard let url = URL(string: self.config!.serverUrl! + endpoint) else {
            DispatchQueue.main.async {
                Toast(text: "Invalid server URL").show(duration: 1.0)
            }
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.setValue(self.config?.applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.setValue(self.config?.masterKey, forHTTPHeaderField: "X-Parse-Master-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = data ?? body.data(using: .utf8)
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if error != nil {
                print(error.debugDescription)
                completion(error!.localizedDescription, [:], false)
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String : AnyObject] else {
                    completion("Sorry, an unexpected error occurred", [:], false)
                    return
                }
                if let error = json["error"] as? String {
                    completion(error, json, false)
                } else {
                    if let code = json["code"] as? Int {
                        if code == 1 {
                            completion(json["message"] as! String, json, false)
                            return
                        }
                    } else if let result = json["result"] as? Bool {
                        if !result {
                            completion("Faild to send push", json, false)
                            return
                        }
                    } else {
                        completion("Success", json, true)
                    }
                }
            } catch let error as NSError {
                completion(error.debugDescription, [:], false)
            }
        }.resume()
    }
    
    class func delete(endpoint: String, completion: @escaping (String, Int?, Bool) -> ()) {
        
        guard let url = URL(string: self.config!.serverUrl! + endpoint) else {
            DispatchQueue.main.async {
                Toast(text: "Invalid server URL").show(duration: 1.0)
            }
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.setValue(self.config?.applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.setValue(self.config?.masterKey, forHTTPHeaderField: "X-Parse-Master-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if error != nil {
                print(error.debugDescription)
                completion(error!.localizedDescription, (response as? HTTPURLResponse)?.statusCode, false)
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String : AnyObject] else {
                    completion("Sorry, an unexpected error occurred", -1, false)
                    return
                }
                if let error = json["error"] as? String {
                    let code = json["code"] as? Int
                    completion(error, code, false)
                } else {
                    completion("Success", 0, true)
                }
            } catch let error as NSError {
                completion(error.debugDescription, error.code, false)
            }
        }.resume()
    }
}

class ParseClass {
    
    var name: String?
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
            } else if parseClass.key == "className" {
                self.name = "\(parseClass.value)"
            }
        }
    }
    
    func typeForField(_ field: String?) -> String? { 
        guard let field = field else { return nil }
        guard let dict = fields?[field] as? [String : AnyObject] else { return nil }
        return dict["type"] as? String
    }
}

class ParseObject {
    
    var id: String
    var createdAt: String
    var updatedAt: String
    
    var keys: [String]
    var values: [AnyObject]
    
    var json: [String : AnyObject]
    
    init(_ dictionary: [String : AnyObject]) {
        
        self.json = dictionary
        
        self.id = (dictionary["objectId"] as? String) ?? "<null>"
    
        let createdAt = (dictionary["createdAt"] as? String) ?? "<null>"
        self.createdAt = createdAt
        self.updatedAt = (dictionary["updatedAt"] as? String) ?? createdAt
        
        self.keys = []
        self.values = []
        
        for dict in dictionary {
            self.keys.append(dict.key)
            self.values.append(dict.value)
        }
    }
}








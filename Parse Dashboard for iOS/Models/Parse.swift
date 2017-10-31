//
//  Parse.swift
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
//  Created by Nathan Tannar on 8/30/17.
//

import Foundation
import NTComponents

class Parse {
    
    private static var config: ParseServerConfig?
    
    open weak static var container: UIControllerContainer? {
        didSet {
            isConnectedToNetwork = true
        }
    }
    
    private static var isConnectedToNetwork = true
    
    class func current() -> ParseServerConfig? {
        return Parse.config
    }
    
    class func initialize(_ config: ParseServerConfig) {
        self.config = config
    }
    
    class func isNetworkConnection() -> Bool {
        
        guard UIApplication.isConnectedToNetwork else {
            if isConnectedToNetwork {
                container?.trayView.backgroundColor = Color.Red.P500
                container?.toastAlert(text: "No Network Connection", font: UIFont.boldSystemFont(ofSize: 15), duration: nil, completion: nil)
                isConnectedToNetwork = false
            }
            return false
        }
        if !isConnectedToNetwork {
            container?.trayView.backgroundColor = Color.Green.P500
            container?.toastAlert(text: "Network Connection Restored", font: UIFont.boldSystemFont(ofSize: 15), duration: 1, completion: nil)
            isConnectedToNetwork = true
        }
        return true
    }
    
    class func get(endpoint: String, query: String = String(), completion: @escaping ([String : AnyObject]) -> ()) {
        
        guard isNetworkConnection() else {
            completion([:])
            return
        }
        
        let urlString = self.config!.serverUrl! + endpoint
        var filterString = query
        var encodedQuery = String()
        
        if let range = query.range(of: "where=") {
            // Json Encoding required
            filterString = String(query.prefix(upTo: range.lowerBound))
            let json = String(query.suffix(from: range.upperBound))
            if let encodedJson = json.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                encodedQuery = "where=" + encodedJson
            }
        }
        
        print(urlString + filterString + encodedQuery)
        
        guard let url = URL(string: urlString + filterString + encodedQuery) else {
            DispatchQueue.main.async {
                NTToast(text: "Invalid server URL").show(duration: 1.0)
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
                if let error = json["error"] as? String {
                    DispatchQueue.main.async {
                        NTToast(text: error, color: .darkPurpleAccent).show(duration: 1.0)
                    }
                } else {
                    completion(json)
                }
            } catch let error as NSError{
                print(error.debugDescription)
                completion([:])
            }
        }.resume()
    }
    
    class func post(endpoint: String, body: String? = String(), completion: @escaping (String, [String : AnyObject], Bool) -> ()) {
        
        guard isNetworkConnection() else {
            completion("",[:], false)
            return
        }
        
        guard let url = URL(string: self.config!.serverUrl! + endpoint) else {
            DispatchQueue.main.async {
                NTToast(text: "Invalid server URL").show(duration: 1.0)
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
        
        guard isNetworkConnection() else {
            completion("",[:], false)
            return
        }
        
        let name = key + ".jpg"
        guard let url = URL(string: self.config!.serverUrl! + "/files/" + name) else {
            DispatchQueue.main.async {
                NTToast(text: "Invalid server URL").show(duration: 1.0)
            }
            return
        }

        DispatchQueue.main.async {
            NTToast(text: "Uploading File", color: UIColor(r: 21, g: 156, b: 238), height: 50).show(duration: 5.0)
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
        
        guard isNetworkConnection() else {
            completion("",[:], false)
            return
        }
        
        guard let url = URL(string: self.config!.serverUrl! + endpoint) else {
            DispatchQueue.main.async {
                NTToast(text: "Invalid server URL").show(duration: 1.0)
            }
            return
        }

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
        
        guard isNetworkConnection() else {
            completion("", nil, false)
            return
        }
        
        guard let url = URL(string: self.config!.serverUrl! + endpoint) else {
            DispatchQueue.main.async {
                NTToast(text: "Invalid server URL").show(duration: 1.0)
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

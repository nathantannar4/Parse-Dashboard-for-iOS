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

import UIKit

typealias PFResult = (success: Bool, error: String?)
typealias PFCompletionBlock = (PFResult, [String:AnyObject]?) -> Void

class Parse: NSObject {
    
    // MARK: - Properties
    
    static var shared = Parse()
    
    public private(set) var currentConfiguration: ParseServerConfig? {
        didSet {
            let hashedConfig: [String:String?] = [
                .configName     : currentConfiguration?.name ?? "App",
                .applicationId  : currentConfiguration?.applicationId ?? "",
                .masterKey      : currentConfiguration?.masterKey ?? "",
                .serverUrl      : currentConfiguration?.serverUrl ?? ""
            ]
            UserDefaults.standard.set(hashedConfig, forKey: .recentConfig)
        }
    }
    
    // MARK: - Initialization
    
    // Use `shared`
    private override init() {
        super.init()
    }
    
    // MARK: - Methods [Public]
    
    func initialize(with config: ParseServerConfig) {
        currentConfiguration = config
    }
    
    func get(_ endpoint: String, query: String = "", completion: @escaping PFCompletionBlock) {
        
        guard UIApplication.shared.isConnectedToNetwork else {
            return completion((false, "Network Connection Unavailable"), nil)
        }
        
        guard let serverURL = currentConfiguration?.serverUrl else {
            return completion((false, "Invalid Server URL"), nil)
        }
        
        var urlString = serverURL + endpoint

        if let range = query.range(of: "where=") {
            // Json Encoding required
            urlString += String(query.prefix(upTo: range.lowerBound))
            let json = String(query.suffix(from: range.upperBound))
            if let encodedQuery = json.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                urlString += ("where=" + encodedQuery)
            }
        } else {
            urlString += query
        }
        
        guard let url = URL(string: urlString) else {
            return completion((false, "Invalid Server URL"), nil)
        }

        var request = PFRequest(url: url)
        request.httpMethod = "GET"
        logToConsole("GET: " + url.absoluteString, kind: .info)
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            guard let data = data, error == nil else {
                self.logToConsole(error.debugDescription, kind: .error)
                DispatchQueue.main.sync { completion((false, error?.localizedDescription), nil) }
                return
            }
            self.logToConsole("RESPONSE: \(data.count) bytes", kind: .success)
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject]
                if let error = json?["error"] as? String {
                    
                    DispatchQueue.main.sync { completion((false, error), json) }
                    
                } else {
                    
                    DispatchQueue.main.sync { completion((true, nil), json) }
                }
            } catch let error {
                
                DispatchQueue.main.sync { completion((false, error.localizedDescription), nil) }
                
            }
        }.resume()
    }
    
    func post(_ endpoint: String, data: Data? = nil, completion: @escaping PFCompletionBlock) {
        
        guard UIApplication.shared.isConnectedToNetwork else {
            return completion((false, "Network Connection Unavailable"), nil)
        }
        
        guard let serverURL = currentConfiguration?.serverUrl, let url = URL(string: serverURL + endpoint) else {
            return completion((false, "Invalid Server URL"), nil)
        }
        
        
        var request = PFRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        logToConsole("POST: \(data?.count ?? 0) bytes to" + url.absoluteString, kind: .info)
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            guard let data = data, error == nil else {
                self.logToConsole(error.debugDescription, kind: .error)
                DispatchQueue.main.sync { completion((false, error?.localizedDescription), nil) }
                return
            }
            self.logToConsole("RESPONSE: \(data.count) bytes", kind: .success)
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject] else { return }
                if let error = json["error"] as? String {
                    
                    DispatchQueue.main.sync { completion((false, error), nil) }
                    
                } else {
                    if let code = json["code"] as? Int, code == 1 {
                        
                        DispatchQueue.main.sync { completion((false, json["message"] as? String), json) }
                        
                    } else {
                        
                        let result = json["result"] as? Bool ?? true
                        DispatchQueue.main.sync { completion((result, nil), json) }
                        
                    }
                }
            } catch let error {
                DispatchQueue.main.sync { completion((false, error.localizedDescription), nil) }
            }
        }.resume()
    }
    
    func delete(_ endpoint: String, completion: @escaping PFCompletionBlock) {
        
        guard let serverURL = currentConfiguration?.serverUrl, let url = URL(string: serverURL + endpoint) else {
            return completion((false, "Invalid Server URL"), nil)
        }
        delete(url: url, completion: completion)
    }
    
    func delete(url: URL, completion: @escaping PFCompletionBlock) {
        
        guard UIApplication.shared.isConnectedToNetwork else {
            return completion((false, "Network Connection Unavailable"), nil)
        }
        
        var request = PFRequest(url: url)
        request.httpMethod = "DELETE"
        logToConsole("DELETE: " + url.absoluteString, kind: .info)
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            guard let data = data, error == nil else {
                self.logToConsole(error.debugDescription, kind: .error)
                DispatchQueue.main.sync { completion((false, error?.localizedDescription), nil) }
                return
            }
            self.logToConsole("RESPONSE: \(data.count) bytes", kind: .success)
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject]
                if let error = json?["error"] as? String {
                    
                    DispatchQueue.main.sync { completion((false, error), json) }
                    
                } else {
                    
                    DispatchQueue.main.sync { completion((true, nil), json) }
                    
                }
            } catch let error {
                DispatchQueue.main.sync { completion((false, error.localizedDescription), nil) }
            }
        }.resume()
    }

    func post(filename: String, classname: String, key: String,
              objectId: String, data: Data?, fileType: String, contentType: String,
              completion: @escaping PFCompletionBlock) {
        
        guard UIApplication.shared.isConnectedToNetwork else {
            return completion((false, "Network Connection Unavailable"), nil)
        }
        
        let name = key + "." + fileType
        guard let serverURL = currentConfiguration?.serverUrl, let url = URL(string: serverURL + "/files/" + name) else {
            return completion((false, "Invalid Server URL"), nil)
        }

        var request = PFRequest(url: url)
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = data
        logToConsole("POST: \(data?.count ?? 0) bytes to " + url.absoluteString, kind: .info)
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            guard let data = data, error == nil else {
                self.logToConsole(error.debugDescription, kind: .error)
                DispatchQueue.main.sync { completion((false, error?.localizedDescription), nil) }
                return
            }
            self.logToConsole("RESPONSE: \(data.count) bytes", kind: .success)
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject]
                
                if let error = json?["error"] as? String {
                    
                    DispatchQueue.main.sync { completion((false, error), json) }
                    
                } else {
                    if let code = json?["code"] as? Int, code == 1 {
                        
                        DispatchQueue.main.sync { completion((false, json?["message"] as? String), json) }
                        
                    } else if let result = json?["result"] as? Bool, !result {
                        
                        DispatchQueue.main.sync { completion((false, "File Upload Failed"), json) }
                        
                    } else {
                        var file: [String : String] = [:]
                        file["__type"] = "File"
                        file["name"] = json?["name"] as? String
                        file["url"] = json?["url"] as? String
                        let jsonObject: [String : [String : String]] = [key : file]
                        do {
                            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                            Parse.shared.put("/classes/\(classname)/\(objectId)", data: data, completion: completion)
                            
                        } catch let error {
                            DispatchQueue.main.sync { completion((false, error.localizedDescription), nil) }
                        }
                    }
                }
            } catch let error {
                DispatchQueue.main.sync { completion((false, error.localizedDescription), nil) }
            }
        }.resume()
    }
    
    func put(_ endpoint: String, data: Data, completion: @escaping PFCompletionBlock) {
        
        guard UIApplication.shared.isConnectedToNetwork else {
            return completion((false, "Network Connection Unavailable"), nil)
        }
        
        guard let serverURL = currentConfiguration?.serverUrl, let url = URL(string: serverURL + endpoint) else {
            return completion((false, "Invalid Server URL"), nil)
        }

        var request = PFRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = data
        logToConsole("PUT: \(data.count) bytes to " + url.absoluteString, kind: .info)
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            guard let data = data, error == nil else {
                self.logToConsole(error.debugDescription, kind: .error)
                DispatchQueue.main.sync { completion((false, error?.localizedDescription), nil) }
                return
            }
            self.logToConsole("RESPONSE: \(data.count) bytes", kind: .success)
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject]
                
                if let error = json?["error"] as? String {
                    
                    DispatchQueue.main.sync { completion((false, error), json) }
                    return
                    
                } else {
                    if let code = json?["code"] as? Int, code == 1 {
                        
                        DispatchQueue.main.sync { completion((false, json?["message"] as? String), json) }
                        
                    } else if let result = json?["result"] as? Bool, !result {
                        
                        DispatchQueue.main.sync { completion((false, "Failed to send push"), json) }
                        
                    } else {
                        
                        DispatchQueue.main.sync { completion((true, nil), json) }

                    }
                }
            } catch let error {
                DispatchQueue.main.sync { completion((false, error.localizedDescription), nil) }
            }
        }.resume()
    }
    
    func push(payload: Data, completion: @escaping PFCompletionBlock) {
        
        guard UIApplication.shared.isConnectedToNetwork else {
            return completion((false, "Network Connection Unavailable"), nil)
        }
        
        guard let serverURL = currentConfiguration?.serverUrl, let url = URL(string: serverURL + "/push") else {
            return completion((false, "Invalid Server URL"), nil)
        }
        
        var request = PFRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = payload
        logToConsole("POST: \(payload.count) to " + url.absoluteString, kind: .info)
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            guard let data = data, error == nil else {
                DispatchQueue.main.sync { completion((false, error?.localizedDescription), nil) }
                return
            }
            self.logToConsole("RESPONSE: \(data.count) bytes", kind: .success)
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject] else { return }
                if let error = json["error"] as? String {
                    
                    DispatchQueue.main.sync { completion((false, error), nil) }
                    
                } else {
                    if let code = json["code"] as? Int, code == 1 {
                        
                        DispatchQueue.main.sync { completion((false, json["message"] as? String), json) }
                        
                    } else {
                        
                        let result = json["result"] as? Bool ?? true
                        DispatchQueue.main.sync { completion((result, nil), json) }
                        
                    }
                }
            } catch _ {
                DispatchQueue.main.sync { completion((false, "Push failed. HTTPS may be required"), nil) }
            }
        }.resume()
    }
    
    // MARK: - Methods [Private]
    
    private func PFRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        let applicationId = currentConfiguration?.applicationId ?? ""
        let masterKey = currentConfiguration?.masterKey ?? ""
        request.setValue(applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.setValue(masterKey, forHTTPHeaderField: "X-Parse-Master-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func logToConsole(_ message: String, kind: ConsoleView.LogKind) {
        print(message)
        ConsoleView.shared.log(message: message, kind: kind)
    }
    
}



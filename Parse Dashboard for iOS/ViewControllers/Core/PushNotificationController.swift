//
//  PushNotificationController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 4/30/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit
import AlertHUDKit
import SwiftyJSON

final class PushNotificationController: UIAlertController {
    
    override var preferredStyle: UIAlertControllerStyle {
        return .alert
    }
    
    private let objectIds: [String]
    
    init(for objects: [ParseLiteObject]) {
        objectIds = objects.map { return $0.id }
        super.init(nibName: nil, bundle: nil)
        title = "Push Notification"
        message = "To: Devices Matching Current Search Query"
        initialize()
    }
    
    init(to user: ParseLiteObject) {
        objectIds = [user.id]
        super.init(nibName: nil, bundle: nil)
        title = "Push Notification"
        message = "To: " + (user.json["username"].stringValue)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initialize() {
        view.tintColor = .logoTint
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { [weak self] _ in
            guard let title = self?.textFields?.first?.text, let message = self?.textFields?.last?.text else { return }
            self?.sendNotification(title: title, message: message)
        })
        
        addAction(UIAlertAction(title: Localizable.cancel.localized, style: .destructive, handler: nil))
        addAction(sendAction)
        addTextField { $0.placeholder = "Title" }
        addTextField { $0.placeholder = "Message" }
    }
    
//    private func sendNotificationToUser(title: String?, message: String?) {
//
//        var user = JSON()
//        user["__type"].string = "Pointer"
//        user["className"].string = "_User"
//        user["objectId"].string = objectIds[0]
//
//        var data = JSON()
//        data["title"].string = title
//        data["alert"].string = message
//
//        var query = JSON()
//        query["user"] = user
//
//        var body = JSON()
//        body["where"] = query
//        body["data"] = data
//
//        do {
//            let data = try body.rawData()
//            ParseLite.shared.push(payload: data, completion: { [weak self] result, json in
//                guard result.success else {
//                    self?.handleError(result.error)
//                    return
//                }
//                Ping(text: "Push Notification Delivered", style: .success).show()
//            })
//        } catch let error {
//            self.handleError(error.localizedDescription)
//        }
//    }
    
    private func sendNotification(title: String, message: String) {
        
        // Example: where={"user":{"$inQuery":{"className":"_User","where":{"objectId":{"$in":["zaAqYBP8X9"]}}}}}
        let bodyStringLiteral = "{\"where\":{\"user\":{\"$inQuery\":{\"className\":\"_User\",\"where\":{\"objectId\":{\"$in\":\(objectIds)}}}}},\"data\":{\"title\":\"\(title)\",\"alert\":\"\(message)\"}}"
        
        let body = JSON(parseJSON: bodyStringLiteral)
        
        do {
            let data = try body.rawData()
            ParseLite.shared.push(payload: data, completion: { result, json in
                guard result.success else {
                    Ping(text: result.error ?? "Delivery Failed", style: .danger).show()
                    return
                }
                Ping(text: "Push Notification Delivered", style: .success).show()
            })
        } catch let error {
            Ping(text: error.localizedDescription, style: .danger).show()
        }
    }
    
}

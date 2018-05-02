//
//  ParseServerConfig+Extensions.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 4/30/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import IGListKit

extension ParseServerConfig: ListDiffable {
    
    public func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let config = object as? ParseServerConfig else { return false }
        return exportableURL == config.exportableURL && icon == config.icon
    }
    
}

extension ParseServerConfig {
    
    var exportableURL: URL? {
        guard let url = URL(string: serverUrl ?? "") else { return nil }
        let isSecure = url.absoluteString.contains("https")
        let port = isSecure ? "" : ":\(String(url.port ?? 80))"
        let urlString = "parsedashboard://\(applicationId ?? ""):\(masterKey ?? "")@" + (url.host ?? "") + port + url.path
        return URL(string: urlString)
    }
    
}

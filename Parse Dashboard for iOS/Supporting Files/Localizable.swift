//
//  Localizable.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 4/11/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import Foundation

enum Localizable: String {
    
    case search = "Search"
    
    case about = "About"
    
    case cancel = "Cancel"
    
    case share = "Share"
    
    case shareCaption = "ShareCaption"
    
    case moreOptions = "MoreOptions"
    
    case `continue` = "Continue"
    
    case getStarted = "GetStarted"
    
    case openSource = "OpenSource"
    
    case openSourceInfo = "OpenSourceInfo"
    
    case dataSecurity = "DataSecurity"
    
    case dataSecurityInfo = "DataSecurityInfo"
    
    case appDescription = "AppDescription"
    
    case success = "Success"
    
    case unknownError = "UnknownError"
    
    case support = "Support"
    
    case supportInfo = "SupportInfo"
    
    case makeDonation = "MakeDonation"
    
    case fanPrompt = "FanPrompt"
    
    case ratePrompt = "RatePrompt"
    
    case starRepoPrompt = "StarRepoPrompt"
    
    case settings = "Settings"
    
    case home = "Home"
    
    case add = "Add"
    
    case recent = "Recent"
    
    case iap_disabled = "IAPDisabled"
    
    case iap_restored = "IAPRestored"
    
    case iap_purchased = "IAPPurchased"
    
    case noNetwork = "NoNetwork"
    
    case invalidURL = "InvalidURL"
    
    case edit = "Edit"
    
    case duplicate = "Duplicate"
    
    case export = "Export"
    
    case delete = "Delete"
    
    case actions = "Actions"
    
    case servers = "Servers"
    
    case save = "Save"
    
    var localized: String {
        return NSLocalizedString(rawValue, comment: "")
    }
    
}

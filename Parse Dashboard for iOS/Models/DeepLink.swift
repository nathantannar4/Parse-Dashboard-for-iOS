//
//  DeepLink.swift
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
//  Created by Nathan Tannar on 12/15/17.
//

import UIKit

enum DeepLink {
    
    case add, recent, support, home
    
    var type: String {
        switch self {
        case .add:
            return "me.nathantannar.Parse-Dashboard.add"
        case .recent:
            return "me.nathantannar.Parse-Dashboard.recent"
        case .support:
            return "me.nathantannar.Parse-Dashboard.support"
        case .home:
            return "me.nathantannar.Parse-Dashboard.home"
        }
    }
    
    var icon: UIApplicationShortcutIcon {
        switch self {
        case .add:
            return UIApplicationShortcutIcon(type: .add)
        case .recent:
            return UIApplicationShortcutIcon(type: .time)
        case .support:
            return UIApplicationShortcutIcon(type: .love)
        case .home:
            return UIApplicationShortcutIcon(type: .home)
        }
    }
    
    var item: UIMutableApplicationShortcutItem {
        switch self {
        case .add:
            return UIMutableApplicationShortcutItem(type: type, localizedTitle: "Add", localizedSubtitle: "New Configuration", icon: icon, userInfo: nil)
        case .recent:
            guard let config = UserDefaults.standard.value(forKey: .recentConfig) as? [String:String] else {
                return DeepLink.home.item
            }
            return UIMutableApplicationShortcutItem(type: type, localizedTitle: "Recent", localizedSubtitle: config[.configName], icon: icon, userInfo: config)
        case .support:
            return UIMutableApplicationShortcutItem(type: type, localizedTitle: "Support", localizedSubtitle: "Donate/Review", icon: icon, userInfo: nil)
        case .home:
            return UIMutableApplicationShortcutItem(type: type, localizedTitle: "Home", localizedSubtitle: "Saved Configurations", icon: icon, userInfo: nil)
        }
    }
    
}


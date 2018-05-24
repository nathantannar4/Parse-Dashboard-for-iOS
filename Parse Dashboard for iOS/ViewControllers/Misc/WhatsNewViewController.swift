//
//  WhatsNewViewController+Extensions.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 4/30/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit
import WhatsNew

extension WhatsNewViewController {
    
    static var items: [WhatsNewItem] = [
        WhatsNewItem.image(title: "Refined UI/UX", subtitle: "A more responsive an intuitive experience", image: #imageLiteral(resourceName: "app_icon_shape")),
        WhatsNewItem.image(title: "Increased Performance", subtitle: "Faster rendering and searching. Searches now query each object's values", image: #imageLiteral(resourceName: "icon_performance")),
        WhatsNewItem.image(title: "Language Localization", subtitle: "Language support for based on your devices locale", image: #imageLiteral(resourceName: "Globe")),
        WhatsNewItem.image(title: "Donations", subtitle: "Show your support for this project", image: #imageLiteral(resourceName: "Money"))
    ]
    
    
    func applyStyling() {
        titleColor = .logoTint
        itemTitleColor = .primaryColor
        buttonTextColor = .white
        buttonBackgroundColor = .logoTint
    }
    
}

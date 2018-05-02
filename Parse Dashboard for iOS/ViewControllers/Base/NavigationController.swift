//
//  NavigationController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 4/30/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit

final class NavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let style = viewControllers.last?.preferredStatusBarStyle {
            return style
        }
        return (navigationBar.barTintColor?.isDark ?? false) ? .lightContent : .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = .white
        navigationBar.tintColor = .logoTint
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = UIImage()
        toolbar.setBackgroundImage(nil, forToolbarPosition: .bottom, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .bottom)
        toolbar.layer.shadowOpacity = 0.3
        toolbar.layer.shadowRadius = 5
        toolbar.layer.shadowColor = UIColor.darkGray.cgColor
    }
    
}

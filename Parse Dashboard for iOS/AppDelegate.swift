//
//  AppDelegate.swift
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
import AlertHUDKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    // MARK: - Properties
    
    var window: UIWindow?
    
    /// A visual effect view for security when biometric authentication is on
    var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 50
        blurView.contentView.addSubview(imageView)
        imageView.anchorCenterXToSuperview()
        imageView.anchorCenterYToSuperview(constant: -200)
        imageView.anchor(widthConstant: 100, heightConstant: 100)
        return blurView
    }()
    
    // MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Alert.Defaults.Color.Info = .logoTint
        Alert.Defaults.Color.Danger = .red
        Alert.Defaults.Color.Success = .logoTint
        Alert.Defaults.Font.Info = .boldSystemFont(ofSize: 14)
        Alert.Defaults.Font.Danger = .boldSystemFont(ofSize: 14)
        Alert.Defaults.Font.Success = .boldSystemFont(ofSize: 14)
        
        setupWindow()
        if let item = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            // If the user selected a shortcut item on launch switch the initial root UIViewController
            self.application(application, performActionFor: item, completionHandler: { _ in })
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Expected Format for config import
        // parsedashboard://<applicationId>:<masterKey>@<url>:<port>/<path>
        
        let config = ParseServerConfig(entity: ParseServerConfig.entity(), insertInto: persistentContainer.viewContext)
        config.name = (url.host ?? "") + url.path
        config.applicationId = url.user ?? String()
        config.masterKey = url.password ?? String()
        var serverUrl = "http://" + (url.host ?? String())
        if let port = url.port {
            serverUrl.append(":\(port)")
        }
        let mount = url.path
        serverUrl.append(mount)
        config.serverUrl = serverUrl
        saveContext()
        self.application(app, performActionFor: DeepLink.home.item, completionHandler: { _ in })
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if blurView.superview == nil {
            // Delay to account for launch screen annimation
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.window?.addSubview(self.blurView)
                self.blurView.fillSuperview()
            })
        }
        if !Auth.shared.granted {
            Auth.shared.unlock(completion: { result in
                self.blurView.isHidden = result
            })
        } else {
            self.blurView.isHidden = true
        }
    }
   
    func applicationWillResignActive(_ application: UIApplication) {
        if Auth.shared.isSetup {
            Auth.shared.lock()
            blurView.isHidden = false
        }
        UIApplication.shared.shortcutItems = [DeepLink.add.item, DeepLink.home.item, DeepLink.recent.item, DeepLink.support.item] // Update Shortcut Items
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    /// Called when a user selects a shortcut item after 3D touching an app icon
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        guard let root = window?.rootViewController as? UINavigationController else { return }
        if root != UIApplication.shared.presentedController {
            UIApplication.shared.presentedController?.dismiss(animated: false, completion: nil)
        }
        guard let base = root.viewControllers.first as? ServersViewController else { return }
        
        switch shortcutItem.type {
        case DeepLink.add.type:
            // Add a new server configuration
            root.popToRootViewController(animated: false)
            base.addServer()
        case DeepLink.recent.type:
            // Go to the schema view of the most recently viewed server
            guard let configHash = shortcutItem.userInfo as? [String:String] else { return }
            let config = ParseServerConfig(entity: ParseServerConfig.entity(), insertInto: nil)
            config.name = configHash[.configName]
            config.applicationId = configHash[.applicationId]
            config.masterKey = configHash[.masterKey]
            config.serverUrl = configHash[.serverUrl]
            root.popToRootViewController(animated: false)
            base.showSchemasForConfig(config)
        case DeepLink.support.type:
            // Show the support page
            root.popToRootViewController(animated: false)
            base.showMore(atIndex: 1) // Index 1 is the SupportViewController
        case DeepLink.home.type:
            // Go to main server config list page
            root.popToRootViewController(animated: false)
            base.viewDidAppear(false)
        default:
            break
        }
        
    }
    
    // MARK: - Window Setup
    
    /// Sets up the window to it's default properties
    private func setupWindow() {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        let launchScreen = UIStoryboard(name: "LaunchScreenCopy", bundle: nil).instantiateInitialViewController()!
        window?.rootViewController = launchScreen
        window?.makeKeyAndVisible() // Required when not using storyboards
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Parse_Dashboard_for_iOS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


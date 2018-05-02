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
import DynamicTabBarController
import CoreData
import Parse
import UserNotifications
import Fabric
import Crashlytics
import EggRating
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    // MARK: - Properties
    
    var window: UIWindow?
    
    /// A visual effect view for security when biometric authentication is on
    private var blurView: UIVisualEffectView = {
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
        
        // Configure Fabric
        Fabric.with([Crashlytics.self, Answers.self])
        
        // Configure AlertHUDKit
        Alert.Defaults.Color.Info = .logoTint
        Alert.Defaults.Color.Warning = .darkPurpleBackground
        Alert.Defaults.Color.Danger = .red
        Alert.Defaults.Color.Success = .logoTint
        Alert.Defaults.Font.Info = .boldSystemFont(ofSize: 14)
        Alert.Defaults.Font.Warning = .boldSystemFont(ofSize: 14)
        Alert.Defaults.Font.Danger = .boldSystemFont(ofSize: 14)
        Alert.Defaults.Font.Success = .boldSystemFont(ofSize: 14)
        
        // Configure SVProgressHUD
        SVProgressHUD.setBackgroundColor(.white)
        
        // Configure EggRating
        EggRating.itunesId = "1212141622"
        EggRating.minRatingToAppStore = 3.5
        EggRating.starFillColor = .logoTint
        EggRating.starBorderColor = .logoTint
        EggRating.delegate = self
        
        // Configure Parse
        setupParse()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { accepted, error in
            guard accepted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        setupWindow()
        if let item = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            // If the user selected a shortcut item on launch switch the initial root UIViewController
            navigateDeepLink(to: item)
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Expected Format for config import
        // parsedashboard://<applicationId>:<masterKey>@<url>:<port>/<path>
        
        if url.scheme == .parseDashboardURLScheme {
            importConfiguration(from: url)
        }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        addSecurityBlurEffect()
        toggleSecurityBlur(isLocked: true)
    }
   
    func applicationWillResignActive(_ application: UIApplication) {
        
        toggleSecurityBlur(isLocked: false)
        updateShortcutItems()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        saveContext()
    }
    
    /// Called when a user selects a shortcut item after 3D touching an app icon
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        navigateDeepLink(to: shortcutItem)
    }
    
    // MARK: - Push Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if (error as NSError).code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let data = userInfo["aps"] {
            print("Recieved Remote Notification: \(data)")
            let title = (data as AnyObject).value(forKey: "title") as? String
            let alert = (data as AnyObject).value(forKey: "alert") as? String
            var message: String?
            if let title = title, let alert = alert {
                message = title + ": " + alert
            } else {
                message = title ?? alert
            }
            guard let notificationMessage = message else { return }
            UIApplication.shared.applicationIconBadgeNumber += 1
            Ping(text: notificationMessage, style: .info).show(animated: true, duration: 5)
        }
    }
    
    // MARK: - Window Setup
    
    /// Sets up the window to it's default properties
    private func setupWindow() {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        let launchScreen = UIStoryboard(name: "LaunchScreenCopy", bundle: nil).instantiateInitialViewController() as! LaunchScreenViewController
        window?.rootViewController = launchScreen
//        window?.rootViewController = NavigationController(rootViewController: ServersViewController())
        window?.makeKeyAndVisible() // Required when not using storyboards
    }
    
    // MARK: - Deep Links
    
    /// Sends the application to the shortcut
    ///
    /// - Parameter shortcutItem: The Deep Link
    private func navigateDeepLink(to shortcutItem: UIApplicationShortcutItem) {
        
        let root = window?.rootViewController as? UINavigationController ?? ((window?.rootViewController as? DynamicTabBarController)?.viewControllers.first as? UINavigationController)
        guard let navigationController = root else { return }
        if root != UIApplication.shared.presentedController {
            UIApplication.shared.presentedController?.dismiss(animated: false, completion: nil)
        }
        guard let serverVC = navigationController.viewControllers.first as? ServersViewController else { return }
        
        switch shortcutItem.type {
        case DeepLink.add.type:
            // Add a new server configuration
            navigationController.popToRootViewController(animated: false)
            serverVC.addNewServer()
        case DeepLink.recent.type:
            // Go to the schema view of the most recently viewed server
            guard let configHash = shortcutItem.userInfo as? [String:String] else { return }
            let config = ParseServerConfig(entity: ParseServerConfig.entity(), insertInto: nil)
            config.name = configHash[.configName]
            config.applicationId = configHash[.applicationId]
            config.masterKey = configHash[.masterKey]
            config.serverUrl = configHash[.serverUrl]
            navigationController.popToRootViewController(animated: false)
            ParseLite.shared.initialize(with: config)
            let shemasViewController = SchemaViewController()
            serverVC.navigationController?.pushViewController(shemasViewController, animated: false)
        case DeepLink.support.type:
            // Show the support page
            navigationController.popToRootViewController(animated: false)
            serverVC.presentSupportViewController()
        case DeepLink.home.type:
            // Go to main server config list page
            serverVC.viewWillAppear(false)
            navigationController.popToRootViewController(animated: false)
        default:
            return
        }
    }
    
    /// Updates the 3D touch shotcut items
    private func updateShortcutItems() {
        
        if UserDefaults.standard.value(forKey: .recentConfig) == nil {
            UIApplication.shared.shortcutItems = [DeepLink.add.item, DeepLink.home.item, DeepLink.support.item]
        } else {
            UIApplication.shared.shortcutItems = [DeepLink.add.item, DeepLink.home.item, DeepLink.recent.item, DeepLink.support.item]
        }
    }
    
    // MARK: - Custom URL Scheme Interaction

    /// Imports a confirguation by parsing a URL
    ///
    /// - Parameter url: parsedashboard://<applicationId>:<masterKey>@<url>:<port>/<path>
    private func importConfiguration(from url: URL) {
        
        let config = ParseServerConfig(entity: ParseServerConfig.entity(),
                                       insertInto: persistentContainer.viewContext)
        
        config.name = (url.host ?? "") + url.path
        config.applicationId = url.user ?? String()
        config.masterKey = url.password ?? String()
        var serverUrl = "https://" + (url.host ?? String()) // Assume https to enforce security
        if let port = url.port {
            serverUrl.append(":\(port)")
        }
        let mount = url.path
        serverUrl.append(mount)
        config.serverUrl = serverUrl
        saveContext()
        
        // Send the user to the home screen
        navigateDeepLink(to: DeepLink.home.item)
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
    
    // MARK: - Auth Security Blur
    
    private func addSecurityBlurEffect() {
        
        if blurView.superview == nil {
            // Delay to account for launch screen annimation
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.window?.addSubview(self.blurView)
                self.blurView.fillSuperview()
            })
        }
    }
    
    private func toggleSecurityBlur(isLocked: Bool) {
        
        if isLocked {
            if !Auth.shared.granted {
                Auth.shared.unlock(completion: { result in
                    self.blurView.isHidden = result
                })
            } else {
                self.blurView.isHidden = true
            }
        } else {
            if Auth.shared.isSetup {
                Auth.shared.lock()
                blurView.isHidden = false
            }
        }
    }
    
    // MARK: - Parse
    
    func setupParse() {
        
        let config = ParseClientConfiguration {
            $0.applicationId = "yTJ0pnOP0yjl9WhFTijhXRv5BK55a9ewLC0CjsSS"
            $0.clientKey = "haEk6JilsROkkLfhyCDmG7aLMVmhnkxY13qOkE7y"
            $0.server = "https://parseapi.back4app.com/"
        }
        Parse.initialize(with: config)
        PFUser.enableAutomaticUser()
        
        // Get some analytics
        if let runCount = PFUser.current()?.value(forKey: "runCount") as? Int {
            PFUser.current()?.setValue(runCount + 1, forKey: "runCount")
        } else {
            PFUser.current()?.setValue(1, forKey: "runCount")
        }
        PFUser.current()?.setValue(Locale.current.languageCode, forKey: "locale")
        PFUser.current()?.saveInBackground()
    }
    
}

extension AppDelegate: EggRatingDelegate {
    
    func didIgnoreToRate() {
        Ping(text: "Please consider rating or donating to this project", style: .info).show()
    }
    
    func didRateOnAppStore() {
        Ping(text: "Thanks for submitting your feedback!", style: .info).show()
    }
    
    func didIgnoreToRateOnAppStore() {
        Ping(text: "Please consider rating or donating to this project", style: .info).show()
    }
    
    func didRate(rating rate: Double) {
        Ping(text: "Thanks for your feedback!", style: .info).show()
    }
    
}


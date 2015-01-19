//
//  AppDelegate.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/19/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var dataManager:KinveyDataManager! = nil

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Configure UI
        InterfaceConfiguration.configure();
        
        // Load Kinvey Config
        let kinveyConfig = loadKinveyConfig()
        let isValid = isKinveyConfigValid(kinveyConfig)
        
        if !isValid {
            //TODO: Let user know we cannot connect to Kinvey
            return true
        }
                
        // Setup the Kinvey Client Library
        let appKey = kinveyConfig.objectForKey(WaterCoolerConstants.Config.AppKey) as String
        let appSecret = kinveyConfig.objectForKey(WaterCoolerConstants.Config.AppSecret) as String
        KCSClient.sharedClient().initializeKinveyServiceForAppKey(appKey, withAppSecret: appSecret, usingOptions: nil);
        
        // Setup the Data Manager
        self.dataManager = KinveyDataManager()
        
        // If we have an active user, proceed to the main view and bypass the login / signup view
        if(KCSUser.activeUser() != nil) {
            let navController:UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainNavigationController") as UINavigationController;
            self.window?.rootViewController = navController;
        }
        
        // Register for Push
        KCSPush.registerForPush()
        
        return true
    }
    
    func loadKinveyConfig() -> NSDictionary! {
        if let path = NSBundle.mainBundle().pathForResource("Kinvey", ofType: "plist") {
            let kinveyDict = NSDictionary(contentsOfFile: path)
            return kinveyDict
        }
        return nil
    }
    
    func isKinveyConfigValid(config:NSDictionary!) -> Bool {
        // Verify that we were actually able to get something from the plist
        if(config == nil) {
            return false
        }
        
        let appKey = config.objectForKey(WaterCoolerConstants.Config.AppKey) as String?
        let appSecret = config.objectForKey(WaterCoolerConstants.Config.AppSecret) as String?
        
        // Verify that these values are not nil
        if (appKey == nil) || (appSecret == nil) {
            return false
        }
        
        // Verify that these aren't just empty strings
        if appKey!.isEmpty || appSecret!.isEmpty {
            return false
        }
        
        return true
    }
    
    func testKinveyConnection() {
        KCSPing.pingKinveyWithBlock { (result:KCSPingResult!) -> Void in
            if(result.pingWasSuccessful) {
                println("Connecting to Kinvey: Success");
            } else {
                println("Connecting to Kinvey: Failure");
            }
        };
    }
    
    func presentKinveyConfigurationAlert() {
        let alertController = UIAlertController(title: "Kinvey Config", message: "The application was not properly configured with the needed Kinvey appKey and appSecret.  You will need to create your own Kinvey app instance and load this information.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Read More", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            //TODO: Add the URL to launch
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        KCSPush.sharedPush().application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken) { (success, error) -> Void in
            // Registered
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        KCSPush.sharedPush().application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        KCSPush.sharedPush().application(application, didReceiveRemoteNotification: userInfo)
        dataManager.newMessageReceived(userInfo)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        KCSPush.sharedPush().registerForRemoteNotifications()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        KCSPush.sharedPush().onUnloadHelper()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

}


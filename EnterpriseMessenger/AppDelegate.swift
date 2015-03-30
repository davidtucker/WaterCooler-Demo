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
        
        // --------------------------------------------------------------------
        // INCLUDE YOUR KINVEY CREDENTIALS HERE
        // --------------------------------------------------------------------
        
        let appKey = ""
        let appSecret = ""
        
        //---------------------------------------------------------------------
        
        // Configure UI
        InterfaceConfiguration.configure();
        
        // Load the Kinvey Client
        if appKey.isEmpty || appSecret.isEmpty {
            setupKinveyClient()
        } else {
            setupKinveyClient(appKey, appSecret: appSecret)
        }
        
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
    
    func setupKinveyClient(appKey:String,appSecret:String) {
        KCSClient.sharedClient().initializeKinveyServiceForAppKey(appKey, withAppSecret: appSecret, usingOptions: nil)
    }
    
    func setupKinveyClient() {
        let kinveyConfig = loadKinveyConfig()
        let isValid = isKinveyConfigValid(kinveyConfig)
        
        assert(isValid, "Be sure you have defined your Kinvey configuration in the AppDelegate - both the appKey and appSecret")
        
        // Setup the Kinvey Client Library
        let appKey = kinveyConfig.objectForKey(WaterCoolerConstants.Config.AppKey) as String
        let appSecret = kinveyConfig.objectForKey(WaterCoolerConstants.Config.AppSecret) as String
        setupKinveyClient(appKey,appSecret: appSecret)
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

}


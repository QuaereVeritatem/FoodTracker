//
//  AppDelegate.swift
//  FoodTracker
//
//  Created by Robert Martin on 9/14/16.
//  Copyright © 2016 Robert Martin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //Backendless variablles
    let VERSION_NUM = "v1"
    
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // Replace these with YOUR App's ID and Secret Key from YOUR Backendless Dashboard!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    let APP_ID = "BB167472-BAE1-DCBC-FF4C-0E475BF35E00"
    let SECRET_KEY = "CA8325C6-6AF9-E6C5-FF4D-E6ED01505D00"
    



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //backendless test for keys entered vs default keys 
        if APP_ID != "<replace-with-your-app-id>" && SECRET_KEY != "<replace-with-your-secret-key>" {
            
            let backendless = Backendless.sharedInstance()
            backendless?.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
            backendless?.userService.setStayLoggedIn(true)
        }

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


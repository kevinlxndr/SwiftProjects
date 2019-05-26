//
//  AppDelegate.swift
//  DrillBook+
//
//  Created by Kevin Ramsussen on 11/11/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    let model = Model.sharedInstance

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: {granted, error in
            if !granted{
                print(error!)
            }
        })
        
        let nextAction = UNNotificationAction(identifier: "next", title: "Next", options: [])
        let prevAction = UNNotificationAction(identifier: "prev", title: "Previous", options: [])
        let category = UNNotificationCategory(identifier: "AdvanceDrill", actions: [nextAction, prevAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        center.removeAllDeliveredNotifications()
        if response.actionIdentifier == "next"{
            if model.currentDrillSet < model.numberOfDrillSets()-1{
                model.currentDrillSet += 1
                 NotificationCenter.default.post(name: NSNotification.Name("Trigger"), object: nil)
                }
        }
        else if response.actionIdentifier == "prev"{
            if model.currentDrillSet > 0{
                model.currentDrillSet -= 1
                 NotificationCenter.default.post(name: NSNotification.Name("Trigger"), object: nil)
            }
        }

        model.scheduleNotification(inSeconds: 1, completion: { success in
            if success {
                print("Successfully scheduled notification")
            } else {
                print("Error scheduling notification")
            }
        })
    completionHandler()
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

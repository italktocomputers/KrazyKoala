//
//  AppDelegate.swift
//  KrazyKoala
//
//  Created by Andrew Schools on 1/3/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

import UIKit
import GameKit
//import AVFoundation
//import SpriteKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var gameCenterEnabled = false
    var leaderboardIdentifier = ""
    var helpers = Helpers()
    var gameCenterController = GameCenterController()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if self.helpers.getGameCenterSetting() == true {
            if self.window != nil && self.window!.rootViewController != nil {
                //println("Game center authentication")
                self.gameCenterController.authenticateLocalPlayer(self.window!.rootViewController!, callback: ({}))
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        NSNotificationCenter.defaultCenter().postNotificationName("fromApplicationWillResignActive", object: nil)
        //AVAudioSession.sharedInstance().setActive(false, error: nil)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //AVAudioSession.sharedInstance().setActive(false, error: nil)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        NSNotificationCenter.defaultCenter().postNotificationName("fromApplicationWillEnterForeground", object: nil)
        //AVAudioSession.sharedInstance().setActive(true, error: nil)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSNotificationCenter.defaultCenter().postNotificationName("fromApplicationDidBecomeActive", object: nil)
        //AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        //let view = self.window!.rootViewController!.view as SKView;
        //view.paused = true;
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}
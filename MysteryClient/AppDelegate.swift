//
//  AppDelegate.swift
//  MysteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit
import LcLib
import UserNotifications

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        createWorkingPath()
        MYLang.setup(langListCodes: ["it"], langFileName: "Lang.txt")
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }
        var s = ""
        if kerr == KERN_SUCCESS {
            s = "Memory in use (in MB): \(info.resident_size/1000000). Free \(ProcessInfo.processInfo.physicalMemory/1000000)"
        }
        else {
            s = "Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error")
        }
        print(s)
        
        var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
        topWindow?.rootViewController = UIViewController()
        topWindow?.windowLevel = UIWindowLevelAlert + 1
        let alert = UIAlertController(title: "Memory Warning", message: s, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", tableName: "confirm", comment: ""), style: .cancel, handler: {(action: UIAlertAction) -> Void in
            topWindow?.isHidden = true // if you want to hide the topwindow then use this
            topWindow = nil // if you want to remove the topwindow then use this
        }))
        topWindow?.makeKeyAndVisible()
        topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func createWorkingPath () {
        let fm = FileManager.default  
        for path in [Config.Path.zip] {
            if fm.fileExists(atPath: path) {
                continue
            }
            do {
                try fm.createDirectory(atPath: path,
                                       withIntermediateDirectories: true,
                                       attributes: nil)
            } catch let error as NSError {
                print("Directory (result) error: \(error.debugDescription)")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse, withCompletionHandler
        completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        return completionHandler()
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent
        notification: UNNotification, withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        return completionHandler(UNNotificationPresentationOptions.alert)
    }
}



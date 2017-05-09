//
//  AppDelegate.swift
//  LayerChatClient
//
//  Created by Jitendra Solanki on 5/5/17.
//  Copyright © 2017 jitendra. All rights reserved.
//

import UIKit
import LayerKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    //MARK:- Remote Notification
    func registerForPushNotification(){
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Format the received token and save it.
        // let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        if let _ = User.sharedUser.layerClient.authenticatedUser {
            do{
                try User.sharedUser.layerClient.updateRemoteNotificationDeviceToken(deviceToken)
            }catch{
                print("error in udating device token to layer")
                print(error.localizedDescription)
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
        
    }
    
    /// Handle push notification from background.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if  let userInformation = response.notification.request.content.userInfo as? [String: Any]{
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            if User.sharedUser.isUserLoggedIn(){
                let isCalled =   User.sharedUser.layerClient.synchronize(withRemoteNotification: userInformation, completion: { (conversation, message, error) in
                    
                    if error != nil{
                        print(error!.localizedDescription)
                        return
                    }
                    
                    if conversation != nil{
                        //start conversation here
                        self.presentChatViewController(conversation: conversation!)
                    }
                })
            }
        }
        
        
    }
    
    /// Handle push notification from foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if let notificationInfo = notification.request.content.userInfo as? [String: Any]{
            print("\(notificationInfo)")
            //to synchronize layer with notification
            User.sharedUser.layerClient.synchronize(withRemoteNotification: notificationInfo) { (layerConversation, lyrMessage, error) in
                
            }
            
            if User.sharedUser.isUserLoggedIn() {
                if let aps = notificationInfo["aps"] as? [String:Any], let alertMessage = aps["alert"]as? String{
                    
                    let sharedMessageView = JStausBarMessageView.sharedMessageView
                    sharedMessageView.messageLabelTextColor = UIColor.white
                    sharedMessageView.messageBackgroundColor = eDuruColor.kBlue.colorFor()
                    sharedMessageView.messageBackgroundColor.withAlphaComponent(0.8)
                    
                    sharedMessageView.statusBarMessageViewWith(message: alertMessage, autoHide: true, onTouch: {
                        sharedMessageView.hideStatusBarMessageView()
                    })
                    
                    
                }
            }
        }
        
    }
    
    
    //MARK:- Helper Method
    func presentChatViewController(conversation:LYRConversation){
        if let topVC =  AppDelegate.topViewController(){
            
            let chatVC = ATChatViewController(layerClient: User.sharedUser.layerClient)
            chatVC.conversation = conversation
            chatVC.isPresented = true
            let navigationVC = UINavigationController(rootViewController: chatVC)
            topVC.present(navigationVC, animated: true, completion: {
                
            })
        }
    }
    
    //get conversation from notification info
    func getConversationFrom(userInfo:[String:Any])->LYRConversation?{
        if let layer = userInfo["layer"]as? [String:Any],let conversationIdentifer = layer["conversation_identifier"]as? String{
            
            if User.sharedUser.layerClient.isConnected{
                //check if conversation already exists with this participant
                let layerQuery:LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
                layerQuery.predicate = LYRPredicate(property: "identifier", predicateOperator: .isEqualTo, value:conversationIdentifer)
                let arrConver = try? User.sharedUser.layerClient.execute(layerQuery)
                if let conversation = arrConver?.firstObject as? LYRConversation{
                    return conversation
                }else{
                    return nil
                }
            }
            
        }
        
        return nil
    }
    
    func getMessageFrom(userInfo:[String:Any])->LYRMessage?{
        if let layer = userInfo["layer"]as? [String:Any],let conversationIdentifer = layer["message_identifier"]as? String{
            
            if User.sharedUser.layerClient.isConnected{
                //check if conversation already exists with this participant
                let layerQuery:LYRQuery = LYRQuery(queryableClass: LYRMessage.self)
                layerQuery.predicate = LYRPredicate(property: "identifier", predicateOperator: .isEqualTo, value:conversationIdentifer)
                let arrMessage = try? User.sharedUser.layerClient.execute(layerQuery)
                if let message = arrMessage?.firstObject as? LYRMessage{
                    return message
                }else{
                    return nil
                }
                
            }
            
        }
        
        return nil
    }
    func layerMessageFromConversation(conversation:LYRConversation)->LYRMessage?{
        if User.sharedUser.layerClient.isConnected{
            //check if conversation already exists with this participant
            let layerQuery:LYRQuery = LYRQuery(queryableClass: LYRMessage.self)
            layerQuery.predicate = LYRPredicate(property: "conversation", predicateOperator: .isEqualTo, value:conversation)
            layerQuery.sortDescriptors = [NSSortDescriptor.init(key: "position", ascending: true)]
            
            let arrMessage = try? User.sharedUser.layerClient.execute(layerQuery)
            if let message = arrMessage?.firstObject as? LYRMessage{
                return message
            }else{
                return nil
            }
            
        }
        return nil
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let sideMenuController = controller as? MFSideMenuContainerViewController{
            return topViewController(controller: sideMenuController.centerViewController as! UIViewController?)
        }
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
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


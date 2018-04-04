//
//  AppDelegate.swift
//  EpitechEisenhower
//
//  Created by fauquette fred on 25/09/17.
//  Copyright © 2017 Epitech. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import FirebaseStorage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    var picURL: URL! = nil

    // Google+ LogIn
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        if (user.profile.hasImage){
            picURL = user.profile.imageURL(withDimension: 200)
        }
        Auth.auth().signIn(with: credential) { (user, error) in
            if let _ = error { return }
            if (self.picURL != nil){
                let imagesRef = Storage.storage().reference().child("images/\(user!.uid).jpg")
                self.uploadFile(imagesRef, self.picURL)
            }
        }
    }
    
    func uploadFile(_ fileRef: StorageReference, _ url: URL){
        let data = NSData(contentsOf: url)
        fileRef.getMetadata { (metadata, error) in
            guard let storageError: NSError = error as NSError? else { return }
            guard let errorCode = StorageErrorCode(rawValue: storageError.code) else { return }
            if (errorCode == .objectNotFound){
                print("File doesn't exist")
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                _ = fileRef.putData(data! as Data, metadata: metadata)
            }
            else{
                print("File exists")
            }
        }
    }
    
    // Google+ LogOut
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        // Override point for customization after application launch.
//        do{
//            try Auth.auth().signOut()
//        } catch let signoutError as NSError {
//            print ("Error signing out: %@", signoutError)
//        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let fbHandler = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        let googleHandler = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        return fbHandler || googleHandler
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


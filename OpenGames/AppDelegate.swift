//
//  AppDelegate.swift
//  OpenGames
//
//  Created by yjlee12 on 2021/12/29.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var sudoku: sudokuClass = sudokuClass()
    var load: sudokuData?

    // ---------[ getPuzzles ]---------------------
    func getPuzzles(_ name : String) -> [String] {
        guard let url = Bundle.main.url(forResource: name, withExtension: "plist") else { return [] }
        guard let data = try? Data(contentsOf: url) else { return [] }
        guard let array = try? PropertyListDecoder().decode([String].self, from: data) else { return [] }
        return array
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


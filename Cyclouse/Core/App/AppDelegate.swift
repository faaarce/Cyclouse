//
//  AppDelegate.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit
import SwiftData
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    configureAppearance()
    setupIQKeyboard()
    return true
  }
  
  func configureAppearance() {
    UINavigationBar.appearance().barTintColor = ThemeColor.background
    UITabBar.appearance().barTintColor = ThemeColor.background
  
  }
  
  
  private func setupIQKeyboard() {
    IQKeyboardManager.shared.isEnabled = true
      IQKeyboardManager.shared.resignOnTouchOutside = true
      IQKeyboardManager.shared.enableAutoToolbar = true
      
      // Customize the keyboard appearance to match your theme
    IQKeyboardManager.shared.toolbarConfiguration.tintColor = ThemeColor.primary
    IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.color = UIColor(hex: "9E9E9E")
    IQKeyboardManager.shared.toolbarConfiguration.barTintColor = ThemeColor.cardFillColor
      
      // Set default keyboard distance
    IQKeyboardManager.shared.keyboardDistance = 10
      
      // Enable smart handling of next/previous buttons
      IQKeyboardManager.shared.enableAutoToolbar = true
    IQKeyboardManager.shared.toolbarConfiguration.manageBehavior = .byPosition
      
      // Customize toolbar buttons
    IQKeyboardManager.shared.toolbarConfiguration.previousNextDisplayMode = .default
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


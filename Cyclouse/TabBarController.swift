//
//  TabBarController.swift
//  Cyclouse
//
//  Created by yoga arie on 14/11/24.
//

import Foundation
import UIKit

class TabBarController: WaveTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeAppearance()
    }
    
    
  private func customizeAppearance() {
      // Set up transparent background for wave effect
      let appearance = UITabBarAppearance()
      appearance.configureWithTransparentBackground()
      
      // Configure tab bar item appearance
      let tabBarItemAppearance = UITabBarItemAppearance()
      
      // Selected state - hide text when selected (since we show icon in circle)
      tabBarItemAppearance.selected.titleTextAttributes = [
          .foregroundColor: ThemeColor.primary
      ]
      tabBarItemAppearance.selected.iconColor = .clear
      
      // Normal state - show text in secondary color
      tabBarItemAppearance.normal.titleTextAttributes = [
          .foregroundColor: ThemeColor.secondary
      ]
      tabBarItemAppearance.normal.iconColor = .clear
      
      appearance.stackedLayoutAppearance = tabBarItemAppearance
      appearance.inlineLayoutAppearance = tabBarItemAppearance
      appearance.compactInlineLayoutAppearance = tabBarItemAppearance
      
      tabBar.standardAppearance = appearance
      tabBar.scrollEdgeAppearance = appearance
      
      // This controls the color of the icon in the floating circle
      tabBar.tintColor = ThemeColor.primary
  }
  
  override func setupTabBarColoring() {
      waveSubLayer.fillColor = ThemeColor.cardFillColor.cgColor
      circle?.backgroundColor = ThemeColor.cardFillColor
  }
  
  // Override to ensure icon color in circle is correct
  override func setupImageView(_ center: Float) {
      super.setupImageView(center)
      imageView?.tintColor = ThemeColor.primary
  }
  
  // Override to maintain icon color after updates
  override func updateImageView() {
      super.updateImageView()
      imageView?.tintColor = ThemeColor.primary
  }}

//
//  SplashViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 29/10/24.
//

import UIKit


//class SplashViewController: UIViewController {
//    private var splashView: RevealingSplashView!
//    weak var coordinator: AppCoordinator?
//    
//    init(coordinator: AppCoordinator) {
//        self.coordinator = coordinator
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupSplashScreen()
//    }
//    
//    private func setupSplashScreen() {
//        // Create splash view with your app icon
//        let iconImage = UIImage(named: "cepeda")! // Make sure this matches your icon name
//        let iconInitialSize = CGSize(width: 60, height: 60)
//        
//        splashView = RevealingSplashView(
//            iconImage: iconImage,
//            iconInitialSize: iconInitialSize,
//            backgroundColor: ThemeColor.background // Or your app's theme color
//        )
//        
//        // Customize appearance
//        splashView.animationType = .twitter
//        splashView.duration = 2.0
//        splashView.delay = 0.2
//        
//        // Add splash view
//        view.addSubview(splashView)
//        
//        // Start animation
//        splashView.startAnimation { [weak self] in
//            self?.splashAnimationCompleted()
//        }
//    }
//    
//    private func splashAnimationCompleted() {
//        coordinator?.splashCompleted()
//    }
//}

//
//  CyclouseTabBarPresenter.swift
//  WaveTab
//
//  Created by Matthew Pierce on 15/05/2019.
//

import Foundation

protocol CyclouseTabBarPresenter: class {
    
    var view: CyclouseTabBarProtocol { get }
    
    func viewDidLoad()
    
    func viewDidAppear(portrait portraitOrientation: Bool)
    
    func viewDidRotate(portrait portraitOrientation: Bool, at index: Int)
    
    func tabBarDidSelectItem(with tag: Int)
    
    func viewWillLayoutSubviews()
    
    func moveCircleComplete(down movingDown: Bool)
    
}

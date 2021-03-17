//
//  BottomSelectionTabBarBottomSelectionTabBarViewInput.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol BottomSelectionTabBarViewInput: class, Waiting {

    /**
        @author AlexanderP
        Setup initial state of the view
    */

    func setupInitialState()
    
    func setupBar(style: BottomActionsBarStyle, config: EditingBarConfig)
    func showBar(animated: Bool, onView sourceView: UIView)
    func hideBar(animated: Bool)
}

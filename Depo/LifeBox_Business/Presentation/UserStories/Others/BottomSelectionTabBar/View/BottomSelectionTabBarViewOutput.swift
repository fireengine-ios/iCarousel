//
//  BottomSelectionTabBarBottomSelectionTabBarViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol BottomSelectionTabBarViewOutput {

    /**
        @author AlexanderP
        Notify presenter that view is ready
    */

    func viewIsReady()
    
    func bottomBarSelected(actionType: ElementTypes)
    func showMenu(actionTypes: [ElementTypes], sender: UIButton)
}

//
//  BottomSelectionTabBarBottomSelectionTabBarModuleInput.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol BottomSelectionTabBarModuleInput: BaseItemOuputPassingProtocol {
    
    func setupTabBarWith(config: EditingBarConfig)
    
    func setupTabBarWith(items: [BaseDataSourceItem])//  Disable/Enable tabs
    
}

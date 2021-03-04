//
//  BottomSelectionTabBarBottomSelectionTabBarModuleInput.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol BottomSelectionTabBarModuleInput: BaseItemOuputPassingProtocol {

//    func showAlertSheet(withTypes types: [ElementTypes], presentedBy sender: Any?, onSourceView sourceView: UIView?)
//
//    func showAlertSheet(withItems items: [BaseDataSourceItem], presentedBy sender: Any?, onSourceView sourceView: UIView?)
//
//    func showSpecifiedAlertSheet(withItem item: BaseDataSourceItem, presentedBy sender: Any?, onSourceView sourceView: UIView?)
    
    func setupTabBarWith(config: EditingBarConfig)
    
    func setupTabBarWith(items: [BaseDataSourceItem])//  Disable/Enable tabs
    
}

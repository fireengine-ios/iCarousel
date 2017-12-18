//
//  BaseFilesGreedRouterInput.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol BaseFilesGreedRouterInput {
    
    func onItemSelected(item: BaseDataSourceItem, from data:[[BaseDataSourceItem]], type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, moduleOutput: BaseFilesGreedModuleOutput?)
    
    func showPrint(items: [BaseDataSourceItem])
    
    func showBack()
}


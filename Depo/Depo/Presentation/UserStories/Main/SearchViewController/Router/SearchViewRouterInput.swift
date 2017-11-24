//
//  SearchViewRouterInput.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol SearchViewRouterInput {
    
    func onItemSelected(item: BaseDataSourceItem, from data:[[BaseDataSourceItem]])
}

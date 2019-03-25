//
//  SelectNameSelectNameRouterInput.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SelectNameRouterInput {
    
    func hideScreen()
    
    func moveToFolderPage(item: Item, isSubFolder: Bool)
}

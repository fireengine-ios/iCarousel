//
//  BottomSelectionTabBarBottomSelectionTabBarInteractorOutput.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol BottomSelectionTabBarInteractorOutput: MoreFilesActionsInteractorOutput {
    func selectFolder(_ selectFolder: SelectFolderViewController)
    func objectsToShare(rect: CGRect?, urls: [String])
    func deleteMusic(_ completion: @escaping VoidHandler)
}

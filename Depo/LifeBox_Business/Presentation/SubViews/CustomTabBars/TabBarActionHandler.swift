//
//  TabBarActionHandler.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 12/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol TabBarActionHandler: class {
    func canHandleTabBarAction(_ action: TabBarViewController.Action) -> Bool
    func handleAction(_ action: TabBarViewController.Action)
}

protocol TabBarActionHandlerContainer: class {
    var tabBarActionHandler: TabBarActionHandler? { get }
}

extension TabBarViewController {
    enum Action {
        case createFolder, upload, uploadFromApp, uploadFromAppFavorites, uploadFiles, uploadDocuments, uploadMusic
    }
}

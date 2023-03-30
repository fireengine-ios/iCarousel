//
//  TabBarActionHandler.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 12/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol TabBarActionHandler: AnyObject {
    func canHandleTabBarAction(_ action: TabBarViewController.Action) -> Bool
    func handleAction(_ action: TabBarViewController.Action)
}

protocol TabBarActionHandlerContainer: AnyObject {
    var tabBarActionHandler: TabBarActionHandler? { get }
}

extension TabBarViewController {
    enum Action {
        case takePhoto, createFolder, createStory, upload, createAlbum, uploadFromApp, uploadFromAppFavorites, importFromSpotify, uploadFiles, uploadDocuments, uploadMusic, uploadDocumentsAndMusic, photopick, createCollage, createWord, createExcel, createPowerPoint
    }
}

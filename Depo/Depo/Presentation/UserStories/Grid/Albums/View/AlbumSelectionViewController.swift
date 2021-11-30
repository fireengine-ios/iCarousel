//
//  AlbumSelectionViewController.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AlbumSelectionViewController: BaseFilesGreedChildrenViewController {

    ///need override this method for correct configuration UINavigationBar
    override func configureNavBarActions(isSelecting: Bool = false) {
        let more = NavBarWithAction(navItem: NavigationBarList().newAlbum) { item in
            self.output.onStartCreatingPhotoAndVideos()
        }
        let rightActions: [NavBarWithAction] = [more]
        navBarConfigurator.configure(right: rightActions, left: [])
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }
}

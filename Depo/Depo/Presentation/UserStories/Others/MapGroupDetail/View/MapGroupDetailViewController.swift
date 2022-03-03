//
//  MapGroupDetailViewController.swift
//  Depo
//
//  Created by Hady on 3/1/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class MapGroupDetailViewController: BaseFilesGreedChildrenViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // don't show subtitle
        setTitle(withString: mainTitle)
    }

    override func stopSelection() {
        super.stopSelection()
        // don't show subtitle
        setTitle(withString: mainTitle)
    }

    override func configureNavBarActions(isSelecting: Bool = false) {
        // don't add bar button items
    }

    override func hideNoFiles() {
        // hide the top bar containing sort button
        topBarContainer.isHidden = true
    }
}

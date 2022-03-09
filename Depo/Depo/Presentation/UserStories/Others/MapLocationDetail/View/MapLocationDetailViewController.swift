//
//  MapLocationDetailViewController.swift
//  Depo
//
//  Created by Hady on 3/1/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class MapLocationDetailViewController: BaseFilesGreedChildrenViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // don't show subtitle
        setTitle(withString: mainTitle)
    }

    override func stopSelection() {
        super.stopSelection()
        // don't show subtitle
        setTitle(withString: mainTitle)

        // mark the data in the previous page as outdated upon actions like (delete, hide)
        setMapDataNeedsRefresh()
    }

    override func configureNavBarActions(isSelecting: Bool = false) {
        // don't add bar button items
    }

    override func hideNoFiles() {
        // hide the top bar containing sort button
        topBarContainer.isHidden = true
    }

    private func setMapDataNeedsRefresh() {
        guard let mapSearchViewController = getPreviousViewController() as? MapSearchViewInput else {
            return
        }

        mapSearchViewController.setMapDataNeedsRefresh()
    }

    private func getPreviousViewController() -> UIViewController? {
        if let navigationStack = navigationController?.viewControllers, navigationStack.count > 1 {
            return navigationStack[navigationStack.count - 2]
        }

        return nil
    }
}

//
//  BottomSelectionTabBarDrawerViewController.swift
//  Depo
//
//  Created by Hady on 6/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class BottomSelectionTabBarDrawerViewController: UIViewController, BottomSelectionTabBarViewInput, NibInit {

    @IBOutlet private weak var editingBar: EditinglBar!

    var output: BottomSelectionTabBarViewOutput!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        output.viewIsReady()
    }

    private func setupDelegate() {
        editingBar.delegate = self
    }

    // MARK: BottomSelectionTabBarViewInput
    func setupInitialState() {

    }

    func setupBar(with config: EditingBarConfig) {
        editingBar.tintColor = config.tintColor
        editingBar.unselectedItemTintColor = config.unselectedItemTintColor
        editingBar.barStyle = config.style
        editingBar.barTintColor = config.barTintColor
        editingBar.shadowImage = UIImage()
        editingBar.backgroundImage = UIImage()

        let bottomItems = config.elementsConfig.map { item in
            (item.icon, item.editingBarTitle, item.editingBarAccessibilityId)
        }

        editingBar.setupItems(
            withImageToTitleNames: bottomItems,
            syncInProgress: config.elementsConfig.contains(.syncInProgress)
        )
    }

    private weak var currentDrawer: DrawerViewController?

    func showBar(animated: Bool, onView sourceView: UIView) {
        guard currentDrawer == nil || currentDrawer?.presentingViewController == nil else {
            return
        }

        presentAsDrawer { drawer in
            drawer.drawerPresentationController?.allowsDismissalWithPanGesture = false
            drawer.drawerPresentationController?.allowsDismissalWithTapGesture = false
            drawer.drawerPresentationController?.passesTouchesToPresentingView = true
            drawer.drawerPresentationController?.dimmedViewStyle = .none
            self.currentDrawer = drawer
        }
    }

    func hideBar(animated: Bool) {
        currentDrawer?.dismiss(animated: true)
    }

    func unselectAll() {
        editingBar.selectedItem = nil
    }

    private func changeStatusForTabs(atIntdex indexes: [Int], enabled: Bool) {
        indexes.forEach {
            guard let item = editingBar.items?[$0] else {
                return
            }

            item.isEnabled = enabled
        }
    }

    func disableItems(at indexes: [Int]) {
        changeStatusForTabs(atIntdex: indexes, enabled: false)
    }

    func enableItems(at indexes: [Int]) {
        changeStatusForTabs(atIntdex: indexes, enabled: true)
    }
}


extension BottomSelectionTabBarDrawerViewController: UITabBarDelegate {

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let selectedItemIndex = tabBar.items?.firstIndex(of: item) else {
            return
        }

        output.bottomBarSelectedItem(index: selectedItemIndex, sender: item)

        DispatchQueue.main.asyncAfter(deadline: .now() + NumericConstants.animationDuration) {[weak self] in
            self?.unselectAll()
        }
    }

}

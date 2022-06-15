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

    func setupBar(tintColor: UIColor?, style: UIBarStyle?, items: [ImageNameToTitleTupple]) {
        if let tintColor = tintColor {
            editingBar.tintColor = tintColor
        } else {
            editingBar.tintColor = ColorConstants.blueColor
        }
        if let style = style, style != .default {
            editingBar.backgroundImage = UIImage()
        }

        editingBar.setupItems(withImageToTitleNames: items)
    }

    private weak var currentDrawer: DrawerViewController?

    func showBar(animated: Bool, onView sourceView: UIView) {
        guard currentDrawer == nil || currentDrawer?.presentingViewController == nil else {
            return
        }

        let drawer = DrawerViewController(content: self)
        drawer.drawerPresentationController?.allowsDismissalWithPanGesture = false
        drawer.drawerPresentationController?.allowsDismissalWithTapGesture = false
        drawer.drawerPresentationController?.passesTouchesToPresentingView = true
        drawer.drawerPresentationController?.dimmedViewStyle = .none
        RouterVC().presentViewController(controller: drawer)
        self.currentDrawer = drawer
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

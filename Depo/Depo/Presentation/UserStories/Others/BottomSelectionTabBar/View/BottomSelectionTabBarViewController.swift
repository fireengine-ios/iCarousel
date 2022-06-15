//
//  BottomSelectionTabBarBottomSelectionTabBarViewController.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit


class BottomSelectionTabBarViewController: UIViewController, BottomSelectionTabBarViewInput, NibInit {

    @IBOutlet var editingBar: EditinglBar!
    var output: BottomSelectionTabBarViewOutput!
    
    var sourceView: UIView?
    
    
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

        let bottomItems = config.elementsConfig.map { item in
            (item.icon, item.editingBarTitle, item.editingBarAccessibilityId)
        }

        editingBar.setupItems(
            withImageToTitleNames: bottomItems,
            syncInProgress: config.elementsConfig.contains(.syncInProgress)
        )
    }
    
    func showBar(animated: Bool, onView sourceView: UIView) {
        self.sourceView = sourceView

        editingBar.show(animated: animated, onView: sourceView)
    }
    
    func hideBar(animated: Bool) {
        editingBar?.dismiss(animated: animated)
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


extension BottomSelectionTabBarViewController: UITabBarDelegate {
    
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

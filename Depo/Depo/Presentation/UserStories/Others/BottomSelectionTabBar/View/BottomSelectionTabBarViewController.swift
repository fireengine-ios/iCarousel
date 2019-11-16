//
//  BottomSelectionTabBarBottomSelectionTabBarViewController.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class BottomSelectionTabBarViewController: UIViewController, BottomSelectionTabBarViewInput, UITabBarDelegate {

    @IBOutlet var editingBar: EditinglBar!
    var output: BottomSelectionTabBarViewOutput!

    static let xibName = "BottomSelectionTabBarViewController"
    
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
    
    class func initFromXib() -> BottomSelectionTabBarViewController {
        return BottomSelectionTabBarViewController(nibName: BottomSelectionTabBarViewController.xibName, bundle: nil)
    }
    
    // MARK: BottomSelectionTabBarViewInput
    func setupInitialState() {
        
    }
    
    func setupBar(tintColor: UIColor?, style: UIBarStyle?, items: [ImageNameToTitleTupple]) {
        if let tintColor = tintColor {
            editingBar.tintColor = tintColor
        } else {
            editingBar.tintColor = ColorConstants.selectedBottomBarButtonColor
        }
        if let style = style, style != .default {
            editingBar.backgroundImage = UIImage()
        }
        editingBar.setupItems(withImageToTitleNames: items)
    }
    
    func showBar(animated: Bool, onView sourceView: UIView) {
        self.sourceView = sourceView
        
        editingBar.show(animated: animated, onView: sourceView)
    }
    
    func hideBar(animated: Bool) {
        editingBar?.dismiss(animated: animated)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let selectedItemIndex = tabBar.items?.index(of: item) else {
            return
        }
        output.bottomBarSelectedItem(index: selectedItemIndex, sender: item)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + NumericConstants.animationDuration) {[weak self] in
            self?.unselectAll()
        }
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

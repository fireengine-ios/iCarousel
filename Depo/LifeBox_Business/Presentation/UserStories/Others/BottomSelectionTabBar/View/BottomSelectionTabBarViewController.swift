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
    var config: EditingBarConfig?
    var sourceView: UIView?
    
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupDelegate()
        output.viewIsReady()
    }

    private func setupDelegate() {
        editingBar.delegate = self
    }
    
    
    // MARK: BottomSelectionTabBarViewInput
    func setupInitialState() {
        
    }
    
    func setupBar(tintColor: UIColor?, style: UIBarStyle?, items: [ImageNameToTitleTupple], config: EditingBarConfig) {
        self.config = config
        if let tintColor = tintColor {
            editingBar.tintColor = tintColor
        } else {
            editingBar.tintColor = ColorConstants.blueColor
        }

        if let style = style {
            editingBar.barStyle = style
            
            switch style {
                case .default:
                    editingBar.clipsToBounds = true
                    editingBar.isTranslucent = true
                    editingBar.backgroundImage = UIImage(color: .clear)
                    editingBar.shadowImage = UIImage(color: .clear)
                    editingBar.tintColor = .white
                default:
                    editingBar.backgroundImage = UIImage()
                    editingBar.tintColor = ColorConstants.bottomBarTint
            }
        } else {
            editingBar.backgroundImage = UIImage()
        }
        
        
        editingBar.setupItems(withImageToTitleNames: items, style: style)
    }
    
    func showBar(animated: Bool, onView sourceView: UIView) {
        self.sourceView = sourceView

        editingBar.show(animated: animated, onView: sourceView)
    }
    
    func hideBar(animated: Bool) {
            ?.dismiss(animated: animated)
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
        guard let selectedItemIndex = tabBar.items?.index(of: item) else {
            return
        }
        
        output.bottomBarSelectedItem(index: selectedItemIndex, sender: item, config: config)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + NumericConstants.animationDuration) {[weak self] in
            self?.unselectAll()
        }
    }
    
}

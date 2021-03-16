//
//  BottomSelectionTabBarBottomSelectionTabBarViewController.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit


class BottomSelectionTabBarViewController: UIViewController, BottomSelectionTabBarViewInput, NibInit {

    @IBOutlet var bottomActionsBar: BottomActionsBar! {
        willSet {
            newValue.delegate = self
        }
    }
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
        //TODO: bottom bar
//        editingBar.delegate = self
    }
    
    
    // MARK: BottomSelectionTabBarViewInput
    func setupInitialState() {
        
    }
    
    func setupBar(tintColor: UIColor?, style: BottomActionsBarStyle = .opaque, items: [ImageNameToTitleTupple], config: EditingBarConfig) {
        self.config = config
       
        bottomActionsBar.setup(style: style, elementTypes: [.delete, .download])
    }
    
    func showBar(animated: Bool, onView sourceView: UIView) {
        self.sourceView = sourceView
        bottomActionsBar.show(onSourceView: sourceView, animated: animated)
    }
    
    func hideBar(animated: Bool) {
        bottomActionsBar.hide(animated: animated)
    }
    
    func unselectAll() {
//        editingBar.selectedItem = nil
    }
    
    private func changeStatusForTabs(atIntdex indexes: [Int], enabled: Bool) {
        //TODO: bottom bar
//        indexes.forEach {
//            guard let item = editingBar.items?[$0] else {
//                return
//            }
//
//            item.isEnabled = enabled
//        }
    }
    
    func disableItems(at indexes: [Int]) {
        changeStatusForTabs(atIntdex: indexes, enabled: false)
    }
    
    func enableItems(at indexes: [Int]) {
        changeStatusForTabs(atIntdex: indexes, enabled: true)
    }
}


extension BottomSelectionTabBarViewController: BottomActionsBarDelegate {
    
    func onSelected(action: BottomBarActionType) {
//        guard let selectedItemIndex = tabBar.items?.index(of: item) else {
//            return
//        }
//
//        output.bottomBarSelectedItem(index: selectedItemIndex, sender: item, config: config)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + NumericConstants.animationDuration) { [weak self] in
            self?.unselectAll()
        }
    }
}

//
//  BottomSelectionTabBarBottomSelectionTabBarViewController.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit


class BottomSelectionTabBarViewController: UIViewController, BottomSelectionTabBarViewInput, NibInit {

    @IBOutlet var bottomActionsBar: BottomActionsBar! 
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bottomActionsBar.updateLayout(animated: false)
    }

    private func setupDelegate() {
        bottomActionsBar.delegate = self
    }
    
    
    // MARK: BottomSelectionTabBarViewInput
    func setupInitialState() {
        
    }
    
    func changeBar(style: BottomActionsBarStyle) {
        bottomActionsBar.set(style: style)
    }
    
    func setupBar(style: BottomActionsBarStyle = .opaque, config: EditingBarConfig) {
        self.config = config
       
        bottomActionsBar.setup(style: style, elementTypes: config.elementsConfig)
    }
    
    func showBar(animated: Bool, onView sourceView: UIView) {
        self.sourceView = sourceView
        bottomActionsBar.show(onSourceView: sourceView, animated: animated)
    }
    
    func hideBar(animated: Bool) {
        bottomActionsBar.hide(animated: animated)
    }
}


extension BottomSelectionTabBarViewController: BottomActionsBarDelegate {
    
    func onSelected(action: BottomBarActionType) {
        output.bottomBarSelected(actionType: action.toElementType)
    }
    
    func onMoreButton(actions: [BottomBarActionType], sender: UIButton) {
        output.showMenu(actionTypes: actions.compactMap { $0.toElementType }, sender: sender)
    }
}

//
//  AnalyzeHistoryTabBarPresenter.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 1/15/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol AnalyzeHistoryTabBarPresenterDelegate: AnyObject {
    func bottomBarSelectedItem(_ item: ElementTypes)
}

final class AnalyzeHistoryTabBarPresenter: BottomSelectionTabBarPresenter {
    
    private weak var delegate: AnalyzeHistoryTabBarPresenterDelegate?
    
    private var types = [ElementTypes]()
    
    func setup(with types: [ElementTypes], delegate: AnalyzeHistoryTabBarPresenterDelegate?) {
        self.types = types
        self.delegate = delegate
    }
    
    override func bottomBarSelectedItem(index: Int, sender: UITabBarItem) {
        delegate?.bottomBarSelectedItem(types[index])
    }
}

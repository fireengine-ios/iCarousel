//
//  SegmentedChildNavBarManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol SegmentedChildNavBarManagerDelegate: SegmentedChildController {
    func onCancelSelectionButton()
    func onThreeDotsButton()
    func onSearchButton()
    func onPlusButton()
}

final class SegmentedChildNavBarManager {
    
    private lazy var cancelSelectionButton = UIBarButtonItem(
        title: TextConstants.cancelSelectionButtonTitle,
        font: .TurkcellSaturaDemFont(size: 19.0),
        target: self,
        selector: #selector(onCancelSelectionButton))
    
    /// public bcz can be disabled
    lazy var threeDotsButton = UIBarButtonItem(
        image: Images.threeDots,
        style: .plain,
        target: self,
        action: #selector(onThreeDotsButton))
    
    private lazy var searchButton = UIBarButtonItem(
        image: UIImage(),
        style: .plain,
        target: self,
        action: #selector(onSearchButton))
    
    private lazy var plusButton = UIBarButtonItem(
        image: UIImage(),
        style: .plain,
        target: self,
        action: #selector(onPlusButton))
    
    private weak var delegate: SegmentedChildNavBarManagerDelegate?
    
    init(delegate: SegmentedChildNavBarManagerDelegate?) {
        plusButton.setBackgroundImage(NavigationBarImage.headerActionPlus.image, for: .normal, barMetrics: .default)
        searchButton.setBackgroundImage(NavigationBarImage.headerActionSearch.image, for: .normal, barMetrics: .default)
        self.delegate = delegate
    }
    
    func setSelectionMode() {
        delegate?.setLeftBarButtonItems([cancelSelectionButton], animated: true)
        delegate?.setRightBarButtonItems([], animated: false)
    }
    
    func setDefaultMode(title: String = "", isThreeDotsEnabled: Bool = true) {
        delegate?.setTitle(title)
        delegate?.setRightBarButtonItems([plusButton, searchButton], animated: false)
        delegate?.setLeftBarButtonItems(nil, animated: true)
        
    }
    
    func setDefaultModeWithoutPlusButton(title: String = "") {
        delegate?.setTitle(title)
        delegate?.setRightBarButtonItems([searchButton], animated: false)
        delegate?.setLeftBarButtonItems(nil, animated: true)
    }
    
    @objc private func onCancelSelectionButton() {
        delegate?.onCancelSelectionButton()
    }
    
    @objc private func onThreeDotsButton() {
        delegate?.onThreeDotsButton()
    }
    
    @objc private func onSearchButton() {
        delegate?.onSearchButton()
    }
    
    @objc private func onPlusButton() {
        delegate?.onPlusButton()
    }
}

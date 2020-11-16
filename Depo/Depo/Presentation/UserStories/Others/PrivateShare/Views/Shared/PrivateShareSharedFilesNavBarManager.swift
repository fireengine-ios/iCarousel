//
//  PrivateShareSharedFilesNavBarManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 16.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareSharedFilesNavBarManagerDelegate: SegmentedChildController {
    func onCancelSelectionButton()
    func onThreeDotsButton()
    func onSearchButton()
}

final class PrivateShareSharedFilesNavBarManager {
    
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
        image: Images.search,
        style: .plain,
        target: self,
        action: #selector(onSearchButton))
    
    private weak var delegate: PrivateShareSharedFilesNavBarManagerDelegate?
    
    init(delegate: PrivateShareSharedFilesNavBarManagerDelegate?) {
        self.delegate = delegate
    }
    
    func setSelectionMode() {
        delegate?.setLeftBarButtonItems([cancelSelectionButton], animated: true)
        delegate?.setRightBarButtonItems([threeDotsButton], animated: false)
    }
    
    func setDefaultMode(title: String = "") {
        delegate?.setTitle(title)
        delegate?.setRightBarButtonItems([threeDotsButton, searchButton], animated: false)
        delegate?.setLeftBarButtonItems(nil, animated: true)
        threeDotsButton.isEnabled = true
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
}

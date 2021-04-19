//
//  SegmentedChildNavBarManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol SegmentedChildNavBarManagerDelegate: SegmentedChildTopBarSupportedControllerProtocol {
    func onCancelSelectionButton()
    func onPlusButton()
    func onSettingsButton()
    func onTrashBinButton()
    func onBackButton()
}

final class SegmentedChildNavBarManager {

    private lazy var cancelSelectionForTrashBinButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "closeButton"), style: .plain, target: self, action: #selector(onCancelSelectionButton))
        return barButtonItem
    }()
    
    private lazy var cancelSelectionButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(onCancelSelectionButton),
                         for: UIControlEvents.touchUpInside)
        button.setTitle(TextConstants.cancelSelectionButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 18)
        button.setTitleColor(ColorConstants.confirmationPopupTitle, for: .normal)
        
       return UIBarButtonItem(customView: button)
    }()
    
    private(set) lazy var plusButton: UIBarButtonItem = {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "plusFillButton"),
                            for: .normal)

            button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)

            button.addTarget(self, action: #selector(onPlusButton),
                             for: UIControlEvents.touchUpInside)
            return UIBarButtonItem(customView: button)
    }()

    private(set) lazy var trashButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "trash_bin_nav_bar"),
                        for: .normal)

        button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)

        button.addTarget(self, action: #selector(onTrashBinButton),
                         for: UIControlEvents.touchUpInside)
        return UIBarButtonItem(customView: button)
    }()

    private(set) lazy var customBackButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "blackBackButton"), style: .plain, target: self, action: #selector(onBackButton))
        return barButtonItem
    }()
    
    lazy var settingsButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        
        let initials: String
        
        if let firstLetter = SingletonStorage.shared.accountInfo?.name?.firstLetter,
           let secondLetter = SingletonStorage.shared.accountInfo?.surname?.firstLetter {
            initials = firstLetter + secondLetter
        } else {
            initials = String((SingletonStorage.shared.accountInfo?.email ?? "").prefix(2)).uppercased()
        }
        
        button.setTitle(initials, for: .normal)
        button.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 13.5)
        button.setTitleColor(ColorConstants.confirmationPopupTitle, for: .normal)
        
        button.backgroundColor = ColorConstants.topBarSettingsIconColor
        button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        button.layer.cornerRadius = button.frame.height * 0.5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(onSettingsButton),
                         for: UIControlEvents.touchUpInside)
        
        return UIBarButtonItem(customView: button)
    }()
    
    private weak var delegate: SegmentedChildNavBarManagerDelegate?
    
    init(delegate: SegmentedChildNavBarManagerDelegate?) {
        self.delegate = delegate
    }
    
    func setSelectionMode() {
        delegate?.setLeftBarButtonItems([cancelSelectionButton], animated: true)
        delegate?.setRightBarButtonItems([], animated: false)
    }

    func setSelectionModeForTrashBin() {
        delegate?.setLeftBarButtonItems([cancelSelectionForTrashBinButton], animated: true)
        delegate?.setRightBarButtonItems([], animated: false)
    }
    
    func setRootMode(title: String = "") {
        delegate?.setTitle(title, isSelectionMode: false, style: .white)
        delegate?.setRightBarButtonItems([plusButton], animated: false)
        delegate?.setLeftBarButtonItems([settingsButton], animated: false)
    }
    
    func setupLargeTitle(isLarge: Bool) {
        delegate?.changeNavbarLargeTitle(isLarge, style: .white)
    }
    
    func setNestedMode(title: String = "") {
        delegate?.setTitle(title, isSelectionMode: false, style: .white)
        delegate?.setRightBarButtonItems([plusButton], animated: false)
        delegate?.setLeftBarButtonItems(nil, animated: false)
    }
    
    func setExtendedLayoutNavBar(extendedLayoutIncludesOpaqueBars: Bool) {
        delegate?.setExtendedLayoutNavBar(extendedLayoutIncludesOpaqueBars: extendedLayoutIncludesOpaqueBars)
    }
    
    func setDefaultModeWithoutThreeDot(title: String = "") {
        delegate?.setTitle(title, isSelectionMode: false, style: .white)
        delegate?.setLeftBarButtonItems(nil, animated: true)
    }

    func setTrashBinMode(title: String, innerFolder: Bool = false, emptyDataList: Bool = true) {
        delegate?.setTitle(title, isSelectionMode: false, style: .white)
        let rightButtons: [UIBarButtonItem]? = innerFolder || emptyDataList ? nil : [trashButton]
        delegate?.setRightBarButtonItems(rightButtons, animated: false)
        delegate?.setLeftBarButtonItems(nil, animated: false)
    }
    
    @objc private func onCancelSelectionButton() {
        delegate?.onCancelSelectionButton()
    }
    
    @objc private func onPlusButton() {
        delegate?.onPlusButton()
    }
    
    @objc private func onSettingsButton() {
        delegate?.onSettingsButton()
    }

    @objc private func onTrashBinButton() {
        delegate?.onTrashBinButton()
    }

    @objc private func onBackButton() {
        delegate?.onBackButton()
    }
}

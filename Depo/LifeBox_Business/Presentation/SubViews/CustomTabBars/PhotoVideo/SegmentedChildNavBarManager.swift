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
    func onSettingsButton()
}

final class SegmentedChildNavBarManager {
    
    private lazy var cancelSelectionButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(onCancelSelectionButton),
                         for: UIControlEvents.touchUpInside)
        button.setTitle(TextConstants.cancelSelectionButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 18)
        button.setTitleColor(ColorConstants.confirmationPopupTitle, for: .normal)
        
       return UIBarButtonItem(customView: button)
    }()
    
    /// public bcz can be disabled
    lazy var threeDotsButton = UIBarButtonItem(
        image: Images.threeDots,
        style: .plain,
        target: self,
        action: #selector(onThreeDotsButton))
    
    private(set) lazy var plusButton: UIBarButtonItem =  {
        
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "PlusButtonBusiness"),
                            for: .normal)

            button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
            
            button.addTarget(self, action: #selector(onPlusButton),
                             for: UIControlEvents.touchUpInside)
            return UIBarButtonItem(customView: button)

    }()
    
    lazy var settingsButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        
        let initials = (SingletonStorage.shared.accountInfo?.name?.firstLetter ?? "") + (SingletonStorage.shared.accountInfo?.surname?.firstLetter ?? "")
        
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
    
    private lazy var searchButton = UIBarButtonItem(
        image: Images.search,
        style: .plain,
        target: self,
        action: #selector(onSearchButton))
    
    private weak var delegate: SegmentedChildNavBarManagerDelegate?
    
    init(delegate: SegmentedChildNavBarManagerDelegate?) {
        self.delegate = delegate
    }
    
    func setSelectionMode() {
        delegate?.setLeftBarButtonItems([cancelSelectionButton], animated: true)
        delegate?.setRightBarButtonItems([threeDotsButton], animated: false)
    }
    
    func setDefaultMode(title: String = "") {
        delegate?.setTitle(title)
        delegate?.setRightBarButtonItems([plusButton], animated: false)
        delegate?.setLeftBarButtonItems([settingsButton], animated: false)
        threeDotsButton.isEnabled = true
    }
    
    func setNestedMode(title: String = "") {
        delegate?.setTitle(title)
        delegate?.setRightBarButtonItems([plusButton], animated: false)
        threeDotsButton.isEnabled = true
    }
    
    func setDefaultModeWithoutThreeDot(title: String = "") {
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
    
    @objc private func onSettingsButton() {
        delegate?.onSettingsButton()
    }
}

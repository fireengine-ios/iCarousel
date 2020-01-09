//
//  TrashBinNavbarManager..swift
//  Depo
//
//  Created by Andrei Novikau on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol TrashBinNavbarManagerDelegate: NavbarManagerDelegate {
    func onMore(_ sender: UIBarButtonItem)
    func onSearch()
}

final class TrashBinNavbarManager {
    
    weak var delegate: (TrashBinNavbarManagerDelegate & UIViewController)?

    private lazy var cancelButton = UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                                                    font: .TurkcellSaturaDemFont(size: 19.0),
                                                    target: self,
                                                    selector: #selector(onCancel))
    
    private lazy var moreButton = UIBarButtonItem(image: Images.threeDots,
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(onMore))
    
    private lazy var searchButton = UIBarButtonItem(image: Images.search,
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(onSearch))
    
    // MARK: -
    
    required init(delegate: (TrashBinNavbarManagerDelegate & UIViewController)?) {
        self.delegate = delegate
    }
    
    func setDefaultState(sortType type: SortedRules) {
        moreButton.isEnabled = true
        delegate?.setTitle(withString: TextConstants.hiddenBinNavBarTitle, andSubTitle: type.descriptionForTitle)
        delegate?.setLeftBarButtonItems(nil, animated: true)
        delegate?.setRightBarButtonItems([moreButton, searchButton], animated: true)
    }
    
    func setSelectionState() {
        moreButton.isEnabled = false
        delegate?.setTitle(withString: "0 \(TextConstants.accessibilitySelected)")
        delegate?.setLeftBarButtonItems([cancelButton], animated: true)
        delegate?.setRightBarButtonItems([moreButton], animated: true)
    }
    
    func changeSelectionItems(count: Int) {
        moreButton.isEnabled = count > 0
        delegate?.setTitle(withString: "\(count) \(TextConstants.accessibilitySelected)")
    }
    
    func setMoreButton(isEnabled: Bool) {
        moreButton.isEnabled = isEnabled
    }
    
    // MARK: - Actions
    
    @objc private func onCancel() {
        delegate?.onCancel()
    }
    
    @objc private func onMore() {
        delegate?.onMore(moreButton)
    }
    
    @objc private func onSearch() {
        delegate?.onSearch()
    }
}

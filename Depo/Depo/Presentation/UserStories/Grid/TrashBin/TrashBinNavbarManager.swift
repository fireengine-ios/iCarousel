//
//  TrashBinNavbarManager..swift
//  Depo
//
//  Created by Andrei Novikau on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol TrashBinNavbarManagerDelegate: SegmentedChildController {
    func onMore(_ sender: UIBarButtonItem)
    func onSearch()
    func onCancel()
}

final class TrashBinNavbarManager {
    
    enum State {
        case `default`
        case selection
    }
    
    weak var delegate: TrashBinNavbarManagerDelegate?

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
    
    private var state: State = .default {
        didSet {
            setupNavBarButtons(animated: true)
        }
    }
    
    // MARK: -
    
    required init(delegate: TrashBinNavbarManagerDelegate?) {
        self.delegate = delegate
    }
    
    func setDefaultState(sortType type: SortedRules) {
        state = .default
        moreButton.isEnabled = true
        delegate?.setTitle(withString: TextConstants.hiddenBinNavBarTitle, andSubTitle: type.descriptionForTitle)
    }
    
    func setSelectionState() {
        state = .selection
        moreButton.isEnabled = false
        delegate?.setTitle("0 \(TextConstants.accessibilitySelected)")
    }
    
    func changeSelectionItems(count: Int) {
        moreButton.isEnabled = count > 0
        delegate?.setTitle("\(count) \(TextConstants.accessibilitySelected)")
    }
    
    func setMoreButton(isEnabled: Bool) {
        moreButton.isEnabled = isEnabled
    }
    
    func setupNavBarButtons(animated: Bool) {
        switch state {
        case .default:
            delegate?.setLeftBarButtonItems(nil, animated: animated)
            delegate?.setRightBarButtonItems([moreButton, searchButton], animated: animated)
            
        case .selection:
            delegate?.setLeftBarButtonItems([cancelButton], animated: animated)
            delegate?.setRightBarButtonItems([moreButton], animated: animated)
        }
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

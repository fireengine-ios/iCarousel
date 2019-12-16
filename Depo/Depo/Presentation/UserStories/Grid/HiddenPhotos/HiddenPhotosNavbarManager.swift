//
//  HiddenPhotosNavbarManager.swift
//  Depo
//
//  Created by Andrei Novikau on 12/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol HiddenPhotosNavbarManagerDelegate: NavbarManagerDelegate {
    func onMore(_ sender: UIBarButtonItem)
    func onSearch()
}

final class HiddenPhotosNavbarManager {
    
    weak var delegate: (HiddenPhotosNavbarManagerDelegate & UIViewController)?

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
    
    required init(delegate: (HiddenPhotosNavbarManagerDelegate & UIViewController)?) {
        self.delegate = delegate
    }
    
    func setDefaultState(sortType type: SortedRules) {
        moreButton.isEnabled = true
        delegate?.setTitle(withString: TextConstants.Spotify.Playlist.navBarTitle, andSubTitle: type.descriptionForTitle)
        delegate?.setLeftBarButtonItems(nil, animated: true)
        delegate?.setRightBarButtonItems([moreButton, searchButton], animated: true)
    }
    
    func setSelectionState() {
        moreButton.isEnabled = false
        delegate?.setTitle(withString: TextConstants.Spotify.Playlist.navBarSelectiontTitle)
        delegate?.setLeftBarButtonItems([cancelButton], animated: true)
        delegate?.setRightBarButtonItems([moreButton], animated: true)
    }
    
    func changeSelectionItems(count: Int) {
        moreButton.isEnabled = count > 0
        if count == 0 {
            delegate?.setTitle(withString: TextConstants.Spotify.Playlist.navBarSelectiontTitle)
        } else {
            delegate?.setTitle(withString: "\(count) \(TextConstants.accessibilitySelected)")
        }
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

//
//  SpotifyPlaylistsNavbarManager.swift
//  Depo
//
//  Created by Andrei Novikau on 7/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol SpotifyPlaylistsNavbarManagerDelegate: class {
    func onCancelSelection()
    func onSelectAll()
    func onMore()
}

extension SpotifyPlaylistsNavbarManagerDelegate where Self: UIViewController {
    
    func setTitle(_ title: String) {
        navigationItem.title = title
    }
    
    func setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        navigationItem.leftBarButtonItems = nil
        navigationItem.setLeftBarButtonItems(items, animated: animated)
    }
    
    func setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        navigationItem.rightBarButtonItems = nil
        navigationItem.setRightBarButtonItems(items, animated: animated)
    }
}

final class SpotifyPlaylistsNavbarManager {
    
    private weak var delegate: (SpotifyPlaylistsNavbarManagerDelegate & UIViewController)?
    
    private lazy var cancelSelectionButton: UIBarButtonItem = {
        return UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                               font: .TurkcellSaturaDemFont(size: 19.0),
                               target: self,
                               selector: #selector(onCancelSelection))
    }()
    
    private lazy var selectAllButton: UIBarButtonItem = {
        return UIBarButtonItem(title: TextConstants.actionSheetSelectAll,
                               font: .TurkcellSaturaDemFont(size: 19.0),
                               target: self,
                               selector: #selector(onSelectAll))
    }()
    
    private lazy var moreButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: TextConstants.moreBtnImgName),
                               style: .plain,
                               target: self,
                               action: #selector(onMore))
    }()
    
    // MARK: -
    
    required init(delegate: (SpotifyPlaylistsNavbarManagerDelegate & UIViewController)?) {
        self.delegate = delegate
        delegate?.setRightBarButtonItems([moreButton], animated: false)
    }
    
    func changeSelectionItems(count: Int) {
//        moreButton.isEnabled = count > 0
        if count == 0 {
            //TODO: Need localize
            delegate?.setTitle(withString: "Select Items")
        } else {
            delegate?.setTitle(withString: "\(count) \(TextConstants.accessibilitySelected)")
        }
    }
    
    func setSelectionState() {
        delegate?.setLeftBarButtonItems([cancelSelectionButton], animated: true)
    }
    
    func setDefaultState() {
        //TODO: Need localize
        delegate?.setTitle(withString: "Spotify Playlists")
        delegate?.setLeftBarButtonItems(nil, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func onCancelSelection() {
        delegate?.onCancelSelection()
    }
    
    @objc private func onMore() {
        delegate?.onMore()
    }
    
    @objc private func onSelectAll() {
        delegate?.onSelectAll()
    }
}

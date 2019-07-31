//
//  SpotifyPlaylistsNavbarManager.swift
//  Depo
//
//  Created by Andrei Novikau on 7/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol SpotifyPlaylistsNavbarManagerDelegate: class {
    func onCancel()
    func onSelectAll()
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
    
    private lazy var cancelAsBackButton: UIBarButtonItem = {
        return UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                               font: .TurkcellSaturaDemFont(size: 19.0),
                               target: self,
                               selector: #selector(onCancel))
    }()
    
    private lazy var selectAllButton: UIBarButtonItem = {
        return UIBarButtonItem(title: TextConstants.actionSheetSelectAll,
                               font: .TurkcellSaturaDemFont(size: 19.0),
                               target: self,
                               selector: #selector(onSelectAll))
    }()
    
    // MARK: -
    
    required init(delegate: (SpotifyPlaylistsNavbarManagerDelegate & UIViewController)?) {
        self.delegate = delegate
    }
    
    func setSelectionState() {
        delegate?.setTitle(withString: TextConstants.Spotify.Playlist.navBarTitle)
        delegate?.setLeftBarButtonItems([cancelAsBackButton], animated: true)
        delegate?.setRightBarButtonItems([selectAllButton], animated: false)
    }
    
    func changeSelectionItems(count: Int) {
        if count == 0 {
            delegate?.setTitle(withString: TextConstants.Spotify.Playlist.navBarTitle)
        } else {
            delegate?.setTitle(withString: "\(count) \(TextConstants.accessibilitySelected)")
        }
    }
    
    // MARK: - Actions
    
    @objc private func onCancel() {
        delegate?.onCancel()
    }
    
    @objc private func onSelectAll() {
        delegate?.onSelectAll()
    }
}

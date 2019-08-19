//
//  SpotifyPlaylistsNavbarManager.swift
//  Depo
//
//  Created by Andrei Novikau on 7/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol NavbarManagerDelegate: class {
    func onCancel()
}

extension NavbarManagerDelegate where Self: UIViewController {
    
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

protocol SpotifyPlaylistsNavbarManagerDelegate: NavbarManagerDelegate {
    func onSelectAll()
    func onDone()
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
    
    private lazy var doneAsBackButton: UIBarButtonItem = {
        return UIBarButtonItem(title: TextConstants.accessibilityDone,
                               font: .TurkcellSaturaDemFont(size: 19.0),
                               target: self,
                               selector: #selector(onDone))
    }()
    
    // MARK: -
    
    required init(delegate: (SpotifyPlaylistsNavbarManagerDelegate & UIViewController)?) {
        self.delegate = delegate
    }
    
    func setSelectionState() {
        delegate?.setTitle(withString: TextConstants.Spotify.Playlist.navBarTitle)
        delegate?.setLeftBarButtonItems([cancelAsBackButton], animated: true)
        delegate?.setRightBarButtonItems([selectAllButton], animated: true)
    }
    
    func setSuccessImportState() {
        delegate?.setTitle(withString: TextConstants.Spotify.Playlist.navBarTitle)
        delegate?.setLeftBarButtonItems(nil, animated: true)
        delegate?.setRightBarButtonItems([doneAsBackButton], animated: true)
    }
    
    func setSelectAll(isEnabled: Bool) {
        selectAllButton.isEnabled = isEnabled
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
    
    @objc private func onDone() {
        delegate?.onDone()
    }
}

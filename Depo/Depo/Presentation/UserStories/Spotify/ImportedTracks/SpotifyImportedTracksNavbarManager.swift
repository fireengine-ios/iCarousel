//
//  SpotifyImportedTracksNavbarManager.swift
//  Depo
//
//  Created by Andrei Novikau on 8/9/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyImportedTracksNavbarManager: SpotifyImportedPlaylistsNavbarManager {

    var playlist: SpotifyPlaylist?

    required init(delegate: (SpotifyImportedPlaylistsNavbarManagerDelegate & UIViewController)?) {
        super.init(delegate: delegate)
    }
    
    convenience init(delegate: (SpotifyImportedPlaylistsNavbarManagerDelegate & UIViewController)?, playlist: SpotifyPlaylist) {
        self.init(delegate: delegate)
        self.playlist = playlist
    }
    
    override func setDefaultState() {
        super.setDefaultState()
        
        if let playlist = playlist {
            delegate?.setTitle(withString: playlist.name,
                               andSubTitle: String(format: TextConstants.Spotify.Playlist.songsCount, playlist.count))
        }
    }
}

//
//  MusicViewInput.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 8/15/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol MusicViewInput: BaseFilesGreedViewInput {
    
    func didRefreshSpotifyStatusView(isHidden: Bool, status: SpotifyStatus?)
    
    func importSendToBackground()
    
    func spotifyStatusDidChange(_ newStatus: SpotifyStatus)
    
}

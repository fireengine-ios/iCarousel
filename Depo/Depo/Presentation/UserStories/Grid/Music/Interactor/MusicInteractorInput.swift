//
//  MusicInteractorInput.swift
//  Depo
//
//  Created by Harbros12 on 8/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol MusicInteractorInput: BaseFilesGreedInteractorInput {
    
    var spotifyStatus: SpotifyStatus? { get }
    func processSpotifyStatusViewTap()
    
}

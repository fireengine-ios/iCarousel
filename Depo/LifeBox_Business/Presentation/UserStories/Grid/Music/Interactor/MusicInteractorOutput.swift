//
//  MusicInteractorOutput.swift
//  Depo
//
//  Created by Harbros12 on 8/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol MusicInteractorOutput: BaseFilesGreedInteractorOutput {
    
    func didSpotifyStatus(_ status: SpotifyStatus)
    
    func failedObtainSpotifyStatus()
    
    func didImportSendToBackground()
    
    func didSpotifyStatusChange(_ newStatus: SpotifyStatus)
}


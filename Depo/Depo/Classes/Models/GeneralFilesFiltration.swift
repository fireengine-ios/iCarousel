//
//  GeneralFilesFiltration.swift
//  Depo_LifeTech
//
//  Created by Aleksandr on 10/6/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

enum GeneralFilesFiltrationType {
    case fileType(FileType)
    case syncStatus(SyncWrapperedStatus)
    case favoriteStatus(FavoriteGeneralFilter)
    case localStatus(LocalGeneralFilter)
    
    //
    case duplicates
}

enum LocalGeneralFilter {
    case local
    case nonLocal
    case all
}

enum FavoriteGeneralFilter {
    case favorites
    case notFavorites
    case all
}

//struct GeneralFilesFiltrationTypeConfig {
//    let fileTypes: [FileType]
//    let favoritesOnly: Bool
//    let syncStatus: MoreActionsConfig.CellSyncType
//}


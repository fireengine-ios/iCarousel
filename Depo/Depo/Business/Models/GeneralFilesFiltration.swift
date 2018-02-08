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
    case rootFolder(String)
    case rootAlbum(String)
    case parentless //not owned by folder
    case duplicates
    case name(String)
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

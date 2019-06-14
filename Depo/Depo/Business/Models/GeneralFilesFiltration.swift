//
//  GeneralFilesFiltration.swift
//  Depo_LifeTech
//
//  Created by Aleksandr on 10/6/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

enum GeneralFilesFiltrationType: Equatable {
    case fileType(FileType)
    case syncStatus(SyncWrapperedStatus)
    case favoriteStatus(FavoriteGeneralFilter)
    case localStatus(LocalGeneralFilter)
    case rootFolder(String)
    case rootAlbum(String)
    case parentless //not owned by folder
//    case duplicates
    case name(String)

    static func ==(lhs: GeneralFilesFiltrationType, rhs: GeneralFilesFiltrationType) -> Bool {
        switch (lhs, rhs) {
        case (let .fileType(type1), let .fileType(type2)): return type1 == type2
        case (let .syncStatus(status1), let .syncStatus(status2)): return status1 == status2
        case (let .favoriteStatus(status1), let .favoriteStatus(status2)): return status1 == status2
        case (let .localStatus(status1), let .localStatus(status2)): return status1 == status2
        case (let .rootFolder(folder1), let .rootFolder(folder2)): return folder1 == folder2
        case (let .rootAlbum(album1), let .rootAlbum(album2)): return album1 == album2
        case (.parentless, .parentless): return true
//        case (.duplicates, .duplicates): return true
        case (let .name(name1), let .name(name2)): return name1 == name2
        default:
            return false
        }
    }
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

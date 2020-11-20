//
//  WrapDataSorting.swift
//  Depo
//
//  Created by Konstantin Studilin on 12.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation


final class WrapDataSorting {
    static func sort(items: [WrapData], sortType: SortedRules) -> [WrapData] {
        var tempoArray = items
        switch sortType {
        case .timeUp, .timeUpWithoutSection, .lastModifiedTimeUp:
            tempoArray.sort{$0.creationDate! > $1.creationDate!}
        case .timeDown, .timeDownWithoutSection, .lastModifiedTimeDown:
            tempoArray.sort{$0.creationDate! < $1.creationDate!}
        case .lettersAZ, .albumlettersAZ:
            tempoArray.sort{String($0.name!.first!).uppercased() < String($1.name!.first!).uppercased()}
        case .lettersZA, .albumlettersZA:
            tempoArray.sort{String($0.name!.first!).uppercased() > String($1.name!.first!).uppercased()}
        case .sizeAZ:
            tempoArray.sort{$0.fileSize > $1.fileSize}
        case .sizeZA:
            tempoArray.sort{$0.fileSize < $1.fileSize}
        case .metaDataTimeUp:
            tempoArray.sort{$0.metaDate > $1.metaDate}
        case .metaDataTimeDown:
            tempoArray.sort{$0.metaDate < $1.metaDate}
        }
        return tempoArray
    }
}

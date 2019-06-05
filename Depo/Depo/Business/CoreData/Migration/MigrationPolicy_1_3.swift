//
//  MigrationPolicy_1_3.swift
//  Depo
//
//  Created by Konstantin Studilin on 03/06/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


class MediaItemMigrationPolicy_1_3: NSEntityMigrationPolicy {
    @objc func uuidWith(_ trimmedLocalFileID:String) -> String {
        return trimmedLocalFileID.appending("~\(UUID().uuidString)")
    }
}

//
//  MigrationPolicy_3_4.swift
//  Depo
//
//  Created by Konstantin Studilin on 18/12/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


class MediaItemMigrationPolicy_3_4: NSEntityMigrationPolicy {
    @objc func status(_ isTranscoded: Bool) -> Int16 {
        let status: ItemStatus = isTranscoded ? .active : .unknown
        return status.valueForCoreDataMapping()
    }
}

//
//  UploadProgressItem.swift
//  Depo
//
//  Created by Konstantin Studilin on 02.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation


enum UploadProgressStatus {
    case ready
    case inProgress
    case completed
    case failed
}

final class UploadProgressItem {
    private(set) var item: WrapData?
    private(set) var status: UploadProgressStatus = .ready
    
    init(item: WrapData, status: UploadProgressStatus) {
        self.item = item
        self.status = status
    }
    
    func set(status: UploadProgressStatus) {
        self.status = status
    }
}

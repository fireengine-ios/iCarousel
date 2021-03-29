//
//  UploadProgressItem.swift
//  Depo
//
//  Created by Konstantin Studilin on 02.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation


enum UploadProgressStatus: Int, Comparable {
    
    static func < (lhs: UploadProgressStatus, rhs: UploadProgressStatus) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case inProgress = 0
    case ready
    case completed
    case failed
}

final class UploadProgressItem {
    private(set) var item: WrapData?
    private let addedToQueue = Date()
    private(set) var status: UploadProgressStatus = .ready
    
    init(item: WrapData, status: UploadProgressStatus) {
        self.item = item
        self.status = status
    }
    
    func set(status: UploadProgressStatus) {
        self.status = status
    }
}

extension UploadProgressItem {
  enum Comparison {
    static let ascending: (UploadProgressItem, UploadProgressItem) -> Bool = {
        return ($0.status, $0.addedToQueue, $0.item?.name ?? "") < ($1.status, $1.addedToQueue, $0.item?.name ?? "")
    }
  }
}

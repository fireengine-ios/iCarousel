//
//  UploadProgressManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 01.03.2021.
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

protocol UploadProgressManagerDelegate: class {
    func append(items: [UploadProgressItem])
    func remove(items: [UploadProgressItem])
    func setUploadProgress(for item: UploadProgressItem, bytesUploaded: Int, ratio: Float)
    func update(item: UploadProgressItem)
    func cleanAll()
}


final class UploadProgressManager {

    static let shared = UploadProgressManager()

    weak var delegate: UploadProgressManagerDelegate?

    func append(items: [WrapData]) {
        let uploadProgressItems = items.compactMap { UploadProgressItem(item: $0, status: .ready) }
        delegate?.append(items: uploadProgressItems)
    }
    
    func remove(items: [WrapData]) {
        let uploadProgressItems = items.compactMap { UploadProgressItem(item: $0, status: .ready) }
        delegate?.remove(items: uploadProgressItems)
    }
    
    func update(item: WrapData, status: UploadProgressStatus) {
        let uploadProgressItem = UploadProgressItem(item: item, status: status)
        delegate?.update(item: uploadProgressItem)
    }
    
    func setUploadProgress(for item: WrapData, bytesUploaded: Int, ratio: Float) {
        let uploadProgressItem = UploadProgressItem(item: item, status: .inProgress)
        delegate?.setUploadProgress(for: uploadProgressItem, bytesUploaded: bytesUploaded, ratio: ratio)
    }
    
    func cleanAll() {
        delegate?.cleanAll()
    }
}

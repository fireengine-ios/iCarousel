//
//  ItemSyncOperation.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 2/12/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


final class ItemSyncOperation: Operation {
    
    private let semaphore = DispatchSemaphore(value: 0)
    private var service: ItemSyncService?
    private var newItems: Bool = false
    
    
    init(service: ItemSyncService, newItems: Bool) {
        super.init()
        self.service = service
        self.newItems = newItems
        NotificationCenter.default.addObserver(self, selector: #selector(itemStatusChanged), name: .autoSyncStatusDidChange, object: service)
    }
    
    override func cancel() {
        super.cancel()
        
        NotificationCenter.default.removeObserver(self)
        service = nil
        
        semaphore.signal()
    }
    
    override func main() {
        service?.start(newItems: newItems)
        
        if !newItems, service?.status != .executing {
            semaphore.wait()
        }
    }
    
    @objc
    private func itemStatusChanged() {
        if let prepairing = service?.status.isContained(in: [ .undetermined, .prepairing]), !prepairing {
            cancel()
        }
    }
    
}

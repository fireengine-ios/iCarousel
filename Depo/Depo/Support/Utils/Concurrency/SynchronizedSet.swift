//
//  SynchronizedSet.swift
//  Depo
//
//  Created by Andrei Novikau on 10/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class SynchronizedSet<T: Hashable> {
    
    private let queue = DispatchQueue(label: DispatchQueueLabels.syncronizedSet, attributes: .concurrent)
    private var storage: Set<T> = []
    
    func contains(_ item: T) -> Bool {
        var containsItem: Bool!
        queue.sync {
            containsItem = self.storage.contains(item)
        }
        return containsItem
    }
    
    func insert(_ item: T) {
        queue.async(flags: .barrier) {
            self.storage.insert(item)
        }
    }
    
    func remove(_ item: T) {
        queue.async(flags: .barrier) {
            self.storage.remove(item)
        }
    }
    
    func removeAll() {
        queue.async(flags: .barrier) {
            self.storage.removeAll()
        }
    }
    
}


extension SynchronizedSet {
    // The number of elements in the array.
    var count: Int {
        var result = 0
        queue.sync { result = self.storage.count }
        return result
    }
    
    func getSet() -> Set<T> {
        var result = Set<T>()
        queue.sync {
            result = storage
        }
        return result
    }
    
    func getArray() -> [T] {
        var result = [T]()
        queue.sync {
            result = Array(storage)
        }
        return result
    }
}

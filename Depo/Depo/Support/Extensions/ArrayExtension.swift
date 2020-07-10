//
//  ArrayExtension.swift
//  Depo
//
//  Created by Andrei Novikau on 13/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func remove(_ element: Element) {
        for index in (0..<count).reversed() where self[index] == element {
            self.remove(at: index)
        }
    }
}

extension Array {
    mutating func append(_ newElement: Element?) {
        if let element = newElement {
            self.append(element)
        }
    }
    
    #if swift(>=5.0)
    func cutFirstItems(itemsNumber: Int) -> Self {
        return (self.count > itemsNumber) ? Array(self[0..<itemsNumber]) : self
    }
    #else
    func cutFirstItems(itemsNumber: Int) -> [Element] {
        return (self.count > itemsNumber) ? Array(self[0..<itemsNumber]) : self
    }
    #endif
    
    var hasItems: Bool {
        return !self.isEmpty
    }
}

extension Optional where Wrapped == Array<Any> {
    var hasItems: Bool {
        return !(self?.isEmpty ?? true)
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

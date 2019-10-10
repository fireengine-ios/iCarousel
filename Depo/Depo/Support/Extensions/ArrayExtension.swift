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
    
    func cutFirstItems(itemsNumber: Int) -> Self {
        return (self.count > itemsNumber) ? Array(self[0..<itemsNumber]) : self
    }
    
    var hasItems: Bool {
        return !self.isEmpty
    }
}

extension Optional where Wrapped == Array<Any> {
    var hasItems: Bool {
        return !(self?.isEmpty ?? true)
    }
}

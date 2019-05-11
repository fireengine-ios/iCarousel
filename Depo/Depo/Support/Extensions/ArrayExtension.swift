//
//  ArrayExtension.swift
//  Depo
//
//  Created by Andrei Novikau on 13/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

public extension Array where Element: Equatable {    
    public mutating func remove(_ element: Element) {
        for index in (0..<count).reversed() where self[index] == element {
            self.remove(at: index)
        }
    }
    
    public mutating func append(_ newElement: Element?) {
        if let element = newElement {
            self.append(element)
        }
    }
}

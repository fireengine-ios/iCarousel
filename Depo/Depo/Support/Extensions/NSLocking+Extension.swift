//
//  NSLocking+Extension.swift
//  Depo
//
//  Created by Konstantin Studilin on 11/11/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


extension NSLocking {
    func withCriticalSection<T>(block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
}

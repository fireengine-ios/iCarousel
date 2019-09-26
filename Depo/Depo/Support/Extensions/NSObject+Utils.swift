//
//  NSObject+Utils.swift
//  Depo
//
//  Created by Darya Kuliashova on 9/24/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}

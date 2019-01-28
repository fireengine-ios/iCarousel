//
//  UIColor+RGB.swift
//  Depo
//
//  Created by Darya Kuliashova on 1/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

extension UIColor {
    convenience init(_ r: CGFloat,_ g: CGFloat,_ b: CGFloat,_ a: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
}

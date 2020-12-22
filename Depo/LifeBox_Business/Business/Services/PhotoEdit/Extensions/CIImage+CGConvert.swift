//
//  CIImage+CGConvert.swift
//  Depo
//
//  Created by Konstantin Studilin on 07.09.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import CoreGraphics


extension CIImage {
    var toCGImage: CGImage? {
        let context = CIContext(options: nil)
        
        return context.createCGImage(self, from: extent)
    }
}

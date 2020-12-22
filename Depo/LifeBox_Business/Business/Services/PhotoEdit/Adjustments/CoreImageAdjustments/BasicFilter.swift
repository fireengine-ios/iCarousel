//
//  BasicFilter.swift
//  Depo
//
//  Created by Konstantin Studilin on 14.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


protocol BasicFilter {
    var inputImage: CIImage? { get set }
    var outputImage: CIImage? { get }
}

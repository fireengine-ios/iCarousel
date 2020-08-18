//
//  CustomFilter.swift
//  Depo
//
//  Created by Konstantin Studilin on 17.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import MetalPetal

protocol CustomFilterProtocol {
    var type: FilterType { get }
    var parameters: [FilterParameterProtocol] { get }
    
    func apply(on image: MTIImage?) -> MTIImage?
}


enum FilterType: String, CaseIterable {
    case clarendon
    case metropolis
    case lime
}

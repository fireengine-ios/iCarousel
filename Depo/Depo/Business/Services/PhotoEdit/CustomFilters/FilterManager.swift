//
//  FilterManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 17.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


enum FilterType: String {
    case clarendon
}


final class FilterManager {
    private static func filter(type: FilterType) -> CustomFilterProtocol? {
        switch type {
            case .clarendon:
                let intensityParameter = AdjustmentParameter(type: .filterIntensity)
                return MPClarendonFilter(parameters: [intensityParameter])
            
            default:
                assertionFailure("Filter is not implemented")
                return nil
        }
    }
    
    
    let filters: [CustomFilterProtocol]
    
    
    init(types: [FilterType]) {
        filters = types.compactMap { FilterManager.filter(type: $0) }
    }
    
    
    func filteredPreviews(image: UIImage, intensity: Float = 1.0) -> [FilterType: UIImage] {
        var result = [FilterType: UIImage]()
        
        filters.forEach {
            if let filtered = $0.apply(on: image.makeMTIImage(), intensity: intensity)?.makeUIImage() {
                result[$0.type] = filtered
            }
        }
        
        return result
    }
}

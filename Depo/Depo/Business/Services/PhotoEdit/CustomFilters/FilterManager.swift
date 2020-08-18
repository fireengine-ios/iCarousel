//
//  FilterManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 17.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


final class FilterManager {
    private static func filter(type: FilterType) -> CustomFilterProtocol? {
        switch type {
            case .clarendon:
                let intensityParameter = FilterParameter(type: .filterIntensity)
                let filter = MPClarendonFilter(parameters: [intensityParameter])
                return filter
            
            case .lime:
                let intensityParameter = FilterParameter(type: .filterIntensity)
                let filter = MPLimeFilter(parameters: [intensityParameter])
                return filter
            
            case .metropolis:
                let intensityParameter = FilterParameter(type: .filterIntensity)
                let filter = MPMetropolisFilter(parameters: [intensityParameter])
                return filter
            
            default:
                assertionFailure("Filter is not implemented")
                return nil
        }
    }
    
    
    let filters: [CustomFilterProtocol]
    
    
    init(types: [FilterType]) {
        filters = types.compactMap { FilterManager.filter(type: $0) }
    }
    
    
    func filteredPreviews(image: UIImage?) -> [FilterType: UIImage] {
        var result = [FilterType: UIImage]()
        
        guard let source = image else {
            assertionFailure("Pass a nonnil image")
            return result
        }
        
        guard let mtiImage = source.makeMTIImage(isOpaque: source.isOpaque) else {
            return result
        }
        
        filters.forEach {
            if let filtered = $0.apply(on: mtiImage)?.makeUIImage() {
                result[$0.type] = filtered
            }
        }
        
        return result
    }
    

    func filter(image: UIImage?, type: FilterType) -> UIImage? {
        guard let source = image, let filter = filters.first(where: { $0.type == type }) else {
            return image
        }
        
        guard let mtiImage = source.makeMTIImage(isOpaque: source.isOpaque) else {
            return image
        }
        
        return filter.apply(on: mtiImage)?.makeUIImage()
    }
}

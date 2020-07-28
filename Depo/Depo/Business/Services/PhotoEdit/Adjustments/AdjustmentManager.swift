//
//  AdjustmentManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 28.07.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import GPUImage


final class AdjustmentManager {
    
    static let shared = AdjustmentManager()
    
    
    func adjustment(type: AdjustmentType) -> Adjustment? {
        var parameters = [AdjustmentParameterProtocol]()
        var thirdPartyAdjustment: ThirdPartyAdjustmentProtocol?
        
        switch type {
            case .brightness:
                let gpuOperation = BrightnessAdjustment()
                let brightnessAdj = AdjustmentParameter(type: .brightness).onValueDidChange { value in
                    gpuOperation.brightness = value
                }
                parameters = [brightnessAdj]
                thirdPartyAdjustment = GPUAdjustment(operation: gpuOperation)
            
            default:
                assertionFailure("Add missing AdjustmentType")
                break
        }
        
        guard let thirdParty = thirdPartyAdjustment else {
            assertionFailure("Add missing thirdPartyAdjustment")
            return nil
        }
        
        return Adjustment(type: type, parameters: parameters, thirdPartyAdjustment: thirdParty)
    }
    
    
    private init() {}
}

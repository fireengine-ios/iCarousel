//
//  AdjustmentManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 28.07.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import GPUImage


final class AdjustmentManager {
    
    private static func adjustment(type: AdjustmentType) -> Adjustment? {
        var parameters = [AdjustmentParameterProtocol]()
        var thirdPartyAdjustment: ThirdPartyAdjustmentProtocol?
        
        switch type {
            case .brightness:
                let gpuOperation = BrightnessAdjustment()
                let brightnessParameter = AdjustmentParameter(type: .brightness).onValueDidChange { value in
                    gpuOperation.brightness = value
                }
                parameters = [brightnessParameter]
                thirdPartyAdjustment = GPUAdjustment(operation: gpuOperation)
            
            case .contrast:
                let gpuOperation = ContrastAdjustment()
                let contrastParameter = AdjustmentParameter(type: .contrast).onValueDidChange { value in
                    gpuOperation.contrast = value
                }
                parameters = [contrastParameter]
                thirdPartyAdjustment = GPUAdjustment(operation: gpuOperation)
            
            case .exposure:
                let gpuOperation = ExposureAdjustment()
                let exposureParameter = AdjustmentParameter(type: .exposure).onValueDidChange { value in
                    gpuOperation.exposure = value
                }
                parameters = [exposureParameter]
                thirdPartyAdjustment = GPUAdjustment(operation: gpuOperation)
            
            case .highlightsAndShadows:
                let gpuOperation = HighlightsAndShadows()
                let highlightsParameter = AdjustmentParameter(type: .highlights).onValueDidChange { value in
                    gpuOperation.highlights = value
                }
                let shadowsParameter = AdjustmentParameter(type: .shadows).onValueDidChange { value in
                    gpuOperation.shadows = value
                }
                parameters = [highlightsParameter, shadowsParameter]
                thirdPartyAdjustment = GPUAdjustment(operation: gpuOperation)
            
            case .whiteBalance:
                let gpuOperation = WhiteBalance()
                let temperatureParameter = AdjustmentParameter(type: .temperature).onValueDidChange { value in
                    gpuOperation.temperature = value
                }
                let tintParameter = AdjustmentParameter(type: .tint).onValueDidChange { value in
                    gpuOperation.tint = value
                }
                parameters = [temperatureParameter, tintParameter]
                thirdPartyAdjustment = GPUAdjustment(operation: gpuOperation)
            
            case .saturation:
                let gpuOperation = SaturationAdjustment()
                let saturationParameter = AdjustmentParameter(type: .saturation).onValueDidChange { value in
                    gpuOperation.saturation = value
                }
                parameters = [saturationParameter]
                thirdPartyAdjustment = GPUAdjustment(operation: gpuOperation)
            
            case .gamma:
                let gpuOperation = GammaAdjustment()
                let gammaParameter = AdjustmentParameter(type: .gamma).onValueDidChange { value in
                    gpuOperation.gamma = value
                }
                parameters = [gammaParameter]
                thirdPartyAdjustment = GPUAdjustment(operation: gpuOperation)
            
            case .hue:
                let gpuOperation = HueAdjustment()
                let hueParameter = AdjustmentParameter(type: .hue).onValueDidChange { value in
                    gpuOperation.hue = value
                }
                parameters = [hueParameter]
                thirdPartyAdjustment = GPUAdjustment(operation: gpuOperation)
            
            case .monochrome:
                let gpuOperation = MonochromeFilter()
                let intensityParameter = AdjustmentParameter(type: .intensity).onValueDidChange { value in
                    gpuOperation.intensity = value
                }
                parameters = [intensityParameter]
                thirdPartyAdjustment = GPUAdjustment(operation: gpuOperation)
            
            case .hsl:
                let coreAdjustment = HSVMultiband()
                
                let saturarionParameter = AdjustmentParameter(type: .saturation).onValueDidChange { value in
                    let newShift = CIVector(x: 0, y: CGFloat(value), z: 1)
                    coreAdjustment.inputBlueShift = newShift
                }
                
                let intensityParameter = AdjustmentParameter(type: .intensity).onValueDidChange { value in
                    let newShift = CIVector(x: 0, y: 1, z: CGFloat(value))
                    //                    coreAdjustment.inputGreenShift = newShift
                    //                    coreAdjustment.inputAquaShift = newShift
                    coreAdjustment.inputBlueShift = newShift
                    //                    coreAdjustment.inputMagentaShift = newShift
                    //                    coreAdjustment.inputPurpleShift = newShift
                    //                    coreAdjustment.inputOrangeShift = newShift
                }
                parameters = [saturarionParameter, intensityParameter]
                thirdPartyAdjustment = CoreImageAdjustment(filter: coreAdjustment)
            
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
    
    
    let adjustments: [AdjustmentProtocol]
    let parameters: [AdjustmentParameterProtocol]
    
    private let operationQueue: OperationQueue = {
           let queue = OperationQueue()
           queue.maxConcurrentOperationCount = 1
           return queue
       }()
    
    
    required init(types: [AdjustmentType]) {
        adjustments = types.compactMap { AdjustmentManager.adjustment(type: $0) }
        parameters = adjustments.flatMap { $0.parameters }
    }
    
    
    private func updateValues(parameterType: AdjustmentParameterType, value: Float) -> AdjustmentProtocol? {
        let relatedAdjustment = adjustments.first(where: { $0.parameters.contains(where: { $0.type == parameterType }) })
        
        guard let adjustment = relatedAdjustment else {
            assertionFailure("Unknown adjustment")
            return nil
        }
        
        let relatedParameter = adjustment.parameters.first(where: { $0.type == parameterType })
        
        guard let parameter = relatedParameter else {
            assertionFailure("Unknown adjustment parameter")
            return nil
        }
        
        parameter.set(value: value)
        
        //because we're applying the adjustment on a sourceImage
        guard parameter.currentValue != parameter.defaultValue else {
            return nil
        }
        
        return adjustment
    }
    
    
    func applyOnValueDidChange(adjustmentValues: [AdjustmentValue], sourceImage: UIImage, onFinished: @escaping ValueHandler<UIImage>) {
        
        operationQueue.cancelAllOperations()
        
        AdjustmentOperation.sourceImage = sourceImage
        
        var relatedAdjustments = [AdjustmentProtocol]()
        adjustmentValues.forEach { adjValue in
            let adjustment = updateValues(parameterType: adjValue.type, value: adjValue.value)
            relatedAdjustments.append(adjustment)
        }
        
        let operations: [AdjustmentOperation] = relatedAdjustments.map { adjustment in

            let operation = AdjustmentOperation(adjustment: adjustment) { [weak self] output in
                guard let self = self else {
                    return
                }
                
                AdjustmentOperation.sourceImage = output
                
                let unfinishedOperations = self.operationQueue.operations.filter { $0.isReady || $0.isExecuting }
                let operationQueueIsEmpty = self.operationQueue.operations.isEmpty || unfinishedOperations.count <= 1
                
                if operationQueueIsEmpty {
                    onFinished(output)
                }
            }
            return operation
        }
    
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
}

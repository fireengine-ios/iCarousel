//
//  ThirdPartyAdjustment.swift
//  Depo
//
//  Created by Konstantin Studilin on 28.07.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import GPUImage

protocol ThirdPartyAdjustmentProtocol {
    func applyOn(image: UIImage, onFinished: @escaping ValueHandler<UIImage>)
}

final class CoreImageAdjustment: ThirdPartyAdjustmentProtocol {
    
    private var filter: BasicFilter?
    
    init(filter: BasicFilter) {
        self.filter = filter
    }
    
    func applyOn(image: UIImage, onFinished: @escaping ValueHandler<UIImage>) {
        guard let inputImage = CIImage(image: image) else {
            onFinished(image)
            return
        }
        
        filter?.inputImage = inputImage
        
        guard let adjustedImage = filter?.outputImage else {
            onFinished(image)
            return
        }
        
        guard let cgImage = convertCIImageToCGImage(inputImage: adjustedImage) else {
            onFinished(image)
            return
        }
        
        let output = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        onFinished(output)
    }
    
    private func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        
        return context.createCGImage(inputImage, from: inputImage.extent)
    
    }
}


final class GPUAdjustment: ThirdPartyAdjustmentProtocol {
    
    private let operation: BasicOperation
    private let pictureOutput = PictureOutput()
    
    
    init(operation: BasicOperation) {
        self.operation = operation
        
        //link the operation output to the pictureOutput
        operation --> pictureOutput
    }
    
    
    func applyOn(image: UIImage, onFinished: @escaping ValueHandler<UIImage>) {
        let input = PictureInput(image: image)
        
        pictureOutput.imageAvailableCallback = onFinished
        
        //remove previous input
        operation.removeSourceAtIndex(0)
        
        input --> operation
        input.processImage(synchronously: false)
    }
}

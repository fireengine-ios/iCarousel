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


final class GPUAdjustment: ThirdPartyAdjustmentProtocol {
    
    private let operation: BasicOperation
    private let pictureOutput = PictureOutput()
    
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    
    init(operation: BasicOperation) {
        self.operation = operation
        
        //link the operation output to the pictureOutput
        operation --> pictureOutput
    }
    
    
    func applyOn(image: UIImage, onFinished: @escaping ValueHandler<UIImage>) {
        operationQueue.addOperation { [weak self] in
            guard let self = self else {
                onFinished(image)
                return
            }
            let input = PictureInput(image: image)
            
            self.pictureOutput.imageAvailableCallback = onFinished
            
            //remove previous input
            self.operation.removeSourceAtIndex(0)
            
            input --> self.operation
            input.processImage(synchronously: true)
        }
    }
}

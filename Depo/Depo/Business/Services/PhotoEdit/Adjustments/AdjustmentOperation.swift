//
//  AdjustmentOperation.swift
//  Depo
//
//  Created by Konstantin Studilin on 04.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

final class AdjustmentOperation: Operation {
    
    private let sourceImage: UIImage
    private var outputImage: UIImage
    
    private var adjustments = [AdjustmentProtocol]()
    private let completion: ValueHandler<UIImage>
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    
    init(image: UIImage, adjustments: [AdjustmentProtocol], completion: @escaping ValueHandler<UIImage>) {
        self.sourceImage = image
        self.outputImage = image
        self.adjustments = adjustments
        self.completion = completion
    }
    
    
    override func cancel() {
        super.cancel()
        
        semaphore.signal()
    }
    
    override func main() {
        applyNextAdjustment()
        
        semaphore.wait()
        
        completion(outputImage)
    }
    
    private func applyNextAdjustment() {
        guard !isCancelled else {
            outputImage = sourceImage
            semaphore.signal()
            return
        }
        
        guard !adjustments.isEmpty else {
            self.semaphore.signal()
            return
        }
        
        let adjustment = adjustments.removeFirst()
        
        adjustment.applyOn(image: outputImage) { [weak self] output in
            guard let self = self else {
                return
            }
            
            self.outputImage = output
            self.applyNextAdjustment()
        }
    }
    
}

//
//  AdjustmentOperation.swift
//  Depo
//
//  Created by Konstantin Studilin on 04.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

final class AdjustmentOperation: Operation {
    
    static var sourceImage: UIImage?
    
    var adjustmentType: AdjustmentType {
        return adjustment.type
    }
    
    private let adjustment: AdjustmentProtocol!
    private let completion: ValueHandler<UIImage>
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    
    init(adjustment: AdjustmentProtocol, completion: @escaping ValueHandler<UIImage>) {
        self.adjustment = adjustment
        self.completion = completion
    }
    
    override func cancel() {
        super.cancel()
        
        semaphore.signal()
    }
    
    
    override func main() {
        guard let image = AdjustmentOperation.sourceImage else {
            return
        }
        
        adjustment.applyOn(image: image) { [weak self] outputImage in
            guard let self = self else {
                return
            }
            
            guard !self.isCancelled else {
                self.semaphore.signal()
                return
            }
    
            self.completion(outputImage)
            self.semaphore.signal()
        }
        
        semaphore.wait()
    }
    
}

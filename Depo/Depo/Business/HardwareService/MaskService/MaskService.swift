//
//  MaskService.swift
//  Depo
//
//  Created by Oleg on 29.05.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class MaskService {
    
    static let shared = MaskService()
    
    let queue = OperationQueue()
    
    init() {
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
    }
    
    func generateImageWithMask(image: UIImage, sucess: @escaping (UIImage?) -> Void){
        let operation = MaskServiceOperation(image: image, sucessBlock: sucess)
        queue.addOperation(operation)
        //queue.waitUntilAllOperationsAreFinished()
    }

}

class MaskServiceOperation: Operation {
    
    let image: UIImage
    let sucessBlock: (UIImage?) -> Void
    
    init(image: UIImage, sucessBlock: @escaping (UIImage?) -> Void) {
        self.image = image
        self.sucessBlock = sucessBlock
        super.init()
    }
    
    override func main() {
        let filtredImage = image.grayScaleImage?.mask(with: ColorConstants.oldieFilterColor)
        sucessBlock(filtredImage)
    }
    
    override func cancel() {
        super.cancel()
    }
    
}



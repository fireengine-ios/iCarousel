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
        queue.qualityOfService = .userInteractive
    }
    
    func generateImageWithMask(image: UIImage, sucess: (UIImage) -> Void){
        
    }

}

class MaskServiceOperation: Operation {
    
    let image: UIImage
    let sucessBlock: (UIImage) -> Void
    
    init(image: UIImage, sucessBlock: ()) {
        self.image = image
        super.init()
    }
    
    override func main() {
        let filtresdImage = image.grayScaleImage?.mask(with: ColorConstants.oldieFilterColor)
    }
    
    override func cancel() {
        super.cancel()
    }
    
}



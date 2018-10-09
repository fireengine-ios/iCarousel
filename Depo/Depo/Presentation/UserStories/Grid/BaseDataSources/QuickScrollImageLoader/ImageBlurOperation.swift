//
//  ImageBlurOperation.swift
//  Depo
//
//  Created by Konstantin on 10/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


final class ImageBlurOperation: Operation, DataTransferrableOperation {
    
    var inputData: AnyObject?
    private (set) var outputData: AnyObject?
    

    override func main() {
        guard !isCancelled, let inputImage = inputData as? UIImage else {
            return
        }
        
        outputData = blurEffect(image: inputImage)
    }
    
    
    private func blurEffect(image: UIImage) -> UIImage? {
        
        guard let gaussianFilter = CIFilter(name: "CIGaussianBlur"),
            let cropFilter = CIFilter(name: "CICrop"),
            let inputImage = CIImage(image: image),
            !isCancelled
        else {
            return nil
        }
        
        gaussianFilter.setValue(1, forKey: kCIInputRadiusKey)
        gaussianFilter.setValue(inputImage, forKey: kCIInputImageKey)
        
        guard !isCancelled, let gaussianImage = gaussianFilter.outputImage else {
            return nil
        }
  
        cropFilter.setValue(gaussianImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: inputImage.extent), forKey: "inputRectangle")
        
        
        guard !isCancelled, let croppedImage = cropFilter.outputImage else {
            return nil
        }
        
        return UIImage(ciImage: croppedImage)
        

        ///TODO: check what is wrong, I had crashes on context.createCGImage
        ///the algorithm above works without crashes so far
        
//        EAGLContext.setCurrent(nil)
//        ///https://stackoverflow.com/questions/27632618/cicontext-bad-access-crash
//        ///to prevent createCGImage bad_access crash
//
//        let context = CIContext(options: nil)
//        currentFilter.setValue(inputImage, forKey: kCIInputImageKey)
//        currentFilter.setValue(1, forKey: kCIInputRadiusKey)
//
//        if isCancelled {
//            return nil
//        }
//
//        cropFilter.setValue(currentFilter.outputImage, forKey: kCIInputImageKey)
//        cropFilter.setValue(CIVector(cgRect: inputImage.extent), forKey: "inputRectangle")
//
//        guard !isCancelled, let output = cropFilter.outputImage else {
//            return nil
//        }
//
//        guard let cgImg = context.createCGImage(output, from: output.extent) else {
//            return nil
//        }
//
//        if isCancelled {
//            return nil
//        }
//
//        return UIImage(cgImage: cgImg)
    }
}

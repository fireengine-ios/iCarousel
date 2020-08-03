//
//  AdjustViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.07.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit


final class AdjustViewController: UIViewController, NibInit {
    
    static func with(image: UIImage) -> AdjustViewController {
        let controller = AdjustViewController.initFromNib()
        controller.image = image
        return controller
    }
    
    private var image: UIImage!
    
    
    @IBOutlet private weak var cropViewContainer: UIView!
    
    @IBOutlet private weak var slider: UISlider! {
        willSet {
            newValue.isContinuous = true
            newValue.minimumValue = -90
            newValue.maximumValue = 90
            newValue.value = 0
        }
    }
    
    private lazy var cropView: TOCropView = {
        let crop = TOCropView(croppingStyle: .default, image: image!)
        crop.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        crop.alwaysShowCroppingGrid = true
        return crop
    }()
    
    private var previousRotationTime = Date()
    private var threshold: TimeInterval = 0.1
    
    private var isFirstSetupDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cropView.frame = cropViewContainer.bounds
        cropViewContainer.addSubview(cropView)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cropView.frame = cropViewContainer.bounds
        cropView.moveCroppedContentToCenter(animated: false)
        
        if !isFirstSetupDone {
            isFirstSetupDone = true
            cropView.performInitialSetup()
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if navigationController == nil {
            cropView.setBackgroundImageViewHidden(true, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cropView.simpleRenderMode = false
        if cropView.gridOverlayHidden {
            cropView.setGridOverlayHidden(false, animated: animated)
        }
        if navigationController == nil {
            cropView.setBackgroundImageViewHidden(false, animated: animated)
        }
    }
    
    private func rotate(angle: Float) {
        guard let degrees = Double(angle).toInt() else {
            return
        }
        
        cropView.angle = degrees
    }

    @IBAction func onValueChnage(_ sender: Any) {
        let currentTime = Date()
        
        guard currentTime.timeIntervalSince(previousRotationTime) > threshold else {
            return
        }
        
        previousRotationTime = currentTime
        rotate(angle: slider.value)
    }
}

extension UIImage {
    func rotate(degrees: Float) -> UIImage? {
        let radians = CGFloat(degrees) * .pi / 180
        
        let rotation = CGAffineTransform(rotationAngle: radians)
        var newSize = CGRect(origin: CGPoint.zero, size: size).applying(rotation).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, !hasAlpha, scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return self
        }

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}


extension UIImage {
    
    var hasAlpha: Bool {
        guard let alphaInfo = self.cgImage?.alphaInfo else {
            return false
        }
        
        return alphaInfo.isContained(in: [.first, .last, .premultipliedFirst, .premultipliedLast])
    }
    
    
    func cropped(frame: CGRect, angle: Int) -> UIImage {
        let radians = CGFloat(angle) * .pi / 180.0
        
        UIGraphicsBeginImageContextWithOptions(frame.size, !hasAlpha, scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return self
        }
        
        if angle != 0 {
            let imageView = UIImageView(image: self)
            imageView.layer.minificationFilter = kCAFilterNearest
            imageView.layer.magnificationFilter = kCAFilterNearest
            imageView.transform = CGAffineTransform(rotationAngle: radians)
            let rotationRect = imageView.bounds.applying(imageView.transform)
            let container = UIView(frame: CGRect(origin: .zero, size: rotationRect.size))
            container.addSubview(imageView)
            imageView.center = container.center
            context.translateBy(x: -frame.origin.x, y: -frame.origin.y)
            container.layer.render(in: context)
        } else {
            context.translateBy(x: -frame.origin.x, y: -frame.origin.y)
            draw(at: .zero)
        }
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        guard let croppedCGImage = croppedImage?.cgImage else {
            return self
        }
        
        return UIImage(cgImage: croppedCGImage, scale: scale, orientation: .up)
    }
    
//    - (BOOL)hasAlpha
//    {
//        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
//        return (alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaLast ||
//                alphaInfo == kCGImageAlphaPremultipliedFirst || alphaInfo == kCGImageAlphaPremultipliedLast);
//    }
//
//    - (UIImage *)croppedImageWithFrame:(CGRect)frame angle:(NSInteger)angle circularClip:(BOOL)circular
//    {
//        UIImage *croppedImage = nil;
//        UIGraphicsBeginImageContextWithOptions(frame.size, ![self hasAlpha] && !circular, self.scale);
//        {
//            CGContextRef context = UIGraphicsGetCurrentContext();
//
//            if (circular) {
//                CGContextAddEllipseInRect(context, (CGRect){CGPointZero, frame.size});
//                CGContextClip(context);
//            }
//
//            //To conserve memory in not needing to completely re-render the image re-rotated,
//            //map the image to a view and then use Core Animation to manipulate its rotation
//            if (angle != 0) {
//                UIImageView *imageView = [[UIImageView alloc] initWithImage:self];
//                imageView.layer.minificationFilter = kCAFilterNearest;
//                imageView.layer.magnificationFilter = kCAFilterNearest;
//                imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle * (M_PI/180.0f));
//                CGRect rotatedRect = CGRectApplyAffineTransform(imageView.bounds, imageView.transform);
//                UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, rotatedRect.size}];
//                [containerView addSubview:imageView];
//                imageView.center = containerView.center;
//                CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
//                [containerView.layer renderInContext:context];
//            }
//            else {
//                CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
//                [self drawAtPoint:CGPointZero];
//            }
//
//            croppedImage = UIGraphicsGetImageFromCurrentImageContext();
//        }
//        UIGraphicsEndImageContext();
//
//        return [UIImage imageWithCGImage:croppedImage.CGImage scale: self.scale orientation:UIImageOrientationUp];
//    }
}

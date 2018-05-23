//
//  ImageScrollView.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class ImageScrollView: UIScrollView {
    
    private(set) var imageView = LoadingImageView()
    
    var image: UIImage? {
        didSet {
            /// clear current values
            imageView.image = nil
            imageView.frame = .zero
            contentSize = .zero
            maximumZoomScale = 1
            minimumZoomScale = 1
            zoomScale = 1
            
            guard let image = image else {
                return
            }
            
            /// setup new ones
            imageView.image = image
            imageView.frame.origin = .zero
            imageView.frame.size = image.size
            contentSize = image.size
        }
    }
    
    private let maxScaleFromMinScale: CGFloat = 5.0
    private let multiplyScrollGuardFactor: CGFloat = 0.999
    private let zoomFactorFromMinWhenDoubleTap: CGFloat = 2
    
    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureRecognizer))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        decelerationRate = UIScrollViewDecelerationRateFast
        
        
        imageView.frame = bounds
//        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        imageView.isUserInteractionEnabled = true
        addSubview(imageView)
        imageView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc private func doubleTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // zoom out if it bigger than middle scale point. Else, zoom in
        if zoomScale > minimumZoomScale {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            let center = gestureRecognizer.location(in: gestureRecognizer.view)
            let zoomRect = zoomRectForScale(zoomFactorFromMinWhenDoubleTap * minimumZoomScale, center: center)
            zoom(to: zoomRect, animated: true)
        }
    }
    
    fileprivate func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        
        zoomRect.size.height = frame.height / scale
        zoomRect.size.width = frame.width / scale
        
        zoomRect.origin.x = center.x - (zoomRect.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.height / 2.0)
        
        return zoomRect
    }
    
    func updateZoom() {
        guard let image = image else {
            return
        }
        setMaxMinZoomScales(for: image.size)
    }
     
    private func setMaxMinZoomScales(for imageSize: CGSize) {
        let xScale = bounds.width / imageSize.width
        let yScale = bounds.height / imageSize.height
        
        var minScale = min(xScale, yScale)
        let maxScale = maxScaleFromMinScale * minScale
        
        /// don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if minScale > maxScale {
            minScale = maxScale
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale * multiplyScrollGuardFactor
        zoomScale = minimumZoomScale
    }
    
    func adjustFrameToCenter() {
        var frameToCenter = imageView.frame
        
        /// center horizontally
        if frameToCenter.width < bounds.width {
            frameToCenter.origin.x = (bounds.width - frameToCenter.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        /// center vertically
        if frameToCenter.height < bounds.height {
            frameToCenter.origin.y = (bounds.height - frameToCenter.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
}

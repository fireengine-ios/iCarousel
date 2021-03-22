//
//  ImageScrollView.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol ImageScrollViewDelegate: class {
    func imageViewFinishedLoading(hasData: Bool)
    func onImageLoaded(image: UIImage?)
}

final class ImageScrollView: UIScrollView {
    
    private(set) var imageView = LoadingImageView()
    weak var imageViewDelegate: ImageScrollViewDelegate?
    
    //set minimum image size to be able to display activity indicator that is attached to image
    private let minimumImageSize = CGSize(width: 40, height: 40)
    
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
        delegate = self
        
        imageView.frame = bounds
//        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        imageView.isUserInteractionEnabled = true
        addSubview(imageView)
        imageView.addGestureRecognizer(doubleTapGesture)
        imageView.loadingImageViewDelegate = self
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
    
    private func setupFrame(for image:UIImage?) {
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        
        let size = image?.size ?? minimumImageSize
        imageView.frame = CGRect(origin: CGPoint.zero, size: size)
        contentSize = size
    }
    
    func updateZoom() {
        guard let image = imageView.currentFrameImage else {
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

extension ImageScrollView: LoadingImageViewDelegate {
    func loadingFinished(hasData: Bool) {
        imageViewDelegate?.imageViewFinishedLoading(hasData: hasData)
    }
    
    func onImageLoaded(image: UIImage?) {
        setupFrame(for: image)
        updateZoom()
        imageViewDelegate?.onImageLoaded(image: image)
    }
}

extension ImageScrollView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustFrameToCenter()
    }
}

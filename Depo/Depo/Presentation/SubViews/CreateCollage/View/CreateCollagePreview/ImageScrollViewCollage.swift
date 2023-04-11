//
//  ImageScrollViewCollage.swift
//  Lifebox
//
//  Created by Ozan Salman on 12.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

final class ImageScrollViewCollage: UIScrollView {
    
    private(set) var imageView = LoadingImageView()
    weak var imageViewDelegate: ImageScrollViewDelegate?
    
    //set minimum image size to be able to display activity indicator that is attached to image
    private let minimumImageSize = CGSize(width: 40, height: 40)
    
    private let maxScaleFromMinScale: CGFloat = 5.0
    private let multiplyScrollGuardFactor: CGFloat = 0.999
    private let zoomFactorFromMinWhenDoubleTap: CGFloat = 2
    
    var imageViewTag: Int = -1
    
    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureRecognizer))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()
    
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognizer))
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
    
    func getImageViewMaxY() -> CGFloat {
        return imageView.frame.maxY
    }
    
    private func setup() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        decelerationRate = .fast
        delegate = self
        
        imageView.frame = bounds
        imageView.isUserInteractionEnabled = true
        addSubview(imageView)
        imageView.addGestureRecognizer(doubleTapGesture)
        imageView.addGestureRecognizer(longPressGesture)
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
    
    @objc private func longPressGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let imageViewTags:[String: Int] = ["tag": imageViewTag]
            NotificationCenter.default.post(name: Notification.Name("ImageViewCollageLongPress"), object: nil, userInfo: imageViewTags)
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
        maximumZoomScale = 5
        minimumZoomScale = 1
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

extension ImageScrollViewCollage: LoadingImageViewDelegate {
    func loadingFinished() {
        imageViewDelegate?.imageViewFinishedLoading()
    }
    
    func onImageLoaded(image: UIImage?) {
        //setupFrame(for: image)
        updateZoom()
        imageViewDelegate?.onImageLoaded(image: image)
    }
}

extension ImageScrollViewCollage: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func ImageScrollViewCollage(_ scrollView: UIScrollView) {
        adjustFrameToCenter()
    }
}

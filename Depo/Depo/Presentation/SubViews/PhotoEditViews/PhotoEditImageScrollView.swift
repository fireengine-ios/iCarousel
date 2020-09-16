//
//  PhotoEditImageScrollView.swift
//  Depo
//
//  Created by Andrei Novikau on 9/4/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PhotoEditImageScrollView: UIScrollView {

    let imageView = UIImageView()
    
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
    
    func setup() {
        maximumZoomScale = 5
        delegate = self
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.pinToSuperviewEdges()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureRecognizer))
        gesture.numberOfTapsRequired = 2
        
        imageView.addGestureRecognizer(doubleTapGesture)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
    }
    
    @objc private func doubleTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if zoomScale > minimumZoomScale {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            let center = gestureRecognizer.location(in: gestureRecognizer.view)
            let zoomRect = zoomRectForScale(zoomFactorFromMinWhenDoubleTap * minimumZoomScale, center: center)
            zoom(to: zoomRect, animated: true)
        }
    }
    
    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        
        zoomRect.size.height = frame.height / scale
        zoomRect.size.width = frame.width / scale
        
        zoomRect.origin.x = center.x - (zoomRect.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.height / 2.0)
        
        return zoomRect
    }
}

//MARK: - UIScrollViewDelegate

extension PhotoEditImageScrollView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

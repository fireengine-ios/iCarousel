//
//  PVViewerController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PVViewerController: UIViewController, NibInit {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    private var imageView = UIImageView()
    
    private let maxScaleFromMinScale: CGFloat = 5.0
    private let multiplyScrollGuardFactor: CGFloat = 0.999
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = UIColor.black
        
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.addSubview(imageView)
        
        imageView.isUserInteractionEnabled = true
        
        imageView.image = image
        imageView.frame.size = image.size
        scrollView.contentSize = image.size
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blackNavigationBarStyle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setMaxMinZoomScales(for: image.size)
    }

    fileprivate func setMaxMinZoomScales(for imageSize: CGSize) {
        let xScale = scrollView.bounds.width / imageSize.width
        let yScale = scrollView.bounds.height / imageSize.height
        
        // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
        let imagePortrait = imageSize.height > imageSize.width
        let phonePortrait = scrollView.bounds.height >= scrollView.bounds.width
        
        var minScale = (imagePortrait == phonePortrait) ? xScale : min(xScale, yScale)
        let maxScale = maxScaleFromMinScale * minScale
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if minScale > maxScale {
            minScale = maxScale
        }
        
        scrollView.maximumZoomScale = maxScale
        scrollView.minimumZoomScale = minScale * multiplyScrollGuardFactor
        scrollView.zoomScale = scrollView.minimumZoomScale
    }
    
    public func adjustFrameToCenter() {
        var frameToCenter = imageView.frame
        
        // center horizontally
        if frameToCenter.size.width < scrollView.bounds.width {
            frameToCenter.origin.x = (scrollView.bounds.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        // center vertically
        if frameToCenter.size.height < scrollView.bounds.height {
            frameToCenter.origin.y = (scrollView.bounds.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
}

extension PVViewerController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustFrameToCenter()
    }
}


//final class ImageScrollView: UIScrollView {
//    private var imageView: UIImageView!
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setup()
//    }
//
//    private func setup() {
//
//    }
//}
//
//extension ImageScrollView: UIScrollViewDelegate {
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return imageView
//    }
//
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        //        adjustFrameToCenter()
//    }
//}

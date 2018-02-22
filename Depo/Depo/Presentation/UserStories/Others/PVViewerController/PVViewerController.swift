//
//  PVViewerController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PVViewerController: BaseViewController, NibInit {
    
    @IBOutlet private weak var imageScrollView: ImageScrollView!
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OrientationManager.shared.lock(for: .all, rotateTo: .unknown)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = UIColor.black
        view.addGestureRecognizer(tapGesture)
        
        imageScrollView.delegate = self
        imageScrollView.image = image
        
        if #available(iOS 11.0, *) {
            imageScrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blackNavigationBarStyle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageScrollView.updateZoom()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// set previous state of orientation or any new one
        OrientationManager.shared.lock(for: .portrait, rotateTo: .portrait)
    }
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(actionTapGesture))
        gesture.require(toFail: imageScrollView.doubleTapGesture)
        //gesture.delegate = self
        return gesture
    }()
    
    @objc private func actionTapGesture(_ gesture: UITapGestureRecognizer) {
        isFullScreen = !isFullScreen 
    }
    
    private var isFullScreen = false {
        didSet {
            Device.setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
            navigationController?.navigationBar.isHidden = isFullScreen
        }
    } 
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        Device.setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
    }
}

extension PVViewerController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageScrollView.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageScrollView.adjustFrameToCenter()
    }
}

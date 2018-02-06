//
//  PVViewerController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PVViewerController: UIViewController, NibInit {
    
    @IBOutlet private weak var imageScrollView: ImageScrollView!
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OrientationManager.shared.lock(for: .all, rotateTo: .unknown)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = UIColor.black
        
        imageScrollView.delegate = self
        imageScrollView.image = image
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
}

extension PVViewerController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageScrollView.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageScrollView.adjustFrameToCenter()
    }
}

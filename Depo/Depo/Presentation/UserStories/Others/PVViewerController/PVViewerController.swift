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
        view.addGestureRecognizer(fullscreenTapGesture)
        
        imageScrollView.imageView.originalImage = image
        
        if #available(iOS 11.0, *) {
            imageScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
         
        navigationItem.leftBarButtonItem = BackButtonItem { [weak self] in
            self?.hideView()
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
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .black
    }
    
    override func getBackgroundColor() -> UIColor {
        return UIColor.black
    }

    private lazy var fullscreenTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(actionFullscreenTapGesture))
        gesture.require(toFail: imageScrollView.doubleTapGesture)
        return gesture
    }()
    
    @objc private func actionFullscreenTapGesture(_ gesture: UITapGestureRecognizer) {
        isFullScreen = !isFullScreen 
    }
    
    private func hideView() {
        OrientationManager.shared.lock(for: .portrait, rotateTo: .portrait)
        dismiss(animated: true)
    }
    
    private var isFullScreen = false {
        didSet {
            navigationController?.setNavigationBarHidden(isFullScreen, animated: false)
            setStatusBarHiddenForLandscapeIfNeed(isFullScreen)            
        }
    } 
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
    }
}

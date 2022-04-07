//
//  PVViewerController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PVViewerController: BaseViewController, NibInit {
    
    static func with(item: Item) -> PVViewerController {
        let controller = PVViewerController.initFromNib()
        controller.item = item
        return controller
    }
    
    static func with(image: UIImage) -> UIViewController {
        let controller = PVViewerController.initFromNib()
        controller.image = image
        return controller
    }
    
    @IBOutlet private weak var imageScrollView: ImageScrollView!
    
    private var image: UIImage?
    private var item: Item?
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OrientationManager.shared.lock(for: .all, rotateTo: .unknown)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = UIColor.black
        view.addGestureRecognizer(fullscreenTapGesture)
        
        setupImageView()
        
        imageScrollView.contentInsetAdjustmentBehavior = .never
         
        navigationItem.leftBarButtonItem = BackButtonItem { [weak self] in
            self?.hideView()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageScrollView.updateZoom()
        imageScrollView.adjustFrameToCenter()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .black
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
    
    private func setupImageView() {
        if let image = image {
            imageScrollView.imageView.originalImage = image
        } else if let item = item {
            imageScrollView.imageView.loadImageIncludingGif(with: item)
        }
    }
}

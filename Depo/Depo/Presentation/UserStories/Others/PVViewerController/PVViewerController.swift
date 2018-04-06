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
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        cancelButton.setTitle(TextConstants.backTitle, for: .normal)
        cancelButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancelButton), for: .touchUpInside)
        let barButtonLeft = UIBarButtonItem(customView: cancelButton)
        navigationItem.leftBarButtonItem = barButtonLeft
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blackNavigationBarStyle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageScrollView.updateZoom()
    }
    
    override func getBacgroundColor() -> UIColor {
        return UIColor.black
    }

    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(actionTapGesture))
        gesture.require(toFail: imageScrollView.doubleTapGesture)
        return gesture
    }()
    
    @objc private func actionTapGesture(_ gesture: UITapGestureRecognizer) {
        isFullScreen = !isFullScreen 
    }
    
    @objc private func onCancelButton() {
        hideView()
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

extension PVViewerController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageScrollView.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageScrollView.adjustFrameToCenter()
    }
}

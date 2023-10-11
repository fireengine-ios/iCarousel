//
//  BasePopUpController.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 9/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

///
///Base controller for pop ups. Need for animation
///
class BasePopUpController: UIViewController {

    var dismissCompletion: VoidHandler?

    func open(_ completion : VoidHandler? = nil)  {
        
        presentAsDrawer(config: { drawer in
            drawer.showsDrawerIndicator = false
            drawer.drawerPresentationController?.allowsDismissalWithPanGesture = false
            
        }, completion: completion)
    }
    
    func openWithBlur(_ completion : VoidHandler? = nil)  {
        
        presentAsDrawer(config: { drawer in
            drawer.drawerPresentationController?.allowsDismissalWithPanGesture = false
            drawer.drawerPresentationController?.allowsDismissalWithTapGesture = false
            drawer.showsDrawerIndicator = false
            drawer.drawerPresentationController?.allowsDismissalWithPanGesture = false
            drawer.drawerPresentationController?.dimmedViewStyle = .blurEffect(style: .dark)
        }, completion: completion)
    }

    ///isFinalStep is used for dismissCompletion performing
    ///set isFinalStep as false to skip dismissCompletion performing
    func close(isFinalStep: Bool = true, completion: VoidHandler? = nil) {
        dismiss(animated: true) { [weak self] in
            completion?()

            guard isFinalStep else {
                return
            }

            self?.dismissCompletion?()
        }
    }


    // TODO: Facelift, Remove all below code once all popups are re-designed for facelift.

    weak var contentView: UIView?
    private var isNeedToShow = true

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        openLegacy()
    }
    
    private func openLegacy() {
        guard isNeedToShow else {
            return
        }
        
        isNeedToShow = false
        
        view.alpha = 0
        contentView?.transform = NumericConstants.scaleTransform
        
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
            self.contentView?.transform = .identity
        }
    }
}

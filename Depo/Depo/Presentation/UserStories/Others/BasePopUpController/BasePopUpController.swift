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
    
    //MARK: Properties
    weak var contentView: UIView?
    private var isNeedToShow = true
    
    var dismissCompletion: VoidHandler?
    
    //MARK: Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        open()
    }
    
    //MARK: Utility Methods(private)
    private func open() {
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
    
    //MARK: Utility Methods(public)

    ///isFinalStep is used for dismissCompletion performing
    ///set isFinalStep as false to skip dismissCompletion performing
    func close(isFinalStep: Bool = true, completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.contentView?.transform = NumericConstants.scaleTransform
            
        }, completion: { _ in
            self.dismiss(animated: false) { [weak self] in
                completion?()
                
                guard isFinalStep else {
                    return
                }
                
                self?.dismissCompletion?()
            }
            
        })
    }
}

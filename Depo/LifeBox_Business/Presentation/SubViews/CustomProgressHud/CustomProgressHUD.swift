//
//  CustomProgressHUD.swift
//  Depo
//
//  Created by Aleksandr on 1/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

 import MBProgressHUD

class CustomProgressHUD {
    
    var currentHUD: MBProgressHUD?

    func showProgressSpinner(progress: Float) {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
        if currentHUD == nil {
            currentHUD = MBProgressHUD.showAdded(to: window, animated: true)
            currentHUD?.mode = .determinateHorizontalBar
            currentHUD?.label.text = TextConstants.localFilesBeingProcessed
        }
        
        currentHUD?.progress = progress
    }
    
    func hideProgressSpinner() {
        currentHUD?.hide(animated: true)
//        currentHUD = nil
    }
    
}

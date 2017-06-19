//
//  MessageService.swift
//  Depo
//
//  Created by Alexander Gurin on 6/16/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation


protocol CustomPopUpService {
    
    // TODO : refactor later !
    func showAlert(withText text: String)
    
}


class CustomPopUp: CustomPopUpService {
    
     func showAlert(withText text: String) {
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        guard let window = appDelegate.window else {
            return
        }
        let customAlert = CustomAlertView.init(frame: CGRect(x:0, y:0,
                                                             width: window!.frame.size.width,
                                                             height: window!.frame.size.height),
                                               withTitle: "ERROR", withMessage: text, with: ModalTypeError)
        (appDelegate as! AppDelegate).showCustomAlert(customAlert)
    }
    
}

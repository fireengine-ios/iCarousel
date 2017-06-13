//
//  SwitchButton.swift
//  Depo
//
//  Created by Oleg on 09.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SwitchButton: UIButton {
    
    var activeState: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(onButton), for: UIControlEvents.touchUpInside)
        self.setSwitchButtonState(switchButtonActive: self.activeState)
    }

    func setSwitchButtonState(switchButtonActive:Bool){
        self.activeState = switchButtonActive
        if (switchButtonActive){
            self.setImage(UIImage(named: "checkbox_active"), for: UIControlState.normal)
        }else{
            self.setImage(UIImage(named: "checkbox_normal"), for: UIControlState.normal)
        }
    }
    
    func onButton(){
        self.activeState = !self.activeState
        self .setSwitchButtonState(switchButtonActive: self.activeState)
    }

}

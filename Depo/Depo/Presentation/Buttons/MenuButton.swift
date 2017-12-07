//
//  MenuButton.swift
//  Depo
//
//  Created by Oleg on 11.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class MenuButton: CircleButton {

    override func configurate(){
        super.configurate()
        
        bottomTitleLabel?.textColor = UIColor.white
        
        tintColor = UIColor.white
        setTitleColor(UIColor.white, for: .normal)
        //TO DO fix it Oleg
        setTitleColor(ColorConstants.selectedBottomBarButtonColor, for: .selected)
    }
    
    override func getSpaceBetwinImageAndLabel() -> CGFloat{
        let space: CGFloat = 2
        return space
    }

}

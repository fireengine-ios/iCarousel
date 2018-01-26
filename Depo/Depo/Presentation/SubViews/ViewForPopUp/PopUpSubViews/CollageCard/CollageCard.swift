//
//  CollageCard.swift
//  Depo
//
//  Created by Oleg on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class CollageCard: BaseView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var imageView: LoadingImageView!
    @IBOutlet weak var bottomButton: UIButton!
    
    override func configurateView() {
        super.configurateView()
        
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
        titleLabel.textColor = ColorConstants.darkText
        titleLabel.text = TextConstants.homeCollageCardTitle
        
        subTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        subTitleLabel.textColor = ColorConstants.textGrayColor
        subTitleLabel.text = TextConstants.homeCollageCardSubTitle
        
        bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        bottomButton.setTitleColor(ColorConstants.blueColor, for: .normal)
        bottomButton.setTitle(TextConstants.homeCollageCardButtonSaveCollage, for: .normal)
        //bottomButton.setTitle(TextConstants.homeCollageCardButtonViewCollage, for: .normal)
        
    }
    
    @IBAction func onCloseButton(){
        
    }
    
    @IBAction func onBottomBar(){
        
    }

}

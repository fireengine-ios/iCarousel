//
//  AlbumCard.swift
//  Depo
//
//  Created by Oleg on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class AlbumCard: BaseView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var previewImageView: LoadingImageView!
    @IBOutlet weak var bottomButton: UIButton!

    override func configurateView() {
        super.configurateView()
        
        titleLabel.textColor = ColorConstants.darkText
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
        titleLabel.text = TextConstants.homeAlbumCardTitle
        
        subTitleLabel.textColor = ColorConstants.textGrayColor
        subTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        subTitleLabel.text = TextConstants.homeAlbumCardSubTitle
        
        descriptionLabel.textColor = ColorConstants.textGrayColor
        descriptionLabel.font = UIFont.TurkcellSaturaDemFont(size: 14)
        
        bottomButton.setTitleColor(ColorConstants.blueColor, for: .normal)
        bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        bottomButton.setTitle(TextConstants.homeAlbumCardBottomButtonSaveAlbum, for: .normal)
        //bottomButton.setTitle(TextConstants.homeAlbumCardBottomButtonViewAlbum, for: .normal)
    }
    
    @IBAction func onCloseButton(){
        
    }
    
    @IBAction func onBottomButton(){
        
    }
    
}

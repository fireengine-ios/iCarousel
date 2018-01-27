//
//  MovieCard.swift
//  Depo
//
//  Created by Oleg on 27.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class MovieCard: BaseView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var videoPreviewImageView: LoadingImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var bottomButton: UIButton!
    
    override func configurateView() {
        super.configurateView()
        
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
        titleLabel.textColor = ColorConstants.darkText
        titleLabel.text = TextConstants.homeMovieCardTitle
        
        subTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        subTitleLabel.textColor = ColorConstants.textGrayColor
        subTitleLabel.text = TextConstants.homeMovieCardSubTitle
        
        durationLabel.textColor = ColorConstants.whiteColor
        durationLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
        
        
        bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        bottomButton.setTitleColor(ColorConstants.blueColor, for: .normal)
        bottomButton.setTitle(TextConstants.homeMovieCardViewButton, for: .normal)
        //bottomButton.setTitle(TextConstants.homeMovieCardSaveButton, for: .normal)
    }
    
    @IBAction func onBottomButton(){
        
    }

}

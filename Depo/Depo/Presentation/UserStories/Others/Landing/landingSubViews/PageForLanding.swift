//
//  PageForLanding.swift
//  Depo
//
//  Created by Oleg on 04.05.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class PageForLanding: UIViewController {
    
    @IBOutlet weak var titleLabel : UILabel! {
        didSet {
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 31.5)
            titleLabel.textColor = ColorConstants.whiteColor
            titleLabel.text = "Welcome! Let’s get started!"
        }
    }
    
    @IBOutlet weak var subTitleLabel : UILabel! {
        didSet {
            subTitleLabel.font = UIFont.TurkcellSaturaItaFont(size: 15.4)
            subTitleLabel.textColor = ColorConstants.whiteColor
            subTitleLabel.text = "You can access everything about lifebox from home page. Start using your lifebox with our suggestions. You can swipe the cards that you don't like."
        }
    }
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var gradientView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func configurateForIndex(index: Int) {
        if index != 0 {
            gradientView.isHidden = true
            titleLabel.textColor = ColorConstants.blackForLanding
            subTitleLabel.textColor = ColorConstants.blackForLanding
            bgImage.contentMode = .scaleAspectFit
        } else {
            gradientView.isHidden = false
            bgImage.contentMode = .scaleAspectFill
        }
        
        titleLabel.text = getTitleForIndex(index: index)
        subTitleLabel.text = getSubTitleForIndex(index: index)
        
        let bgImageName = String(format: "LandingBG%d", index)
        bgImage.image = UIImage(named: bgImageName)
        
        let imageName = String(format: "LandingImage%d", index)
        imageView.image = UIImage(named: imageName)
    }
    
    private func getTitleForIndex(index: Int) -> String{
        switch index {
        case 0:
            return TextConstants.landingTitle0
        case 1:
            return TextConstants.landingTitle1
        case 2:
            return TextConstants.landingTitle2
        case 3:
            return TextConstants.landingTitle3
        case 4:
            return TextConstants.landingTitle4
        case 5:
            return TextConstants.landingTitle5
        case 6:
            return TextConstants.landingTitle6
        default:
            return ""
        }
    }
    
    private func getSubTitleForIndex(index: Int) -> String{
        switch index {
        case 0:
            return TextConstants.landingSubTitle0
        case 1:
            return TextConstants.landingSubTitle1
        case 2:
            return TextConstants.landingSubTitle2
        case 3:
            return TextConstants.landingSubTitle3
        case 4:
            return TextConstants.landingSubTitle4
        case 5:
            return TextConstants.landingSubTitle5
        case 6:
            return TextConstants.landingSubTitle6
        default:
            return ""
        }
    }

}

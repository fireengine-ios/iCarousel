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
        } else {
            gradientView.isHidden = false
        }
        
        let bgImageName = String(format: "LandingBG%d", index)
        bgImage.image = UIImage(named: bgImageName)
        
        let imageName = String(format: "LandingImage%d", index)
        imageView.image = UIImage(named: imageName)
    }

}

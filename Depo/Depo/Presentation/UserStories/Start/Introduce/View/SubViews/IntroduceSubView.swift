//
//  IntroduceSubView.swift
//  Depo
//
//  Created by Oleg on 12.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class IntroduceSubView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    class func initFromNib() -> IntroduceSubView{
        let nibName = String(describing: self)
        let nibs = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        guard let view = nibs?[0] else {
            return IntroduceSubView()
        }
        let introduceSubView = view as! IntroduceSubView
        introduceSubView.configurateView()
        return introduceSubView
    }

    func configurateView(){
        titleLabel.numberOfLines = 10
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 5)
        titleLabel.textColor = ColorConstants.whiteColor
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true;
    }

    func setModel(model: IntroduceModel){
        imageView.image = UIImage(named: model.imageName)
        titleLabel.attributedText = model.text
    }

}

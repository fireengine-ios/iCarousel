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
    var titleLabel = UILabel()
    
    class func initFromNib() -> IntroduceSubView {
        let nibName = String(describing: self)
        let nibs = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        guard let view = nibs?[0] else {
            return IntroduceSubView()
        }
        let introduceSubView = view as! IntroduceSubView
        introduceSubView.configurateView()
        return introduceSubView
    }

    func configurateView() {
        titleLabel.numberOfLines = 10
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 5)
        titleLabel.textColor = ColorConstants.whiteColor
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
    }

    func setModel(model: IntroduceModel) {
        imageView.image = UIImage(named: model.imageName)
        titleLabel.attributedText = model.text
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let image = imageView.image {
            let hImage = image.size.height
            let wImage = image.size.width
            let kImage = hImage / wImage
            
            let hView = imageView.frame.height
            let wView = imageView.frame.width
            let kView = hView / wView
            
            var hDispl: CGFloat = 0
            var wDispl: CGFloat = 0
            var dx: CGFloat = 0
            var dy: CGFloat = 0
            
            if kView >= kImage {
                wDispl = wView
                hDispl = wDispl * kImage
                dy = (hView - hDispl) * 0.5
            } else {
                hDispl = hView
                wDispl = hDispl / kImage
                dx = (wView - wDispl) * 0.5
            }
            
            //Numbers calculated for image that should be displayed
            let wLabel = wDispl / 1.24
            let hLabel = hDispl / 4.4
            let bottom = hDispl / 25.25
            
            let xPositionForLabel = dx + imageView.frame.origin.x + (wDispl - wLabel) * 0.5
            let yPositionForLabel = dy + imageView.frame.origin.y + (hDispl - hLabel - bottom)
            
            let rect = CGRect(x: xPositionForLabel, y: yPositionForLabel, width: wLabel, height: hLabel)
            titleLabel.frame = rect
            addSubview(titleLabel)
        }
    }

}

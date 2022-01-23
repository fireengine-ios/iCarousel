//
//  GraceBannerView.swift
//  Lifebox
//
//  Created by Burak Donat on 21.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

protocol GraceBannerViewDelegate: AnyObject {
    func closeButtonTapped()
}

class GraceBannerView: UICollectionReusableView {
    
    weak var delegate: GraceBannerViewDelegate?

    @IBOutlet weak private var bannerView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.lrButterScotch
        }
    }
    
    @IBOutlet weak var bannerMessageLabel: UILabel! {
        willSet {
            newValue.text = localized(.graceBannerText)
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
            newValue.textColor = UIColor.white
            newValue.numberOfLines = 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        delegate?.closeButtonTapped()
    }
    
    class func getHeight() -> CGFloat {
        return 122
    }
    
}

//
//  TitleView.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 1/12/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class TitleView: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    
    class func initFromXib() -> TitleView {
        let view = UINib(nibName: "TitleView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TitleView
        return view
    }
    
    func setTitle(_ title: String) {
        titleLabel?.isHidden = false
        titleLabel?.textAlignment = .center
        titleLabel?.backgroundColor = UIColor.clear
        titleLabel?.textColor = UIColor.white
        titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 19.0)
        titleLabel?.text = title
    }
    
    func setSubTitle(_ title: String) {
        subTitleLabel?.isHidden = false
        subTitleLabel?.textAlignment = .center
        subTitleLabel?.backgroundColor = UIColor.clear
        subTitleLabel?.textColor = UIColor.white
        subTitleLabel?.font = UIFont.TurkcellSaturaMedFont(size: 12.0)
        subTitleLabel?.text = title
    }

    #if MAIN_APP
    func updateColors(for style: NavigationBarStyle) {
        titleLabel.textColor = style.titleColor
        subTitleLabel.textColor = style.titleColor
    }
    #endif
}

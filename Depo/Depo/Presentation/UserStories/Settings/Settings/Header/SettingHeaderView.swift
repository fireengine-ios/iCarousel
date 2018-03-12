//
//  SettingHeaderView.swift
//  Depo
//
//  Created by Oleg on 07.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SettingHeaderView: UIView {

    class func viewFromNib() -> SettingHeaderView {
        return UINib(nibName: "SettingHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SettingHeaderView
    }

}

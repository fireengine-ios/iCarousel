//
//  HelpAndSupportHeaderView.swift
//  Depo
//
//  Created by Ryhor on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//


import UIKit

class HelpAndSupportHeaderView: UIView {
    
    class func viewFromNib()->HelpAndSupportHeaderView{
        return UINib(nibName: "HelpAndSupportHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HelpAndSupportHeaderView
    }
    
}

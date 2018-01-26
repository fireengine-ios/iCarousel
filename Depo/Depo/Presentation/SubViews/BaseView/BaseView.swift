//
//  BaseView.swift
//  Depo_LifeTech
//
//  Created by Oleg on 19.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BaseView: UIView, NibInit {
    
    @IBOutlet weak var whiteView: UIView?
    
    var canSwipe: Bool = true
    static let baseViewCornerRadius: CGFloat = 5
    var calculatedH: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configurateView()
    }
    
    func configurateView() {
        whiteView?.layer.cornerRadius = BaseView.baseViewCornerRadius
        calculatedH = frame.size.height
    }
    
    func viewDeletedBySwipe(){
        
    }
    
}

//
//  BaseView.swift
//  Depo_LifeTech
//
//  Created by Oleg on 19.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BaseView: UIView {
    
    @IBOutlet weak var whiteView: UIView?
    var canSwipe: Bool = true
    
    static let baseViewCornerRadius: CGFloat = 5
    
    class func initFromNib() -> BaseView{
        let nibName = String(describing: self)
        let nibs = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        guard let view = nibs?[0] else {
            return BaseView()
        }
        
        if let baseView = view as? BaseView{
            baseView.configurateView()
            return baseView
        }
        return BaseView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configurateView()
    }
    
    func configurateView(){
        if let wView = whiteView {
            wView.layer.cornerRadius = BaseView.baseViewCornerRadius
        }
    }
    
    func viewDeletedBySwipe(){
        
    }
    
}

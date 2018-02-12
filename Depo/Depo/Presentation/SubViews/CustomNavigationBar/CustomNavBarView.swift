//
//  CustomNavBar.swift
//  Depo
//
//  Created by Aleksandr on 6/22/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol CustomNavBarViewActionDelegate: class {
    func navBarButtonGotPressed(button: CustomNavBarButton)
    func navBarBackButtonPressed()
}

class CustomNavBarView: UIView, UISearchBarDelegate {
    
    static let nibName = "CustomNavBar"
    
    weak var actionDelegate: CustomNavBarViewActionDelegate?
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var hideLogo: Bool {
        set {
           logoImage.isHidden = newValue
        }
        get {
            return logoImage.isHidden
        }
    }
    
    class func getFromNib() -> CustomNavBarView? {
        let fakeNavBar = Bundle.main.loadNibNamed(CustomNavBarView.nibName,
                                                  owner: self,
                                                  options: nil)?.first
        
        let bar = fakeNavBar as? CustomNavBarView
        
        if #available(iOS 11.0, *) {
            bar?.bgImageView.isHidden = true
        }
        
        return fakeNavBar as? CustomNavBarView
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        actionDelegate?.navBarBackButtonPressed()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        return false
    }
}

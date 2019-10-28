//
//  CustomNavBar.swift
//  Depo
//
//  Created by Aleksandr on 6/22/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CustomNavBarView: UIView, UISearchBarDelegate {
    
    private var logoImage: UIImageView = {
        let newValue =  UIImageView()
        
        newValue.image = Device.isIpad ? UIImage(named: "group-2") : UIImage(named: "logo")
        newValue.contentMode = .scaleToFill

        return newValue
    }()
    
    private var bgImageView: UIImageView = {
        let newValue =  UIImageView()
        
        newValue.image = UIImage(named: "NavigationBarBackground")
        newValue.contentMode = .scaleToFill
        
        return newValue
    }()
    
    var hideLogo: Bool {
        set { logoImage.isHidden = newValue }
        get { return logoImage.isHidden }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override func removeFromSuperview() {
        ///overriding this method without calling super
        ///this helps to avoid bouncing of navigation
        ///it happens on push()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupFrames()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = []
        
        addSubview(bgImageView)
        addSubview(logoImage)
    }
    
    private func setupFrames() {

        bgImageView.frame = frame
        
        let logoImageY = (frame.height - FrameConstants.logoImageSizeIPad) + FrameConstants.logoBottomOffset
        if Device.isIpad {
            logoImage.center = center
            logoImage.frame.origin.y = logoImageY
            
            logoImage.frame.size = CGSize(width: FrameConstants.logoImageSizeIPad,
                                          height: FrameConstants.logoImageSizeIPad)
            
        } else {
            logoImage.frame.size = CGSize(width: FrameConstants.logoImageWidthIPhone,
                                          height: FrameConstants.logoImageSizeIPad)
            
            logoImage.frame.origin = CGPoint(x: FrameConstants.logoLeadingOffset,
                                             y: logoImageY)
            
        }

    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}

private enum FrameConstants {
    static var logoBottomOffset: CGFloat = 10

    static var logoLeadingOffset: CGFloat = 16

    static var logoImageSizeIPad: CGFloat = 54
    static var logoImageWidthIPhone: CGFloat = 126
}

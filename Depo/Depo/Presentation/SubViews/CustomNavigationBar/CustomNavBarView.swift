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
            #if LIFEDRIVE
///            There are no "true" design available right now.
            #else
            logoImage.center = center
            
            logoImage.frame.origin.y = logoImageY
            
            logoImage.frame.size = CGSize(width: FrameConstants.logoImageSizeIPad,
                                          height: FrameConstants.logoImageSizeIPad)
            #endif
        } else {
            logoImage.frame.origin = CGPoint(x: FrameConstants.logoLeadingOffset,
                                             y: logoImageY)
            
            #if LIFEDRIVE
            logoImage.frame.origin.y = logoImage.frame.origin.y - (FrameConstants.logoBottomOffset * 2)
            
            logoImage.frame.size = CGSize(width: FrameConstants.logoImageWidthIPhone,
                                          height: FrameConstants.logoImageSizeIPad)
            #else
            logoImage.frame.size = CGSize(width: FrameConstants.logoImageWidthIPhone,
                                          height: FrameConstants.logoImageSizeIPad)
            #endif
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}

private enum FrameConstants {
    static var logoBottomOffset: CGFloat = 10

    #if LIFEDRIVE
    static var logoLeadingOffset: CGFloat = 30

    static var logoImageSizeIPad: CGFloat = 24
    static var logoImageWidthIPhone: CGFloat = 60
    #else
    static var logoLeadingOffset: CGFloat = 16

    static var logoImageSizeIPad: CGFloat = 54
    static var logoImageWidthIPhone: CGFloat = 126
    #endif
}

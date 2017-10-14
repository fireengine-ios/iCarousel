//
//  SelectionImageView.swift
//  Depo
//
//  Created by Oleg on 31.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SelectionImageView: UIImageView {

    var selectionImageView: UIImageView! = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
    var cornerView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    
    var configured: Bool = false
    var isSelected: Bool = false
    var showSelectionBorder: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionImageView.center = CGPoint(x: 40, y: 6)
        
        cornerView.backgroundColor = UIColor.clear
        cornerView.layer.borderColor = ColorConstants.darcBlueColor.cgColor
        cornerView.layer.borderWidth = 2
        cornerView.alpha = 0
        addSubview(cornerView)
        bringSubview(toFront: selectionImageView)
        
    }
    
    func setSelection(selection: Bool, showSelectonBorder: Bool){
        isSelected = selection
        self.showSelectionBorder = showSelectonBorder
        if (!configured){
            selectionImageView.removeFromSuperview()
            self.cornerView.alpha = 0
            return
        }
        
        if (showSelectonBorder){
            UIView.animate(withDuration: NumericConstants.durationOfAnimation, animations: {
                self.cornerView.alpha = selection ? 1 : 0
            })
            addSubview(selectionImageView)
        }else{
            UIView.animate(withDuration: NumericConstants.durationOfAnimation, animations: {
                self.cornerView.alpha = 0
            })
            selectionImageView.removeFromSuperview()
        }
        
        if (selection){
            selectionImageView.image = UIImage(named: "selected")
        }else{
            selectionImageView.image = UIImage(named: "notSelected")
        }
    }
    
    func setImage(image: UIImage?){
        self.image = image
        setSelection(selection: isSelected, showSelectonBorder: showSelectionBorder)
    }

}

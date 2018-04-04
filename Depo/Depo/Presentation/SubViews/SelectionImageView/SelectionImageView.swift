//
//  SelectionImageView.swift
//  Depo
//
//  Created by Oleg on 31.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SelectionImageView: UIImageView {
    var cornerView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
    
    var configured: Bool = false
    var isSelected: Bool = false
    var showSelectionBorder: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cornerView.backgroundColor = UIColor.clear
        cornerView.layer.borderColor = ColorConstants.darcBlueColor.cgColor
        cornerView.layer.borderWidth = 2
        cornerView.alpha = 0
        addSubview(cornerView)
    }
    
    func setSelection(selection: Bool, showSelectonBorder: Bool) {
        isSelected = selection
        self.showSelectionBorder = showSelectonBorder
        if (!configured) {
            self.cornerView.alpha = 0
            return
        }
        
        if (showSelectonBorder) {
            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                self.cornerView.alpha = selection ? 1 : 0
            })
        } else {
            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                self.cornerView.alpha = 0
            })
        }
    }
    
    func setImage(image: UIImage?) {
        self.image = image
        setSelection(selection: isSelected, showSelectonBorder: showSelectionBorder)
    }

}

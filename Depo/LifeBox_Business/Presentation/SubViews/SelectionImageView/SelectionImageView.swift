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
        cornerView.layer.borderColor = ColorConstants.darkBlueColor.cgColor
        cornerView.layer.borderWidth = 2
        cornerView.alpha = 0
        addSubview(cornerView)
    }
    
    func setSelection(selection: Bool, showSelectonBorder: Bool) {
        isSelected = selection
        showSelectionBorder = showSelectonBorder
        
        guard configured else {
            cornerView.alpha = 0
            return
        }
        
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.cornerView.alpha = showSelectonBorder && selection ? 1 : 0
        })
    }
    
    func setImage(image: UIImage?) {
        self.image = image
        setSelection(selection: isSelected, showSelectonBorder: showSelectionBorder)
    }

}

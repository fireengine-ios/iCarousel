//
//  SelectionImageView.swift
//  Depo
//
//  Created by Oleg on 31.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SelectionImageView: UIImageView {
    var configured: Bool = false
    var isSelected: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setSelection(selection: Bool) {
        isSelected = selection
    }
    
    func setImage(image: UIImage?) {
        self.image = image
        setSelection(selection: isSelected)
    }
}

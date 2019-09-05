//
//  PhotoSelectionNoFilesView.swift
//  Depo
//
//  Created by User on 9/4/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class PhotoSelectionNoFilesView: UIView, NibInit {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.textColor = ColorConstants.textGrayColor
            label.font = UIFont.TurkcellSaturaRegFont(size: 14)
            label.text = TextConstants.thereAreNoPhotos
        }
    }
    
    var text:String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
            setNeedsLayout()
        }
    }
}

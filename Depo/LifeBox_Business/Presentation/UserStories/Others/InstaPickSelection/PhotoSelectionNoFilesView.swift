//
//  PhotoSelectionNoFilesView.swift
//  Depo
//
//  Created by Nikolay Zmachinsky on 9/4/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class PhotoSelectionNoFilesView: UIView, NibInit {
    
    @IBOutlet weak private var cameraImageView: UIImageView!
    @IBOutlet weak private var noPhotosLabel: UILabel! {
        didSet {
            noPhotosLabel.textColor = ColorConstants.textGrayColor
            noPhotosLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
            noPhotosLabel.text = TextConstants.thereAreNoPhotos
        }
    }
    
    var text:String? {
        get {
            return noPhotosLabel.text
        }
        set {
            noPhotosLabel.text = newValue
            setNeedsLayout()
        }
    }
}

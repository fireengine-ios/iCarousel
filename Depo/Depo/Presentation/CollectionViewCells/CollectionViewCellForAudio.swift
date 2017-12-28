//
//  CollectionViewCellForAudio.swift
//  Depo
//
//  Created by Oleg on 04.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CollectionViewCellForAudio: CollectionViewCellForPhoto {
    
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override class func getCellSise() -> CGSize {
        return CGSize(width: 90.0, height: 90.0)
    }
  
}

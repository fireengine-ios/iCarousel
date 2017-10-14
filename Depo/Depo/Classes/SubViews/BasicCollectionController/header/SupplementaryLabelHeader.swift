//
//  SupplementaryLabelHeader.swift
//  Depo
//
//  Created by Aleksandr on 6/28/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SupplementaryLabelHeader: UICollectionReusableView {
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    func setupTitle(withText titleText: String) {
        headerTitleLabel.font = UIFont.TurkcellSaturaBolFont(size: 17)

        headerTitleLabel.text = titleText
    }
}

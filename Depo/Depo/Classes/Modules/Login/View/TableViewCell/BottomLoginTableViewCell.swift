//
//  BottomLoginTableViewCell.swift
//  Depo
//
//  Created by Oleg on 09.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BottomLoginTableViewCell: UITableViewCell {

    class func initFromNib() -> BottomLoginTableViewCell{
        let nibName = String(describing: self)
        let nibs = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        guard let view = nibs?[0] else {
            return BottomLoginTableViewCell()
        }
        let bottomLoginTableViewCell = view as! BottomLoginTableViewCell
        return bottomLoginTableViewCell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

//
//  GridListTopBarSortingTableCell.swift
//  Depo
//
//  Created by Aleksandr on 9/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class GridListTopBarSortingTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var approveImage: UIImageView!
    
    func setup(withText text: String, selected: Bool) {
        
        titleLabel.text = text
        
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 19)
        titleLabel.textColor = ColorConstants.textGrayColor
        
        approveImage.isHidden = selected ? false : true
        
    }
    
    func changeState(selected: Bool) {
        approveImage.isHidden = selected ? false : true
    }
    
}

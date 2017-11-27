//
//  HelpAndSupportSectionTableViewCell.swift
//  Depo
//
//  Created by Ryhor on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class HelpAndSupportSectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sectionImageView: UIImageView!
    @IBOutlet weak var separator: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(item:FAQSectionItem){
        titleLabel.text = item.name
        if (item.selected){
            sectionImageView.image = UIImage(named: "mselected")
        }else{
            sectionImageView.image = UIImage(named: "pselected")
        }
        separator.isHidden = item.selected
    }
    
}

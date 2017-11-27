//
//  HelpAndSupportDescriptionTableViewCell.swift
//  Depo
//
//  Created by Ryhor on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class HelpAndSupportDescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // swift 4 
//        descriptionLabel.enabledTypes = [.mention, .url]
//        descriptionLabel.URLColor = UIColor.blue
//        descriptionLabel.handleURLTap { (url) in
//            URL.lb_openUrl(url: url)
//        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setTextForLabel(titleText: String, needShowSeparator:Bool){
        descriptionLabel?.text = titleText
//        separatorView.isHidden = !needShowSeparator
    }
    
}

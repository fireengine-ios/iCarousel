//
//  CollectionViewSimpleHeaderWithText.swift
//  Depo
//
//  Created by Oleg on 01.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CollectionViewSimpleHeaderWithText: UICollectionReusableView {

    @IBOutlet weak var labelForTitle: UILabel!
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var selectionView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configurateView(){
        labelForTitle.text = ""
        labelForTitle.font = UIFont.TurkcellSaturaDemFont(size: 16)
        labelForTitle.textColor = ColorConstants.textGrayColor
    }
    
    func setText(text: String?) {
        labelForTitle.text = text
    }
    
    func setSelectedState(selected: Bool, activateSelectionState: Bool){
        selectionImageView.isHidden = !activateSelectionState
        if (selected){
            selectionImageView.image = UIImage(named: "selected")
        }else{
            selectionImageView.image = UIImage(named: "notSelected")
        }
    }
    
}

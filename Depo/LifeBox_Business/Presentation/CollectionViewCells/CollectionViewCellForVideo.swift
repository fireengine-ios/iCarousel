//
//  CollectionViewCellForVideo.swift
//  Depo
//
//  Created by Oleg on 04.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CollectionViewCellForVideo: CollectionViewCellForPhoto {
    
    @IBOutlet weak var videoLengthLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        videoLengthLabel.textColor = ColorConstants.whiteColor.color
        videoLengthLabel.font = UIFont.GTAmericaStandardRegularFont(size: 16)
    }
    
    override func configureWithWrapper(wrappedObj: BaseDataSourceItem) {
        guard let wrapper = wrappedObj as? WrapData else {
            return
        }
        
        videoLengthLabel.text = wrapper.duration
        super.configureWithWrapper(wrappedObj: wrapper)
    }
    
}

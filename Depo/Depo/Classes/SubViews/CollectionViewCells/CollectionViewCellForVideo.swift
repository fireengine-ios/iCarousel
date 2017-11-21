//
//  CollectionViewCellForVideo.swift
//  Depo
//
//  Created by Oleg on 04.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CollectionViewCellForVideo: CollectionViewCellForPhoto {
    
    @IBOutlet weak var videoLengthLabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        videoLengthLabel.textColor = ColorConstants.whiteColor
        videoLengthLabel.font = UIFont.TurkcellSaturaRegFont(size: 19)
    }
    
    override func confireWithWrapperd(wrappedObj: BaseDataSourceItem) {
        guard let wrappered = wrappedObj as? WrapData else{
            return
        }
        
        videoLengthLabel.text = wrappered.duration
        super.confireWithWrapperd(wrappedObj: wrappered)
    }
    
    override func placeholderImage() -> UIImage? {
        return ActivityFileType.video.image 
    }
}

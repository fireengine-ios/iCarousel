//
//  FaceImageDesigner.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/13/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImageDesigner: NSObject {
    
    @IBOutlet private weak var faceImageAllowedLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.faceImageGrouping
        }
    }
    
    @IBOutlet private weak var facebookTagsAllowedLabel: UILabel! {
        willSet {
//            newValue.text = TextConstants.faceImageGrouping
        }
    }
    
    @IBOutlet private weak var firstFacebookLabel: UILabel! {
        willSet {
//            newValue.text = TextConstants.faceImageGrouping
        }
    }
    
    @IBOutlet private weak var secondFacebookLabel: UILabel! {
        willSet {
//            newValue.text = TextConstants.faceImageGrouping
        }
    }
    
    @IBOutlet private weak var facebookImportButton: UIButton! {
        willSet {
            
        }
    }
}

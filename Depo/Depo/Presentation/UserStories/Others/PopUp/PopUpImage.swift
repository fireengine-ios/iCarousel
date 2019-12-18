//
//  PopUpImage.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 12/13/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

enum PopUpImage {
    case error
    case success
    case delete
    case music
    case clock
    case unhide
    case none
    case custom(UIImage?)
    
    var image: UIImage? {
        let image: UIImage?
        switch self {
        case .error:
            image = UIImage(named: "customPopUpInfo")
        case .success:
            image = UIImage(named: "successImage")
        case .delete:
            image = UIImage(named: "deleteAlert")
        case .music:
            image = UIImage(named: "musicAlert")
        case .clock:
            image = UIImage(named: "clockAlert")
        case .unhide:
            image = UIImage(named: "unhideAlert")
        case .none:
            image = nil
        case .custom(let customImage):
            image = customImage
        }
        return image
    }
}

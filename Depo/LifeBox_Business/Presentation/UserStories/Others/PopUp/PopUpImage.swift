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
    case restore
    case question
    case quota
    case none
    case custom(UIImage?)
    
    var image: UIImage? {
        let image: UIImage?
        switch self {
        case .error:
            image = UIImage(named: "xmarkAlert")
        case .success:
            image = UIImage(named: "successImage")
        case .delete:
            image = UIImage(named: "confirmationPopupIcon")
        case .restore:
            image = UIImage(named: "restoreAlert")
        case .question:
            image = UIImage(named: "confirmationPopupIcon")
        case .quota:
            image = UIImage(named: "quotaAlert")
        case .none:
            image = nil
        case .custom(let customImage):
            image = customImage
        }
        return image
    }
}

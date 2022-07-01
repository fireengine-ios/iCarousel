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
    case hide
    case unhide
    case restore
    case question
    case none
    case custom(UIImage?)

    // TODO: Facelift, ask for other popup icons
    var image: UIImage? {
        let image: UIImage?
        switch self {
        case .error:
            image = Image.popupIconError.image
        case .success:
            image = UIImage(named: "successImage")
        case .delete:
            image = Image.popupIconDelete.image
        case .music:
            image = UIImage(named: "musicAlert")
        case .clock:
            image = UIImage(named: "clockAlert")
        case .hide:
            image = UIImage(named: "hideAlert")
        case .unhide:
            image = UIImage(named: "unhideAlert")
        case .restore:
            image = UIImage(named: "restoreAlert")
        case .question:
            image = Image.popupIconQuestion.image
        case .none:
            image = nil
        case .custom(let customImage):
            image = customImage
        }
        return image
    }
}

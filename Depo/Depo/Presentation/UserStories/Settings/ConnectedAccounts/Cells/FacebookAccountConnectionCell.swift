//
//  FacebookAccountConnectionCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class FacebookAccountConnectionCell: UITableViewCell {
    
    @IBOutlet private weak var caption: UILabel! {
        didSet {
            caption.text = TextConstants.facebook
        }
    }
    
    @IBOutlet private weak var icon: UIImageView! {
        didSet {
            icon.image = #imageLiteral(resourceName: "facebook")
        }
    }
    
    @IBOutlet private weak var customText: UILabel! {
        didSet {
            customText.text = TextConstants.importFromFB
        }
    }
    @IBOutlet private weak var connectionSwitch: UISwitch!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    
    @IBAction func connectionSwitchValueChanged(_ sender: Any) {
    }
}


// MARK: - ImportFromFBViewInput
//extension FacebookAccountConnectionCell: ImportFromFBViewInput {
//    
//    func failedFacebookStatus(errorMessage: String) {
//        isFBConnected = false
//        showErrorAlert(message: errorMessage)
//    }
//    
//    func succeedFacebookStart() {
//        MenloworksAppEvents.onFacebookConnected()
//        MenloworksEventsService.shared.onFacebookTransfered()
//        MenloworksTagsService.shared.facebookImport(isOn: true)
//        isFBConnected = true
//    }
//    
//    func failedFacebookStart(errorMessage: String) {
//        MenloworksTagsService.shared.facebookImport(isOn: false)
//        isFBConnected = false
//        showErrorAlert(message: errorMessage)
//    }
//    
//    func succeedFacebookStop() {
//        isFBConnected = false
//    }
//    
//    func failedFacebookStop(errorMessage: String) {
//        MenloworksAppEvents.onFacebookConnected()
//        isFBConnected = true
//        showErrorAlert(message: errorMessage)
//    }
//}

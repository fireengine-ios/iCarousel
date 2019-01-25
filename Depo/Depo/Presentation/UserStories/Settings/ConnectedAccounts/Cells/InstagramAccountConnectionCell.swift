//
//  InstagramAccountConnectionCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstagramAccountConnectionCell: UITableViewCell {
    
    
    @IBOutlet private weak var caption: UILabel!
    @IBOutlet private weak var instaPickIcon: UIImageView!
    @IBOutlet private weak var importFromInstagramIcon: UIImageView!
    @IBOutlet private weak var removeConnectionButton: UIButton! {
        didSet {
            removeConnectionButton.layer.borderWidth = 1.0
            removeConnectionButton.layer.borderColor = ColorConstants.textGrayColor.cgColor
            removeConnectionButton.layer.cornerRadius = removeConnectionButton.bounds.height * 0.4
            
        }
    }
    @IBOutlet private weak var instaPickSwitch: UISwitch!
    @IBOutlet private weak var importSwitch: UISwitch!
    @IBOutlet private weak var connectedAs: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func instaPickSwitchValueChanged(_ sender: Any) {
        
    }
    
    @IBAction func importSwitchValueChanged(_ sender: Any) {
        
    }
    
    @IBAction func removeConnection(_ sender: Any) {
        
    }
    
}

//extension InstagramAccountConnectionCell: ImportFromInstagramViewInput {
//    
//    // MARK: Status
//    
//    func instagramStatusSuccess() {
//        isInstagramConnected = true
//    }
//    
//    func instagramStatusFailure() {
//        isInstagramConnected = false
//    }
//    
//    // MARK: Start
//    
//    func instagramStartSuccess() {
//        MenloworksEventsService.shared.onInstagramTransfered()
//        MenloworksTagsService.shared.instagramImport(isOn: true)
//        isInstagramConnected = true
//    }
//    
//    func instagramStartFailure(errorMessage: String) {
//        MenloworksTagsService.shared.instagramImport(isOn: false)
//        isInstagramConnected = false
//        if errorMessage != TextConstants.NotLocalized.instagramLoginCanceled {
//            showErrorAlert(message: errorMessage)
//        }
//    }
//    
//    // MARK: Stop
//    
//    func instagramStopSuccess() {
//        isInstagramConnected = false
//    }
//    
//    func instagramStopFailure(errorMessage: String) {
//        isInstagramConnected = true
//        showErrorAlert(message: errorMessage)
//    }
//}

//
//  DropboxAccountConnectionCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

///TODO: setup outlets

final class DropboxAccountConnectionCell: UITableViewCell {
    
    @IBOutlet private weak var caption: UILabel!
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var customText: UILabel!
    @IBOutlet private weak var progress: UILabel! {
        didSet {
            progress.isHidden = true
        }
    }
    @IBOutlet private weak var rotatingImage: RotatingImageView! {
        didSet {
            rotatingImage.isHidden = true
        }
    }
    @IBOutlet private weak var connectButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func connectToDropbox(_ sender: Any) {
        //
    }
    
}


// MARK: - ImportFromDropboxViewInput
//extension DropboxAccountConnectionCell: ImportFromDropboxViewInput {
//    
//    func startDropboxStatus() {
//        dropboxButton.isEnabled = false
//        dropboxLoaderImageView.isHidden = false
//        dropboxLoaderImageView.startInfinityRotate360Degrees(duration: 2)
//        dropboxLoadingLabel.text = String(format: TextConstants.importFiles, String(0))
//    }
//    
//    func updateDropboxStatus(progressPercent: Int) {
//        dropboxLoadingLabel.text = String(format: TextConstants.importFiles, String(progressPercent))
//    }
//    
//    func stopDropboxStatus(lastUpdateMessage: String) {
//        dropboxButton.isEnabled = true
//        dropboxLoaderImageView.isHidden = true
//        dropboxLoaderImageView.stopInfinityRotate360Degrees()
//        dropboxLoadingLabel.text = lastUpdateMessage
//    }
//    
//    // MARK: Start
//    
//    /// nothing. maybe will be toast message
//    func dbStartSuccessCallback() {
//        MenloworksEventsService.shared.onDropboxTransfered()
//    }
//    
//    func failedDropboxStart(errorMessage: String) {
//        let isDropboxAuthorisationError = errorMessage.contains("invalid_access_token")
//        if isDropboxAuthorisationError {
//            showErrorAlert(message: TextConstants.dropboxAuthorisationError)
//        } else {
//            showErrorAlert(message: errorMessage)
//        }
//    }
//}

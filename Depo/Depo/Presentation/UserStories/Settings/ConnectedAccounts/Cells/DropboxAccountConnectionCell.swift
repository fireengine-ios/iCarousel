//
//  DropboxAccountConnectionCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit


final class DropboxAccountConnectionCell: UITableViewCell, SocialAccountConnectionCell {
    
    weak var delegate: SocialAccountConnectionCellDelegate?
    
    private var interactor: ImportFromDropboxInteractor!
    private var presenter: ImportFromDropboxPresenter!
    
    @IBOutlet private weak var caption: UILabel! {
        didSet {
            caption.text = TextConstants.dropbox
        }
    }
    
    @IBOutlet private weak var icon: UIImageView! {
        didSet {
            icon.contentMode = .center
            icon.image = #imageLiteral(resourceName: "dropox")
        }
    }
    
    @IBOutlet private weak var customText: UILabel! {
        didSet {
            customText.text = TextConstants.importFromDB
            customText.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var progress: UILabel! {
        didSet {
            progress.isHidden = true
            progress.text = " "
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
        
        setup()
        
        rotatingImage.resumeAnimations()
    }
    
    private func setup() {
        interactor = ImportFromDropboxInteractor()
        presenter = ImportFromDropboxPresenter()
        
        interactor.output = presenter
        
        presenter.interactor = interactor
        presenter.view = self
    }

    
    @IBAction func connectToDropbox(_ sender: Any) {
        presenter.startDropbox()
    }
    
}


// MARK: - ImportFromDropboxViewInput
extension DropboxAccountConnectionCell: ImportFromDropboxViewInput {

    func startDropboxStatus() {
        connectButton.isEnabled = false
        rotatingImage.isHidden = false
        rotatingImage.startInfinityRotate360Degrees(duration: 2)
        progress.isHidden = false
        progress.text = String(format: TextConstants.importFiles, String(0))
    }
    
    func updateDropboxStatus(progressPercent: Int) {
        progress.isHidden = false
        progress.text = String(format: TextConstants.importFiles, String(progressPercent))
    }
    
    func stopDropboxStatus(lastUpdateMessage: String) {
        connectButton.isEnabled = true
        rotatingImage.isHidden = true
        rotatingImage.stopInfinityRotate360Degrees()
        progress.text = lastUpdateMessage
    }
    
    // MARK: Start
    
    /// nothing. maybe will be toast message
    func dbStartSuccessCallback() {
        MenloworksEventsService.shared.onDropboxTransfered()
    }
    
    func failedDropboxStart(errorMessage: String) {
        let isDropboxAuthorisationError = errorMessage.contains("invalid_access_token")
        if isDropboxAuthorisationError {
            delegate?.showError(message: TextConstants.dropboxAuthorisationError)
        } else {
            delegate?.showError(message: errorMessage)
        }
    }
}

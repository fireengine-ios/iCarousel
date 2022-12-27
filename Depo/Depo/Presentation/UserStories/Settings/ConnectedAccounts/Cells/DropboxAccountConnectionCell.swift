//
//  DropboxAccountConnectionCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit


final class DropboxAccountConnectionCell: UITableViewCell, SocialConnectionCell {
    
    private(set) var section: Section?
    weak var delegate: SocialConnectionCellDelegate?
    
    private var interactor: ImportFromDropboxInteractor!
    private var presenter: ImportFromDropboxPresenter!
    
    @IBOutlet private weak var caption: UILabel! {
        didSet {
            caption.font = UIFont.TurkcellSaturaDemFont(size: 18.0)
            caption.text = TextConstants.dropbox
        }
    }
    
    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.layer.masksToBounds = false
            newValue.layer.cornerRadius = 15
            newValue.layer.shadowOpacity = 0.2
            newValue.layer.shadowColor = UIColor.gray.cgColor
            newValue.layer.shadowOffset = CGSize(width: 0, height: 0)
        }
    }
    
    @IBOutlet private weak var icon: UIImageView! {
        didSet {
            icon.contentMode = .center
            icon.image = UIImage(named:"iconTabDropboxBlue")
        }
    }
    
    @IBOutlet private weak var customText: UILabel! {
        didSet {
            customText.font = .appFont(.regular, size: 14)
            customText.textColor = AppColor.label.color
            customText.text = TextConstants.importFromDB
            customText.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var progress: UILabel! {
        didSet {
            progress.font = UIFont.TurkcellSaturaRegFont(size: 14.0)
            progress.text = " "
            progress.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var importButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        isAccessibilityElement = true
        updateAccessbilityTraits(isEnabled: true)

        setup()
        
        presenter.viewIsReady()
    }
    
    private func setup() {
        interactor = ImportFromDropboxInteractor()
        presenter = ImportFromDropboxPresenter()
        
        interactor.output = presenter
        
        presenter.interactor = interactor
        presenter.view = self
    }
    
    func setup(with section: Section?) {
        self.section = section
    }
    
    func disconnect() {
        presenter.disconnectAccount()
    }

    @IBAction func importToDropbox(_ sender: Any) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .dropboxImport))
        presenter.startDropbox()
    }

    override func accessibilityActivate() -> Bool {
        importToDropbox(importButton)
        return true
    }

    private func updateAccessbilityTraits(isEnabled: Bool) {
        var traits: UIAccessibilityTraits = [.button]
        if !isEnabled {
            traits.insert(.notEnabled)
        }

        accessibilityTraits = traits
    }
}


// MARK: - ImportFromDropboxViewInput
extension DropboxAccountConnectionCell: ImportFromDropboxViewInput {

    func connectionStatusSuccess(_ isOn: Bool) {
        if let section = section {
            if isOn {
                delegate?.didConnectSuccessfully(section: section)
            } else {
                delegate?.didDisconnectSuccessfully(section: section)
            } 
        }
    }

    func connectionStatusFailure(errorMessage: String) {
        delegate?.showError(message: errorMessage)
    }
    
    func disconnectionSuccess() {
        if let section = section {
            delegate?.didDisconnectSuccessfully(section: section)
        }
    }
    
    func disconnectionFailure(errorMessage: String) {
        delegate?.showError(message: errorMessage)
    }
    

    func startDropboxStatus() {
        importButton.isEnabled = false
        updateAccessbilityTraits(isEnabled: false)
        progress.text = String(format: TextConstants.importFiles, String(0))
    }
    
    func updateDropboxStatus(progressPercent: Int) {
        progress.text = String(format: TextConstants.importFiles, String(progressPercent))
    }
    
    func stopDropboxStatus(lastUpdateMessage: String) {
        importButton.isEnabled = true
        updateAccessbilityTraits(isEnabled: true)
        progress.text = lastUpdateMessage
    }
    
    // MARK: Start
    
    /// nothing. maybe will be toast message
    func dbStartSuccessCallback() {
        
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

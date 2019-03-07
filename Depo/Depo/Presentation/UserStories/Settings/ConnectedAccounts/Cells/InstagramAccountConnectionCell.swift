//
//  InstagramAccountConnectionCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstagramAccountConnectionCell: UITableViewCell, SocialAccountConnectionCell {
    
    weak var delegate: SocialAccountConnectionCellDelegate?
    
    private var interactor: ImportFromInstagramInteractor!
    private var presenter: ImportFromInstagramPresenter!
    private var router: ImportFromInstagramRouter!
    
    
    private var isConnected = false {
        didSet {
            removeConnectionButton.isHidden = !isConnected
            connectedAs.isHidden = !isConnected
        
            if !isConnected {
                isImportOn = false
                isInstaPickOn = false
            }
            
            delegate?.willChangeHeight()
        }
    }
    
    private var isImportOn = false {
        didSet {
            importSwitch.setOn(isImportOn, animated: true)
        }
    }
    
    private var isInstaPickOn = false {
        didSet {
            instaPickSwitch.setOn(isInstaPickOn, animated: true)
        }
    }
    
    @IBOutlet private weak var caption: UILabel! {
        didSet {
            caption.font = UIFont.TurkcellSaturaDemFont(size: 18.0)
            caption.text = TextConstants.instagram
        }
    }
    
    @IBOutlet private weak var instaPickIcon: UIImageView! {
        didSet {
            instaPickIcon.image = UIImage(named:"instagram")
            instaPickIcon.contentMode = .center
        }
    }
    
    @IBOutlet private weak var importFromInstagramIcon: UIImageView! {
        didSet {
            importFromInstagramIcon.image = UIImage(named:"instagram")
            importFromInstagramIcon.contentMode = .center
        }
    }
    
    @IBOutlet weak var instaPickText: UILabel! {
        didSet {
            instaPickText.font = UIFont.TurkcellSaturaRegFont(size: 18.0)
            instaPickText.text = TextConstants.myStreamInstaPickTitle
            instaPickText.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet weak var importFromInstagramText: UILabel! {
        didSet {
            importFromInstagramText.font = UIFont.TurkcellSaturaRegFont(size: 18.0)
            importFromInstagramText.text = TextConstants.importFromInstagram
            importFromInstagramText.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var removeConnectionButton: UIButton! {
        didSet {
            removeConnectionButton.tintColor = ColorConstants.removeConnection
            removeConnectionButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 20.0)
            removeConnectionButton.isHidden = true
            removeConnectionButton.layer.borderColor = removeConnectionButton.currentTitleColor.cgColor
            removeConnectionButton.layer.borderWidth = 2.0
            removeConnectionButton.layer.cornerRadius = removeConnectionButton.bounds.height * 0.25
            removeConnectionButton.setTitle(TextConstants.removeConnection, for: .normal)
        }
    }
    
    @IBOutlet private weak var instaPickSwitch: UISwitch! {
        didSet {
            instaPickSwitch.setOn(isInstaPickOn, animated: true)
        }
    }
    
    @IBOutlet private weak var importSwitch: UISwitch! {
        didSet {
            importSwitch.setOn(isConnected, animated: true)
        }
    }
    
    @IBOutlet private weak var connectedAs: UILabel! {
        didSet {
            connectedAs.font = UIFont.TurkcellSaturaMedFont(size: 16.0)
            connectedAs.text = " "
            connectedAs.isHidden = true
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
        
        presenter.viewIsReady()
    }
    

    private func setup() {
        interactor = ImportFromInstagramInteractor()
        presenter = ImportFromInstagramPresenter()
        router = ImportFromInstagramRouter()
        
        interactor.instOutput = presenter
        presenter.router = router
        
        presenter.interactor = interactor
        presenter.view = self
    }
 
    
    @IBAction func instaPickSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            presenter.enableInstaPick()
        } else {
            presenter.disableInstaPick()
        }
    }
    
    @IBAction func importSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            presenter.startInstagram()
        } else {
            presenter.stopInstagram()
        }
    }
    
    @IBAction func removeConnection(_ sender: Any) {
        let attributedText = NSMutableAttributedString(string: TextConstants.instagramRemoveConnectionWarningMessage, attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        if let connectedAsText = connectedAs.attributedText {
            attributedText.append(connectedAsText)
        }
        let warningPopup = PopUpController.with(title: TextConstants.instagramRemoveConnectionWarning,
                             attributedMessage: attributedText,
                             image: .none,
                             firstButtonTitle: TextConstants.cancel, secondButtonTitle: TextConstants.actionSheetRemove,
                             firstAction: { popup in
                                popup.close()
        }, secondAction: { [weak self] popup in
            popup.close()
            self?.presenter.disconnectAccount()
        })
        
        UIApplication.topController()?.present(warningPopup, animated: true, completion: nil)
    }
}


// MARK: - ImportFromInstagramViewInput
extension InstagramAccountConnectionCell: ImportFromInstagramViewInput {

    // MARK: Social status (connection)
    
    func connectionStatusSuccess(_ isOn: Bool, username: String?) {
        isConnected = isOn
        
        if let username = username {
            connectedAs.text = String(format: TextConstants.instagramConnectedAsFormat, username)
            connectedAs.isHidden = false
        } else {
            connectedAs.isHidden = true
        }
    }
    
    func connectionStatusFailure(errorMessage: String) {
        isConnected = false
    }

    func disconnectionSuccess() {
        isConnected = false
    }
    
    func disconnectionFailure(errorMessage: String) {
        delegate?.showError(message: errorMessage)
    }
    
    // MARK: instaPick
    
    func instaPickStatusSuccess(_ isOn: Bool) {
        isInstaPickOn = isOn
    }
    
    func instaPickStatusFailure() {
        isInstaPickOn = false
    }
    
    
    // MARK: Sync status
    
    func syncStatusSuccess(_ isOn: Bool) {
        isImportOn = isOn
    }
    
    func syncStatusFailure() {
        isImportOn = false
    }
    
    
    // MARK: Start
    
    func syncStartSuccess() {
        MenloworksEventsService.shared.onInstagramTransfered()
        MenloworksTagsService.shared.instagramImport(isOn: true)
        isImportOn = true
    }
    
    func syncStartFailure(errorMessage: String) {
        MenloworksTagsService.shared.instagramImport(isOn: false)
        isImportOn = false
        if errorMessage != TextConstants.NotLocalized.instagramLoginCanceled {
            delegate?.showError(message: errorMessage)
        }
    }
    
    
    // MARK: Stop
    
    func syncStopSuccess() {
        isImportOn = false
    }
    
    func syncStopFailure(errorMessage: String) {
        isImportOn = true
        delegate?.showError(message: errorMessage)
    }
}

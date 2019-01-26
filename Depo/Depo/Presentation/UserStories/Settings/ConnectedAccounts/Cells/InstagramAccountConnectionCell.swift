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
            importSwitch.setOn(isConnected, animated: true)
        }
    }
    
    private var isInstaPickOn = false {
        didSet {
            instaPickSwitch.setOn(isInstaPickOn, animated: true)
        }
    }
    
    @IBOutlet private weak var caption: UILabel! {
        didSet {
            caption.text = TextConstants.instagram
        }
    }
    
    @IBOutlet private weak var instaPickIcon: UIImageView! {
        didSet {
            instaPickIcon.image = #imageLiteral(resourceName: "instagram")
            instaPickIcon.contentMode = .center
        }
    }
    
    @IBOutlet private weak var importFromInstagramIcon: UIImageView! {
        didSet {
            importFromInstagramIcon.image = #imageLiteral(resourceName: "instagram")
            importFromInstagramIcon.contentMode = .center
        }
    }
    
    @IBOutlet weak var instaPickText: UILabel! {
        didSet {
            instaPickText.text = TextConstants.myStreamInstaPickTitle
            instaPickText.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet weak var importFromInstagramText: UILabel! {
        didSet {
            importFromInstagramText.text = TextConstants.importFromInstagram
            importFromInstagramText.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var removeConnectionButton: UIButton! {
        didSet {
            removeConnectionButton.layer.borderColor = removeConnectionButton.currentTitleColor.cgColor
            removeConnectionButton.layer.borderWidth = 2.0
            removeConnectionButton.layer.cornerRadius = removeConnectionButton.bounds.height * 0.4
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
            connectedAs.text = " "
            connectedAs.isHidden = true
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    func willDisplay() {
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
        ///
    }
    
    @IBAction func importSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            presenter.startInstagram()
        } else {
            presenter.stopInstagram()
        }
    }
    
    @IBAction func removeConnection(_ sender: Any) {
        ///
    }
}


// MARK: - ImportFromInstagramViewInput
extension InstagramAccountConnectionCell: ImportFromInstagramViewInput {
    
    // MARK: Status
    
    func instagramStatusSuccess() {
        isConnected = true
    }
    
    func instagramStatusFailure() {
        isConnected = false
    }
    
    // MARK: Start
    
    func instagramStartSuccess() {
        MenloworksEventsService.shared.onInstagramTransfered()
        MenloworksTagsService.shared.instagramImport(isOn: true)
        isConnected = true
    }
    
    func instagramStartFailure(errorMessage: String) {
        MenloworksTagsService.shared.instagramImport(isOn: false)
        isConnected = false
        if errorMessage != TextConstants.NotLocalized.instagramLoginCanceled {
            delegate?.showError(message: errorMessage)
        }
    }
    
    // MARK: Stop
    
    func instagramStopSuccess() {
        isConnected = false
    }
    
    func instagramStopFailure(errorMessage: String) {
        isConnected = true
        delegate?.showError(message: errorMessage)
    }
}

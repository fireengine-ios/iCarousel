//
//  InstagramAccountConnectionCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstagramAccountConnectionCell: UITableViewCell, SocialConnectionCell {
    
    private(set) var section: Section?
    weak var delegate: SocialConnectionCellDelegate?
    
    private var interactor: ImportFromInstagramInteractor!
    private var presenter: ImportFromInstagramPresenter!
    private var router: ImportFromInstagramRouter!

    
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

    
    @IBOutlet private weak var instaPickSwitch: UISwitch! {
        didSet {
            instaPickSwitch.setOn(isInstaPickOn, animated: true)
        }
    }
    
    @IBOutlet private weak var importSwitch: UISwitch! {
        didSet {
            importSwitch.setOn(isImportOn, animated: false)
        }
    }

    @IBOutlet private weak var descriptionLabel: UILabel! {
        didSet {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1.8
            
            let attributes: [NSAttributedStringKey : Any] = [
                .foregroundColor : ColorConstants.darkBorder,
                .font : UIFont.TurkcellSaturaRegFont(size: 16),
                .paragraphStyle : paragraphStyle
            ]
            
            descriptionLabel.attributedText = NSAttributedString(string: TextConstants.photoPickDescription,
                                                                 attributes: attributes)
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
    
    func setup(with section: Section?) {
        self.section = section
    }
    
    func disconnect() {
        presenter.disconnectAccount()
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
    
}


// MARK: - ImportFromInstagramViewInput
extension InstagramAccountConnectionCell: ImportFromInstagramViewInput {

    // MARK: Social status (connection)
    
    func connectionStatusSuccess(_ isOn: Bool, username: String?) {
        if let section = section {
            if isOn {
                delegate?.didConnectSuccessfully(section: section)
            } else {
                delegate?.didDisconnectSuccessfully(section: section)
            }
        }
        section?.mediator.setup(with: username)
    }
    
    func connectionStatusFailure(errorMessage: String) {}

    func disconnectionSuccess() {
        if let section = section {
            delegate?.didDisconnectSuccessfully(section: section)
        }
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

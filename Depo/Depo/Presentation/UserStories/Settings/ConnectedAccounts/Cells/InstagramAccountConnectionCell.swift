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
    @IBOutlet private weak var instaPickIcon: UIImageView! {
        didSet {
            instaPickIcon.image = UIImage(named:"iconTabInstagramPink")
            instaPickIcon.contentMode = .center
        }
    }
    
    @IBOutlet private weak var importFromInstagramIcon: UIImageView! {
        didSet {
            importFromInstagramIcon.image = UIImage(named:"iconTabInstagramPink")
            importFromInstagramIcon.contentMode = .center
        }
    }
    
    @IBOutlet weak var instaPickText: UILabel! {
        didSet {
            instaPickText.font = .appFont(.regular, size: 14)
            instaPickText.textColor = AppColor.label.color
            instaPickText.text = TextConstants.myStreamInstaPickTitle
            instaPickText.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet weak var importFromInstagramText: UILabel! {
        didSet {
            importFromInstagramText.font = .appFont(.regular, size: 14)
            importFromInstagramText.textColor = AppColor.label.color
            importFromInstagramText.text = TextConstants.importFromInstagram
            importFromInstagramText.adjustsFontSizeToFitWidth()
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
    
    @IBOutlet private weak var instaPickSwitch: UISwitch! {
        didSet {
            instaPickSwitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.8)
            instaPickSwitch.onTintColor = AppColor.toggleOn.color
            instaPickSwitch.setOn(isInstaPickOn, animated: true)
        }
    }
    
    @IBOutlet private weak var importSwitch: UISwitch! {
        didSet {
            importSwitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.8)
            importSwitch.onTintColor = AppColor.toggleOn.color
            importSwitch.setOn(isImportOn, animated: false)
        }
    }

    @IBOutlet private weak var descriptionLabel: UILabel! {
        didSet {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1.8
            
            var font = UIFont()
            font = .appFont(.regular, size: 12)
            
            let attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor : AppColor.label.color,
                .font : font,
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
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .instagramImport))
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
        isImportOn = true
        SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.snackbarMessageImportFromInstagramStarted)
    }
    
    func syncStartFailure(errorMessage: String) {
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

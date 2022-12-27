//
//  FacebookAccountConnectionCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SocialConnectionCellDelegate: AnyObject, ActivityIndicator {
    func didConnectSuccessfully(section: Section)
    func didDisconnectSuccessfully(section: Section)
    func showError(message: String)
}

protocol SocialConnectionCell: AnyObject, ActivityIndicator {
    var section: Section? { get }
    var delegate: SocialConnectionCellDelegate? { get set }
    
    func setup(with: Section?)
    func disconnect()
}



extension SocialConnectionCell {
    func startActivityIndicator() {
        delegate?.startActivityIndicator()
    }
    
    func stopActivityIndicator() {
        delegate?.stopActivityIndicator()
    }
}

final class FacebookAccountConnectionCell: UITableViewCell, SocialConnectionCell {

    private(set) var section: Section?

    weak var delegate: SocialConnectionCellDelegate?
    
    private var interactor: ImportFromFBInteractor!
    private var presenter: ImportFromFBPresenter!
    
    private var isImportOn = false {
        didSet {
            importSwitch.setOn(isImportOn, animated: true)
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
    
//    @IBOutlet private weak var caption: UILabel! {
//        didSet {
//            caption.font = UIFont.TurkcellSaturaDemFont(size: 18.0)
//            caption.text = TextConstants.facebook
//        }
//    }
    
    @IBOutlet private weak var icon: UIImageView! {
        didSet {
            icon.contentMode = .center
            icon.image = UIImage(named: "iconTabFacebookBlue")
        }
    }
    
    @IBOutlet private weak var customText: UILabel! {
        didSet {
            customText.font = .appFont(.regular, size: 14)
            customText.textColor = AppColor.label.color
            customText.text = TextConstants.importFromFB
            customText.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var importSwitch: UISwitch! {
        didSet {
            importSwitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.8)
            importSwitch.onTintColor = AppColor.toggleOn.color
            importSwitch.setOn(isImportOn, animated: false)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
        
        presenter.viewIsReady()
    }
    
    private func setup() {
        interactor = ImportFromFBInteractor()
        presenter = ImportFromFBPresenter()
        
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
    
    @IBAction func importSwitchValueChanged(_ sender: UISwitch) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .facebookImport))
        if sender.isOn {
            presenter.startImport()
        } else {
            presenter.stopImport()
        }
    }
}


// MARK: - ImportFromFBViewInput
extension FacebookAccountConnectionCell: ImportFromFBViewInput {
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
        isImportOn = false
        delegate?.showError(message: errorMessage)
    }
    
    func disconnectionSuccess() {
        isImportOn = false
        
        if let section = section {
            delegate?.didDisconnectSuccessfully(section: section)
        }
    }
    
    func disconnectionFailure(errorMessage: String) {
        delegate?.showError(message: errorMessage)
    }
    
    func syncStatusSuccess(_ isOn: Bool) {
        isImportOn = isOn
    }
    
    func syncStatusFailure() {
        isImportOn = false
    }
    
    func importStartSuccess() {
        isImportOn = true
        SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.snackbarMessageImportFromFBStarted)
    }
    
    func importStartFailure(errorMessage: String) {
        isImportOn = false
        delegate?.showError(message: errorMessage)
    }
    
    func importStopSuccess() {
        isImportOn = false
    }
    
    func importStopFailure(errorMessage: String) {
        delegate?.showError(message: errorMessage)
    }
    
    
}

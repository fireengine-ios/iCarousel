//
//  FacebookAccountConnectionCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SocialAccountConnectionCellDelegate: class, ActivityIndicator {
    func showError(message: String)
}

protocol SocialAccountConnectionCell: class, ActivityIndicator {
    func willDisplay()
    var delegate: SocialAccountConnectionCellDelegate? { get set }
}

extension SocialAccountConnectionCell {
    func startActivityIndicator() {
        delegate?.startActivityIndicator()
    }
    
    func stopActivityIndicator() {
        delegate?.stopActivityIndicator()
    }
}

final class FacebookAccountConnectionCell: UITableViewCell, SocialAccountConnectionCell {

    weak var delegate: SocialAccountConnectionCellDelegate?
    
    private var interactor: ImportFromFBInteractor!
    private var presenter: ImportFromFBPresenter!
    
    private var isConnected = false {
        didSet {
            connectionSwitch.setOn(isConnected, animated: true)
        }
    }
    
    @IBOutlet private weak var caption: UILabel! {
        didSet {
            caption.text = TextConstants.facebook
        }
    }
    
    @IBOutlet private weak var icon: UIImageView! {
        didSet {
            icon.contentMode = .center
            icon.image = #imageLiteral(resourceName: "facebook")
        }
    }
    
    @IBOutlet private weak var customText: UILabel! {
        didSet {
            customText.text = TextConstants.importFromFB
            customText.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var connectionSwitch: UISwitch! {
        didSet {
            connectionSwitch.setOn(isConnected, animated: true)
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
        interactor = ImportFromFBInteractor()
        presenter = ImportFromFBPresenter()
        
        interactor.output = presenter
        
        presenter.interactor = interactor
        presenter.view = self
    }
    
    @IBAction func connectionSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            presenter.startFacebook()
        } else {
            presenter.stopFacebook()
        }
    }
}


// MARK: - ImportFromFBViewInput
extension FacebookAccountConnectionCell: ImportFromFBViewInput {
    
    func failedFacebookStatus(errorMessage: String) {
        isConnected = false
        delegate?.showError(message: errorMessage)
    }
    
    func succeedFacebookStart() {
        MenloworksAppEvents.onFacebookConnected()
        MenloworksEventsService.shared.onFacebookTransfered()
        MenloworksTagsService.shared.facebookImport(isOn: true)
        isConnected = true
    }
    
    func failedFacebookStart(errorMessage: String) {
        MenloworksTagsService.shared.facebookImport(isOn: false)
        isConnected = false
        delegate?.showError(message: errorMessage)
    }
    
    func succeedFacebookStop() {
        isConnected = false
    }
    
    func failedFacebookStop(errorMessage: String) {
        MenloworksAppEvents.onFacebookConnected()
        isConnected = true
        delegate?.showError(message: errorMessage)
    }
}

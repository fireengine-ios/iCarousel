//
//  SpotifyAccountConnectionCell.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyAccountConnectionCell: UITableViewCell  {
    
    private(set) var section: Section?
    weak var delegate: SocialConnectionCellDelegate?
    private lazy var service: SpotifyRoutingService = factory.resolve()
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18.0)
            newValue.text = TextConstants.spotify
        }
    }
    
    @IBOutlet private weak var logoImage: UIImageView! {
        willSet {
            newValue.contentMode = .center
            newValue.image = UIImage(named:"spotiLogo")
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18.0)
            newValue.text = TextConstants.importFromSpotify
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var connectButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named:"dropbox_button"), for: .normal)
            newValue.setImage(UIImage(named:"dropbox_button"), for: .highlighted)
            newValue.setImage(UIImage(named:"dropbox_button"), for: .disabled)
        }
    }
    
    @IBOutlet private weak var jobStatusLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 14.0)
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter
    }()
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        service.delegates.add(self)
        isAccessibilityElement = true
        updateAccessbilityTraits(isEnabled: true)
    }

    override func accessibilityActivate() -> Bool {
        connectedButtonTapped(connectButton)
        return true
    }
    
    deinit {
        service.delegates.remove(self)
    }

    @IBAction private func connectedButtonTapped(_ sender: Any) {
//        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .spotifyImport))
//        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .connectedAccounts, eventLabel: .importSpotify)
//        connectButton.isEnabled = false
//        updateAccessbilityTraits(isEnabled: false)
//        service.connectToSpotify(isSettingCell: true, completion: {
//            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Import(status: .on, socialType: .spotify))
//            self.connectButton.isEnabled = true
//            self.updateAccessbilityTraits(isEnabled: true)
//        })
    }
    
    private func setupCell() {
        service.getSpotifyStatus { response in
            switch response {
            case .success(let response):
                self.isConnectHandler(spotifyStatus: response)
            case .failed(let error):
                //TODO: create error handling
                print(error)
            }
        }
    }
    
    private func isConnectHandler(spotifyStatus: SpotifyStatus) {
        
        guard let section = section else {
            assertionFailure()
            return
        }
        
        if spotifyStatus.isConnected {
            delegate?.didConnectSuccessfully(section: section)
            
            switch spotifyStatus.jobStatus {
            case .unowned:
                setConnectConditionWithModifyDate(section: section, username: spotifyStatus.userName, jobStatus: spotifyStatus.lastModifiedDate)
            case .pending:
                setConnectCondition(section: section, username: spotifyStatus.userName, jobStatus: TextConstants.Spotify.Card.importing)
            case .running:
                setConnectCondition(section: section, username: spotifyStatus.userName, jobStatus: TextConstants.Spotify.Card.importing)
            case .finished:
                setConnectConditionWithModifyDate(section: section, username: spotifyStatus.userName, jobStatus: spotifyStatus.lastModifiedDate)
            case .cancelled:
                setConnectConditionWithModifyDate(section: section, username: spotifyStatus.userName, jobStatus: spotifyStatus.lastModifiedDate)
            case .failed:
                setConnectConditionWithModifyDate(section: section, username: spotifyStatus.userName, jobStatus: spotifyStatus.lastModifiedDate)
            }
            
        } else {
            hideJobStatusLabel()
            delegate?.didDisconnectSuccessfully(section: section)
        }
    }
    
    private func setConnectCondition(section: Section, username: String?, jobStatus: String?) {
        hideJobStatusLabel()
        if let username = username {
            section.mediator.setup(with: username)
        }
        
        DispatchQueue.main.async {
            if let jobStatus = jobStatus {
                self.jobStatusLabel.text = jobStatus
            }
        }
    }
    
    private func setConnectConditionWithModifyDate(section: Section, username: String?, jobStatus: Date?) {
        guard let jobStatus = jobStatus else {
            hideJobStatusLabel()
            return
        }
        
        let modifyedDate = dateFormatter.string(from: jobStatus)
        DispatchQueue.main.async {
            section.mediator.setup(with: username)
            self.jobStatusLabel.text = String(format: TextConstants.spotyfyLastImportFormat, modifyedDate)
        }
    }
    
    private func hideJobStatusLabel() {
        jobStatusLabel.text = ""
    }

    private func updateAccessbilityTraits(isEnabled: Bool) {
        var traits: UIAccessibilityTraits = .button
        if !isEnabled {
            traits.insert(.notEnabled)
        }

        accessibilityTraits = traits
    }
}

extension SpotifyAccountConnectionCell: SocialConnectionCell {
    
    func setup(with section: Section?) {
        self.section = section
        setupCell()
    }
    
    func disconnect() {
//        service.disconnectFromSpotify { [weak self] result in
//            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Import(status: .off, socialType: .spotify))
//            guard
//                let self = self,
//                let section = self.section
//            else {
//                assertionFailure()
//                return
//            }
//            switch result {
//            case .success(_):
//                self.analyticsService.trackConnectedAccountsGAEvent(action: .connectedAccounts, label: .spotify, dimension: .connectionStatus, status: false)
//                self.delegate?.didDisconnectSuccessfully(section: section)
//            case .failed(let error):
//                print(error)
//            }
//        }
    }
}

extension SpotifyAccountConnectionCell: SpotifyRoutingServiceDelegate {
    
    func importDidComplete() {
        setupCell()
    }
    
    func importDidCanceled() {
        setupCell()
    }
    
    func importSendToBackground() {
        setupCell()
    }
    
    func spotifyStatusDidChange(_ newStatus: SpotifyStatus) {
        isConnectHandler(spotifyStatus: newStatus)
    }
}

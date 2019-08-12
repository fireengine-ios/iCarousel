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
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        service.delegates.add(self)
    }
    
    deinit {
        service.delegates.remove(self)
    }

    @IBAction private func connectedButtonTapped(_ sender: Any) {
        service.connectToSpotify() 
    }
    
    private func setupCell() {
        service.getSpotifyStatus { response in
            switch response {
            case .success(let response):
                self.isConnectHandler(isConnect: response.isConnected, username: response.userName, jobStatus: response.lastModifiedDate)
            case .failed(let error):
                //TODO: create error handling
                print(error)
            }
        }
    }
    
    private func isConnectHandler(isConnect: Bool, username: String?, jobStatus: Date?) {
        
        guard let section = section else {
            return
        }
        
        isConnect ? delegate?.didConnectSuccessfully(section: section) : delegate?.didDisconnectSuccessfully(section: section)

        DispatchQueue.main.async {
            section.mediator.setupSpotify(username: username, jobStatus: jobStatus)
        }
    }
}

extension SpotifyAccountConnectionCell: SocialConnectionCell {
    
    func setup(with section: Section?) {
        self.section = section
        setupCell()
    }
    
    func disconnect() {
        service.disconnectFromSpotify { [weak self] result in
            guard let section = self?.section else {
                return
            }
            switch result {
            case .success(_):
                self?.delegate?.didDisconnectSuccessfully(section: section)
            case .failed(let error):
                print(error)
            }
        }
    }
}

extension SpotifyAccountConnectionCell: SpotifyRoutingServiceDelegate {
    
    func importDidComplete() {
        //TODO: Some logic will here
    }
    
    func importSendToBackground() {
        //TODO: Status will be here
    }
    
    func spotifyStatusDidChange(_ newStatus: SpotifyStatus) {
        //TODO: Spotify job status should be here
       isConnectHandler(isConnect: newStatus.isConnected, username: newStatus.userName, jobStatus: newStatus.lastModifiedDate)
    }
}

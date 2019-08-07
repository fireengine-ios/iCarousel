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
    private lazy var spotifyService: SpotifyService = factory.resolve()
    
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
        setupCell()
        spotifyService.delegates.add(self)
    }
    
    deinit {
        spotifyService.delegates.remove(self)
    }
    
    
    @IBAction private func connectedButtonTapped(_ sender: Any) {
        service.connectToSpotify() 
    }
    
    private func setupCell() {
        service.getSpotifyStatus { response in
            switch response {
            case .success(let response):
                self.isConnectHandler(isConnect: response.isConnected, username: response.userName, modifyedDate: response.lastModifiedDate)
            case .failed(let error):
                //TODO: create error handling
                print(error)
            }
        }
    }
    
    private func isConnectHandler(isConnect: Bool, username: String?, modifyedDate: Date?) {
        
        guard let section = section else {
            return
        }
        
        if isConnect {
            delegate?.didConnectSuccessfully(section: section)
            section.mediator.setupSpotify(username: username, modifyedDate: modifyedDate)
        } else {
            delegate?.didDisconnectSuccessfully(section: section)
        }
        
    }
}

extension SpotifyAccountConnectionCell: SocialConnectionCell {
    
    func setup(with section: Section?) {
        self.section = section
        service.section = section
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

extension SpotifyAccountConnectionCell: SpotifyServiceDelegate {
   
    func importDidComplete() {
        <#code#>
    }
    
    func importDidFailed(error: Error) {
        <#code#>
    }
    
    func importDidCanceled() {
        <#code#>
    }
    
    func sendImportToBackground() {
        <#code#>
    }
    
    func spotifyStatusDidChange() {
        <#code#>
    }
    
    
}

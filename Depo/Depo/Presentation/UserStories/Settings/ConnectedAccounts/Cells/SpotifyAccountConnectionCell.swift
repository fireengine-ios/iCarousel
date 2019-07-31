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
    

    @IBAction private func connectedButtonTapped(_ sender: Any) {
        let service = SpotifyRoutingService()
        service.connectToSpotify { [weak self] url, playLists  in
            self?.authSpotify(url: url, playLists: playLists)
        }
    }
    
    private func authSpotify(url: URL?, playLists: [SpotifyPlaylist]?) {
        if let url = url {
            let router = RouterVC()
            let vc = router.spotifyAuthWebViewController(url: url)
            router.pushViewController(viewController: vc)
        } else if let playLists = playLists {
            // TODO: Temporary logic
            print(playLists.count)
        } else {
            assertionFailure()
            return
        }
    }
}

extension SpotifyAccountConnectionCell: SocialConnectionCell {
    
    func setup(with section: Section?) {
        self.section = section
    }
    
    func disconnect() {
        // TODO: Temporary logic
        print("Disconnect")
    }
}

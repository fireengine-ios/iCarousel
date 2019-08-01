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
        connectToSpotify()
    }
    
    private func connectToSpotify() {
        let service = SpotifyRoutingService()
        service.connectToSpotify { [weak self] result in
            switch result {
            case .urlResponseResult(let urlResponseResult):
                self?.urlResponseResultHandler(urlResponseResult: urlResponseResult)
            case .playListsResponseResult(let playListResponseResult):
                self?.playListResponseResultHandler(playListsResponseResult: playListResponseResult)
            case .error(let error):
                //Temporary logic for error handling
                print(error.localizedDescription)
            }
        }
    }
    
    private func playListResponseResultHandler(playListsResponseResult: ResponseResult<[SpotifyPlaylist]> ) {
        switch playListsResponseResult {
        case .success(let playLists):
            // Present list of play lists
            print(playLists.count)
        case .failed(let error):
            print(error.localizedDescription)
        }
    }
    
    private func urlResponseResultHandler(urlResponseResult: ResponseResult<URL>) {
        switch urlResponseResult {
        case .success(let url):
            let router = RouterVC()
            let vc = router.spotifyAuthWebViewController(url: url)
            router.pushViewController(viewController: vc)
        case .failed(let error):
            print(error.localizedDescription)
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

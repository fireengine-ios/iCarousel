//
//  SpotifyAccountConnectionCell.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyAccountConnectionCell: UITableViewCell  {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaFont(size: 18.0)
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
    }
    
}

//extension SpotifyAccountConnectionCell: SocialConnectionCell {
//    
//    var section: Section? {
//        <#code#>
//    }
//    
//    var delegate: SocialConnectionCellDelegate? {
//        get {
//            <#code#>
//        }
//        set {
//            <#code#>
//        }
//    }
//    
//    func setup(with: Section?) {
//        <#code#>
//    }
//    
//    func disconnect() {
//        <#code#>
//    }
//}

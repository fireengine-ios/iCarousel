//
//  SpotifyStatusView.swift
//  Depo
//
//  Created by Andrei Novikau on 8/2/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyStatusView: UIView, NibInit {

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.Spotify.Card.title
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.textColor = ColorConstants.charcoalGrey
        }
    }
    
    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = UIFont.TurkcellSaturaFont(size: 16)
            newValue.textColor = ColorConstants.charcoalGrey.withAlphaComponent(0.5)
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter
    }()
    
    private lazy var service: SpotifyRoutingService = factory.resolve()
    
    func setup(with status: SpotifyStatus) {
        if status.jobStatus == .pending || status.jobStatus == .running {
            subtitleLabel.text = TextConstants.Spotify.Card.importing
        } else if let date = status.lastModifiedDate {
            let textString = dateFormatter.string(from: date)
            subtitleLabel.text = String(format: TextConstants.Spotify.Card.lastUpdate, textString)
        } else {
            subtitleLabel.text = ""
        }
    }
}

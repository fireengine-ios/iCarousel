//
//  SpotifyStatusView.swift
//  Depo
//
//  Created by Andrei Novikau on 8/2/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyStatusView: UIView, NibInit {
    
    enum State {
        case empty
        case inProgress
        case finished(_ date: Date)
    }

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
    private var status: SpotifyStatus?
    
    var tapHandler: VoidHandler?
    
    var state: State = .empty {
        didSet {
            switch state {
            case .empty:
                subtitleLabel.text = ""
            case .inProgress:
                subtitleLabel.text = TextConstants.Spotify.Card.importing
            case .finished(let date):
                let dateString = dateFormatter.string(from: date)
                subtitleLabel.text = String(format: TextConstants.Spotify.Card.lastUpdate, dateString)
            }
        }
    }
    
    deinit {
        service.delegates.remove(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        service.delegates.add(self)
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(recognizer)
    }
    
    @objc private func onTap() {
        tapHandler?()
    }
}


extension SpotifyStatusView: SpotifyRoutingServiceDelegate {
    func importDidComplete() { }
    
    func importSendToBackground() {
        state = .inProgress
    }
    
    func spotifyStatusDidChange(_ newStatus: SpotifyStatus) {
        if let date = newStatus.lastModifiedDate {
            state = .finished(date)
        }
    }
}

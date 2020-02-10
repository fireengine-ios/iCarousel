//
//  SpotifyStatusView.swift
//  Depo
//
//  Created by Andrei Novikau on 8/2/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SpotifyStatusViewDelegate: class {
    
    func onViewTap()
    
}

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
    
    weak var delegate: SpotifyStatusViewDelegate?
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

    // MARK: Public methods
    
    func setStatus(_ status: SpotifyStatus?) {
        self.status = status
        processStatus()
    }
    
    func importSendToBackground() {
        state = .inProgress
    }
    
    func spotifyStatusDidChange(_ newStatus: SpotifyStatus) {
        if let date = newStatus.lastModifiedDate {
            state = .finished(date)
        }
    }
    
    // MARK: Private methods
    
    private func processStatus() {
        if let status = status {
            switch status.jobStatus {
            case .pending, .running:
                state = .inProgress
            case .finished, .cancelled, .unowned, .failed:
                if let date = status.lastModifiedDate {
                    state = .finished(date)
                }
            }
        }
    }

    @IBAction private func onViewTap(_ sender: Any) {
        delegate?.onViewTap()
    }
    
}

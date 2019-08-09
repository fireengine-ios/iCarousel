//
//  SpotifyImportViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 7/31/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SpotifyImportControllerDelegate: class {
    func importDidComplete(_ controller: SpotifyImportViewController)
    func importDidFailed(_ controller: SpotifyImportViewController, error: Error)
    func importDidCancel(_ controller: SpotifyImportViewController)
    func importSendToBackground()
}

final class SpotifyImportViewController: BaseViewController, NibInit {

    @IBOutlet private weak var importingLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.Spotify.Import.importing
            newValue.textColor = .white
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    
    @IBOutlet private weak var spotifyLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.Spotify.Import.fromSpotify
            newValue.textColor = .white
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    
    @IBOutlet private weak var lifeboxLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.Spotify.Import.toLifebox
            newValue.textColor = .white
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.Spotify.Import.description
            newValue.textColor = .white
            newValue.font = UIFont.TurkcellSaturaFont(size: 16)
            newValue.numberOfLines = 0
            newValue.textAlignment = .center
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var importInBackgroundButton: UIButton! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = newValue.bounds.height * 0.5
            newValue.layer.borderColor = UIColor.white.cgColor
            newValue.layer.borderWidth = 1
            newValue.setTitle(TextConstants.Spotify.Import.importInBackground, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
        }
    }
    
    private lazy var cancelAsBackButton: UIBarButtonItem = {
        return UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                               font: .TurkcellSaturaDemFont(size: 19.0),
                               target: self,
                               selector: #selector(onCancel))
    }()
    
    private lazy var gradientView: GradientView! = {
        let gradientView = GradientView()
        gradientView.setup(withFrame: view.bounds,
                           startColor: ColorConstants.marineTwo,
                           endColoer: ColorConstants.tealishThree,
                           startPoint: .zero,
                           endPoint: CGPoint(x: 0, y: 1))
        return gradientView
    }()
    
    var playlists: [SpotifyPlaylist]!
    
    weak var delegate: SpotifyImportControllerDelegate?

    private lazy var spotifyService: SpotifyService = factory.resolve()
    
    private var canAutoClose = false
    private var isImportComplete = false
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientBackground()
        navigationItem.leftBarButtonItem = cancelAsBackButton
        navigationItem.title = TextConstants.Spotify.Import.navBarTitle
        
        startImport()
        
        /// Minimum show time = spotifyImportMinShowTimeinterval
        DispatchQueue.main.asyncAfter(deadline: .now() + NumericConstants.spotifyImportMinShowTimeinterval) { [weak self] in
            guard let self = self else {
                return
            }
            self.canAutoClose = true
            self.autoclose()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    private func setupGradientBackground() {
        view.addSubview(gradientView)
        view.sendSubview(toBack: gradientView)
    }

    // MARK: - Action
    
    private func startImport() {
        let ids = playlists.map { $0.playlistId }
        spotifyService.start(playlistIds: ids) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(_):
                self.isImportComplete = true
                self.cancelAsBackButton.isEnabled = false
                self.autoclose()
            case .failed(let error):
                self.delegate?.importDidFailed(self, error: error)
            }
        }
    }
    
    private func autoclose() {
        if canAutoClose && isImportComplete {
            delegate?.importDidComplete(self)
        }
    }
    
    private func stopImport(completion: VoidHandler? = nil) {
        spotifyService.stop { _ in
            completion?()
        }
    }
    
    @objc private func onCancel() {
        delegate?.importDidCancel(self)
    }
    
    @objc private func onImportInBackground() {
        delegate?.importSendToBackground()
    }
}

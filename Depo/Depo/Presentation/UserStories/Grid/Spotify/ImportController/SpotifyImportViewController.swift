//
//  SpotifyImportViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 7/31/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

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
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientBackground()
        navigationItem.leftBarButtonItem = cancelAsBackButton
        navigationItem.title = TextConstants.Spotify.Import.navBarTitle
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
    
    @objc private func onCancel() {
        dismiss(animated: true)
    }
    
    @objc private func onImportInBackground() {
        dismiss(animated: true)
    }
}

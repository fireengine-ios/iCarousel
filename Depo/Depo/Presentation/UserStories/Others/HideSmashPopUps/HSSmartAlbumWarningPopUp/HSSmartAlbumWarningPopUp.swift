//
//  HSSmartAlbumWarningPopUp.swift
//  Depo
//
//  Created by Raman Harhun on 12/18/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class HSSmartAlbumWarningPopUp: BasePopUpController {

    enum Mode {
        case faceImageGroupingDisabled
        case notPremiumUser
        case bothDisabled
    }

    @IBOutlet private weak var popUpView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.layer.shadowRadius = 5
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = .zero
        }
    }

    @IBOutlet private weak var darkView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.backgroundViewColor
        }
    }

    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "CloseCardIcon"), for: .normal)
            newValue.tintColor = ColorConstants.closeIconButtonColor
            newValue.accessibilityLabel = TextConstants.accessibilityClose
        }
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.textColor = ColorConstants.darkBlueColor
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }

    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.darkText
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }

    //MARK: Do Not Show Again UI

    /// seems like it can be removed in future
    @IBOutlet private weak var doNotShowAgainStackView: UIStackView!
    
    @IBOutlet private weak var doNotShowAgainLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.hideSuccessedAlertDoNotShowAgain
            newValue.font = UIFont.TurkcellSaturaFont(size: 16)
            newValue.textColor = UIColor.lrBrownishGrey
        }
    }

    @IBOutlet private weak var doNotShowAgainButton: UIButton! {
        willSet {
            newValue.adjustsImageWhenHighlighted = false

            let normalCheckbox = UIImage(named: "checkBoxNotSelected")
            newValue.setImage(normalCheckbox, for: .normal)

            let selectedCheckbox = UIImage(named: "checkbox_active")
            newValue.setImage(selectedCheckbox, for: .selected)
        }
    }

    @IBOutlet private weak var premiumButton: GradientPremiumButton! {
        willSet {
            newValue.setTitle(TextConstants.becomePremium, for: .normal)

            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        }
    }

    @IBOutlet private weak var functionButton: RoundedInsetsButton! {
        willSet {
            newValue.titleEdgeInsets = UIEdgeInsetsMake(6, 14, 6, 14)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.backgroundColor = UIColor.lrTealishTwo

            newValue.titleLabel?.font = UIFont.TurkcellSaturaFont(size: 18)
            newValue.adjustsFontSizeToFitWidth()
        }
    }

    private lazy var storageVars: StorageVars = factory.resolve()
    
    private let mode: Mode
    
    private weak var delegate: DivorceActionStateProtocol?

    init(mode: Mode, delegate: DivorceActionStateProtocol) {
        self.mode = mode
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        mode = .bothDisabled

        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView = popUpView
        configureAppearance()
    }

    private func configureAppearance() {
        switch mode {
        case .bothDisabled:
            titleLabel.text = TextConstants.peopleAlbumWarningAlertTitle1
            descriptionLabel.text = TextConstants.peopleAlbumWarningAlertMessage1
            functionButton.setTitle(TextConstants.peopleAlbumWarningAlertButton1, for: .normal)
            doNotShowAgainStackView.isHidden = true

        case .notPremiumUser:
            titleLabel.text = TextConstants.peopleAlbumWarningAlertTitle2
            descriptionLabel.text = TextConstants.peopleAlbumWarningAlertMessage2
            functionButton.setTitle(TextConstants.peopleAlbumWarningAlertButton2, for: .normal)
            doNotShowAgainStackView.isHidden = true

        case .faceImageGroupingDisabled:
            titleLabel.text = TextConstants.peopleAlbumWarningAlertTitle3
            descriptionLabel.text = TextConstants.peopleAlbumWarningAlertMessage3
            functionButton.setTitle(TextConstants.peopleAlbumWarningAlertButton3, for: .normal)
            premiumButton.isHidden = true
            doNotShowAgainStackView.isHidden = true

        }
    }

    @IBAction func onCloseTap(_ sender: Any) {
        self.delegate?.onPopUpClosed()
        close()
    }

    @IBAction func onPremiumTap(_ sender: Any) {
        close(isFinalStep: false) {
            self.delegate?.onOpenPremium()

        }
    }

    @IBAction func onFunctionTap(_ sender: Any) {
        close(isFinalStep: false) {
            self.delegate?.onOpenFaceImageGrouping()
        }
    }

    @IBAction func onDoNotShowAgainTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        setHiddenStatus(sender.isSelected)
    }
}

extension HSSmartAlbumWarningPopUp {
    private func setHiddenStatus(_ isHidden: Bool) {
        storageVars.smartAlbumWarningPopUpCheckBox = isHidden
    }
}

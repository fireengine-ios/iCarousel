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
            newValue.layer.cornerRadius = 15
            newValue.layer.shadowRadius = 15
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = .zero
            newValue.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }

    @IBOutlet private weak var darkView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.clear
            newValue.layer.cornerRadius = 15
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
            newValue.textAlignment = .center
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 0
        }
    }

    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
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
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
        }
    }

    @IBOutlet private weak var doNotShowAgainButton: UIButton! {
        willSet {
            newValue.adjustsImageWhenHighlighted = false

            let normalCheckbox = Image.iconSelectEmpty.image
            newValue.setImage(normalCheckbox, for: .normal)

            let selectedCheckbox = Image.iconSelectCheck.image
            newValue.setImage(selectedCheckbox, for: .selected)
        }
    }

    @IBOutlet weak var premiumButton: HideInsetsRoundedButton! {
        willSet {
            newValue.setTitle(TextConstants.becomePremium, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.backgroundColor = AppColor.darkBlueColor.color
        }
    }
    
    

    @IBOutlet private weak var functionButton: HideInsetsRoundedButton! {
        willSet {
            newValue.setTitle(TextConstants.hideSuccessedAlertViewPeopleAlbum, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.backgroundColor = AppColor.darkBlueColor.color
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

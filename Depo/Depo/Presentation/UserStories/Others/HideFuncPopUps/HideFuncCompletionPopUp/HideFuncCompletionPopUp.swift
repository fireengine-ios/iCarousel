//
//  HideFuncCompletionPopUp.swift
//  Depo
//
//  Created by Raman Harhun on 12/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class HideFuncCompletionPopUp: BasePopUpController {

    enum Mode {
        case showOpenSmartAlbumButton
        case showBottomCloseButton
    }

    //MARK: IBOutlets

    @IBOutlet private weak var popUpView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5

            newValue.layer.shadowRadius = 5
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = .zero
        }
    }

    @IBOutlet private weak var blurView: UIVisualEffectView! {
        willSet {
            newValue.alpha = 0.9
            newValue.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        }
    }

    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "CloseCardIcon"), for: .normal)
            newValue.tintColor = ColorConstants.closeIconButtonColor
        }
    }

    @IBOutlet private weak var statusImageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
            newValue.image = UIImage(named: "successImage")
        }
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }

    @IBOutlet private weak var openAlbumButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.hideSuccessPopupButtonTitle, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaMedFont(size: 14)
            newValue.setTitleColor(UIColor.lrTealishTwo, for: .normal)
        }
    }

    @IBOutlet private weak var gradientView: TransparentGradientView! {
        willSet {
            newValue.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            newValue.isFlipedColors = true
            newValue.style = .horizontal
        }
    }

    @IBOutlet private weak var previewAlbumsImageView: UIImageView!

    //MARK: smartAlbumsAdditionsParentView

    @IBOutlet private weak var smartAlbumsAdditionsParentView: UIView!

    @IBOutlet private weak var smartAlbumTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.hideSuccessedAlertPeopleAlbumTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.textColor = ColorConstants.darkText
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }

    @IBOutlet weak var smartAlbumDescriptionLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.hideSuccessedAlertPeopleAlbumDescription
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.darkText
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
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

    @IBOutlet private weak var doNotShowAgainLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.hideSuccessedAlertDoNotShowAgain
            newValue.font = UIFont.TurkcellSaturaFont(size: 16)
            newValue.textColor = UIColor.lrBrownishGrey
        }
    }

    @IBOutlet private weak var viewPeopleAlbumButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.hideSuccessedAlertViewPeopleAlbum, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaFont(size: 16)
            newValue.backgroundColor = UIColor.lrTealishTwo
        }
    }

    //MARL: bottomButtonParentView

    @IBOutlet private weak var bottomButtonParentView: UIView!
    
    @IBOutlet private weak var separatorView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.lrTealish
        }
    }

    @IBOutlet private weak var okButton: UIButton! {
        willSet {
            newValue.setTitleColor(UIColor.lrTealish, for: .normal)
            newValue.setTitle(TextConstants.ok, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        }
    }

    //MARK: Properties

    private let photosCount: Int
    private var mode: Mode = .showOpenSmartAlbumButton

    private weak var delegate: HideFuncRoutingProtocol?

    private lazy var storageVars: StorageVars = factory.resolve()

    //MARK: Init

    init(photosCount: Int, delegate: HideFuncRoutingProtocol) {
        self.photosCount = photosCount
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.photosCount = 0
        super.init(coder: coder)
    }

    //MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if storageVars.hiddenPhotoInPeopleAlbumPopUpCheckBox {
            mode = .showBottomCloseButton
        }

        contentView = popUpView

        configureAppearance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        popUpView.layer.shadowPath = UIBezierPath(rect: popUpView.bounds).cgPath
    }

    //MARK: Utility Methods

    private func configureAppearance() {
        let isSingleImage = photosCount == 1

        switch mode {
        case .showOpenSmartAlbumButton:
            let title = isSingleImage ? TextConstants.hideSuccessedAlertWithPeopleAlbumTitle : TextConstants.hideSuccessPopupMessage
            titleLabel.text = title
            titleLabel.font = UIFont.TurkcellSaturaMedFont(size: 18)
            titleLabel.textColor = UIColor.lrLightBrownishGrey

            bottomButtonParentView.isHidden = true

        case .showBottomCloseButton:
            let title = isSingleImage ? TextConstants.hideSuccessedAlertTitle : TextConstants.hideSuccessPopupMessage
            titleLabel.text = title
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            titleLabel.textColor = ColorConstants.darkBlueColor

            smartAlbumsAdditionsParentView.isHidden = true
            closeButton.isHidden = true
        }

        previewAlbumsImageView.image = UIImage(named: "smartAlbumsDummy")
    }

    //MARK: IBAction

    @IBAction private func onOpenHiddenAlbumTap(_ sender: Any) {
        close {
            self.delegate?.openHiddenAlbum()
        }
    }

    @IBAction private func onOpenPeopleAlbumTap(_ sender: Any) {
        close {
            self.delegate?.openPeopleAlbumIfPossible()
        }
    }

    @IBAction private func onCloseTap(_ sender: Any) {
        close()
    }

    @IBAction private func onForgetPopUpTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        setHiddenStatus(sender.isSelected)
    }

}

extension HideFuncCompletionPopUp {
    private func setHiddenStatus(_ isHidden: Bool) {
        storageVars.hiddenPhotoInPeopleAlbumPopUpCheckBox = isHidden
    }
}

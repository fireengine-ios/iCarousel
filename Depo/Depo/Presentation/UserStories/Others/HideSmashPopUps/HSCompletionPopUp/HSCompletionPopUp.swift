//
//  HSCompletionPopUp.swift
//  Depo
//
//  Created by Raman Harhun on 12/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class HSCompletionPopUp: BasePopUpController {

    enum Mode {
        case showOpenSmartAlbumButton
        case showBottomCloseButton
        case smash
        case hiddenPhotosOnly
        case hiddenAlbums
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

    @IBOutlet private weak var darkView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.backgroundViewColor
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
            newValue.image = PopUpImage.hide.image
        }
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }

    @IBOutlet private weak var openHiddenAlbumButton: UIButton! {
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
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.backgroundColor = UIColor.lrTealishTwo
        }
    }

    //MARK: bottomButtonParentView

    @IBOutlet private weak var bottomOffset: NSLayoutConstraint!
    
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

    //MARK: hiddenAlbumParentView

    @IBOutlet private weak var hiddenAlbumParentView: UIStackView!

    //MARK: Properties

    private let photosCount: Int
    private let mode: Mode

    private weak var delegate: HideFuncRoutingProtocol?

    private lazy var storageVars: StorageVars = factory.resolve()
    private lazy var router = RouterVC()

    //MARK: Init

    init(mode: Mode, photosCount: Int, delegate: HideFuncRoutingProtocol) {
        self.photosCount = photosCount
        self.delegate = delegate
        self.mode = mode

        super.init(nibName: nil, bundle: nil)

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.photosCount = 0
        self.mode = .showOpenSmartAlbumButton
        
        super.init(coder: coder)
    }

    //MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

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

        case .smash:
            hiddenAlbumParentView.arrangedSubviews.forEach { $0.isHidden = true }
            bottomButtonParentView.isHidden = true

            titleLabel.text = TextConstants.smashSuccessedAlertTitle
            titleLabel.font = UIFont.TurkcellSaturaMedFont(size: 18)
            titleLabel.textColor = UIColor.lrLightBrownishGrey

            smartAlbumTitleLabel.text = TextConstants.smashSuccessedAlertSecondTitle
            smartAlbumTitleLabel.textColor = ColorConstants.darkBlueColor
            smartAlbumDescriptionLabel.text = TextConstants.smashSuccessedAlertDescription
            
        case .hiddenPhotosOnly:
            titleLabel.text = TextConstants.hideSuccessPopupMessage
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            titleLabel.textColor = ColorConstants.darkBlueColor
            
            smartAlbumsAdditionsParentView.isHidden = true
            closeButton.isHidden = true
            
        case .hiddenAlbums:
            let title = isSingleImage ? TextConstants.hideSingleAlbumSuccessPopupMessage : TextConstants.hideAlbumsSuccessPopupMessage
            titleLabel.text = title
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            titleLabel.textColor = ColorConstants.darkBlueColor
            
            smartAlbumsAdditionsParentView.isHidden = true
            bottomButtonParentView.isHidden = true
            closeButton.isHidden = false
            bottomOffset.constant = 39
        }

        previewAlbumsImageView.image = UIImage(named: "smartAlbumsDummy")
    }

    //MARK: IBAction

    @IBAction private func onOpenHiddenAlbumTap(_ sender: Any) {
        close {
            if let delegate = self.delegate {
                delegate.openHiddenAlbum()
            } else {
                self.router.navigationController?.dismiss(animated: true, completion: {
                    let controller = self.router.hiddenPhotosViewController()
                    self.router.pushViewController(viewController: controller)
                })
            }
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

extension HSCompletionPopUp {
    private func setHiddenStatus(_ isHidden: Bool) {
        switch mode {
        case .showBottomCloseButton, .hiddenPhotosOnly, .hiddenAlbums:
            assertionFailure("this is kind of magic, do not show button should be hidden")

        case .showOpenSmartAlbumButton:
            storageVars.hiddenPhotoInPeopleAlbumPopUpCheckBox = isHidden

        case .smash:
            storageVars.smashPhotoPopUpCheckBox = isHidden
        }

    }
}

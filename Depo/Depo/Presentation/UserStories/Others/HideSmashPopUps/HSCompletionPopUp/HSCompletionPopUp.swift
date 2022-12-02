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
        case smashPremium
        case smashStandart
        case hiddenAlbums
    }

    //MARK: IBOutlets

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

    @IBOutlet private weak var statusImageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
            newValue.image = PopUpImage.unhide.image
        }
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 0
        }
    }

//    @IBOutlet private weak var openHiddenAlbumButton: UIButton! {
//        willSet {
//            newValue.isHidden = true
//            newValue.setTitle(TextConstants.hideSuccessPopupButtonTitle, for: .normal)
//            newValue.titleLabel?.font = UIFont.TurkcellSaturaMedFont(size: 14)
//            newValue.setTitleColor(UIColor.lrTealishTwo, for: .normal)
//        }
//    }

//    @IBOutlet private weak var gradientView: TransparentGradientView! {
//        willSet {
//            newValue.backgroundColor = AppColor.secondaryBackground.color.withAlphaComponent(0.8)
//            newValue.isFlipedColors = true
//            newValue.style = .horizontal
//        }
//    }

//    @IBOutlet private weak var previewAlbumsImageView: UIImageView!

    //MARK: smartAlbumsAdditionsParentView

    @IBOutlet private weak var smartAlbumsAdditionsParentView: UIView!

    @IBOutlet private weak var smartAlbumTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.hideSuccessedAlertPeopleAlbumTitle
            newValue.font = .appFont(.medium, size: 20)
            newValue.textColor = AppColor.label.color
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }

    @IBOutlet weak var smartAlbumDescriptionLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.hideSuccessedAlertPeopleAlbumDescription
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
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

    @IBOutlet private weak var doNotShowAgainLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.hideSuccessedAlertDoNotShowAgain
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
        }
    }

    @IBOutlet private weak var viewPeopleAlbumButton: HideInsetsRoundedButton! {
        willSet {
            newValue.setTitle(TextConstants.hideSuccessedAlertViewPeopleAlbum, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.backgroundColor = AppColor.darkBlueColor.color
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

    private weak var delegate: DivorceActionStateProtocol?

    private lazy var storageVars: StorageVars = factory.resolve()
    private lazy var router = RouterVC()
    private lazy var analyticsService: AnalyticsService = factory.resolve()

    //MARK: Init

    init(mode: Mode, photosCount: Int, delegate: DivorceActionStateProtocol) {
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

        self.view.layer.cornerRadius = 15
        self.view.layer.masksToBounds = true
        contentView = popUpView

        configureAppearance()
        trackScreenEvents()
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
            titleLabel.textAlignment = .center
            titleLabel.font = .appFont(.regular, size: 16)
            titleLabel.textColor = AppColor.label.color

            bottomButtonParentView.isHidden = true

        case .showBottomCloseButton:
            let title = isSingleImage ? TextConstants.hideSuccessedAlertTitle : TextConstants.hideSuccessPopupMessage
            titleLabel.text = title
            titleLabel.text = title
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            titleLabel.textColor = ColorConstants.darkBlueColor

            smartAlbumsAdditionsParentView.isHidden = true
            closeButton.isHidden = true

        case .smashPremium:
            viewPeopleAlbumButton.setTitle(TextConstants.smashSuccessedAlertShareButton, for: .normal)
            fallthrough
        case .smashStandart:
            statusImageView.image = PopUpImage.success.image
            
            hiddenAlbumParentView.arrangedSubviews.forEach { $0.isHidden = true }
            bottomButtonParentView.isHidden = true
            
            titleLabel.text = title
            titleLabel.textAlignment = .center
            titleLabel.font = .appFont(.regular, size: 16)
            titleLabel.textColor = AppColor.label.color

            smartAlbumTitleLabel.text = TextConstants.smashSuccessedAlertSecondTitle
            smartAlbumTitleLabel.textColor = AppColor.label.color
            smartAlbumDescriptionLabel.text = TextConstants.smashSuccessedAlertDescription
            
        case .hiddenAlbums:
            let title = isSingleImage ? TextConstants.hideSingleAlbumSuccessPopupMessage : TextConstants.hideAlbumsSuccessPopupMessage
            titleLabel.text = title
            titleLabel.textAlignment = .center
            titleLabel.font = .appFont(.regular, size: 16)
            titleLabel.textColor = AppColor.label.color
            
            smartAlbumsAdditionsParentView.isHidden = true
            bottomButtonParentView.isHidden = true
            closeButton.isHidden = false
            bottomOffset.constant = 39
        }

//        previewAlbumsImageView.image = UIImage(named: "smartAlbumsDummy")
    }

    //MARK: IBAction
    
    @IBOutlet weak var rectangleView1: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.layer.shadowRadius = 1
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet weak var rectangleView2: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.layer.shadowRadius = 2
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet weak var rectangleView3: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.layer.shadowRadius = 3
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = .zero
        }
    }
    
//    @IBAction private func onOpenHiddenAlbumTap(_ sender: Any) {
//        close(isFinalStep: false) {
//            //TODO: Need to change to delegate.openHiddenBin() in future
//            //now delegate == nil if hide album (custom or FIR) inside himself
//            self.openHiddenBin()
//        }
//    }
    
    private func openHiddenBin() {
        if #available(iOS 13, *) {
            self.router.navigationController?.dismiss(animated: true, completion: {
                let controller = self.router.hiddenPhotosViewController()
                self.router.pushViewController(viewController: controller)
            })
        } else {
            let controller = router.hiddenPhotosViewController()
            router.pushViewController(viewController: controller)
        }
    }

    @IBAction private func onOpenPeopleAlbumTap(_ sender: Any) {
        if mode == .smashPremium {
            close(isFinalStep: false) {
                self.delegate?.onShare()
            }
        } else {
            trackOpenPeopleAlbumEvent(isCanceled: false)
            close(isFinalStep: false) {
                self.delegate?.onOpenPeopleAlbum()
            }
        }
    }

    @IBAction private func onCloseTap(_ sender: Any) {
        trackOpenPeopleAlbumEvent(isCanceled: true)
        close(isFinalStep: false) { [weak self] in
            self?.delegate?.onPopUpClosed()
        }
    }

    @IBAction private func onForgetPopUpTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        setHiddenStatus(sender.isSelected)
    }

    
    private func trackOpenPeopleAlbumEvent(isCanceled: Bool) {
        switch mode {
        case .smashStandart:
            analyticsService.trackCustomGAEvent(eventCategory: .popUp,
                                                eventActions: .smashSuccessPopUp,
                                                eventLabel: isCanceled ? .cancel : .viewPeopleAlbum)
        case .hiddenAlbums:
            analyticsService.trackCustomGAEvent(eventCategory: .popUp,
                                                eventActions: .saveHiddenSuccessPopup,
                                                eventLabel: isCanceled ? .cancel : .viewPeopleAlbum)
        default:
            break
        }
        
    }
    
    private func trackScreenEvents() {
        switch mode {
        case .smashStandart, .smashPremium:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.SaveSmashSuccessfullyPopUp())
        case .hiddenAlbums, .showBottomCloseButton, .showOpenSmartAlbumButton:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.SaveHiddenSuccessfullyPopUp())
        }
    }
}

extension HSCompletionPopUp {
    private func setHiddenStatus(_ isHidden: Bool) {
        switch mode {
        case .showBottomCloseButton, .hiddenAlbums:
            assertionFailure("this is kind of magic, do not show button should be hidden")

        case .showOpenSmartAlbumButton:
            storageVars.hiddenPhotoInPeopleAlbumPopUpCheckBox = isHidden

        case .smashPremium, .smashStandart:
            storageVars.smashPhotoPopUpCheckBox = isHidden
        }
    }
}

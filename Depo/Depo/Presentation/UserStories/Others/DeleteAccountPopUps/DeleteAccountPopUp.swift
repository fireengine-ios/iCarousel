//
//  DeleteAccountPopUp.swift
//  Depo
//
//  Created by Hady on 10/21/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class DeleteAccountPopUp: UIViewController {
    typealias ProceedTappedHandler = (DeleteAccountPopUp) -> Void

    private var type: Type?
    private var onProceedTapped: ProceedTappedHandler?

    private let analyticsService: AnalyticsService = factory.resolve()

    // MARK: - Outlets
    @IBOutlet weak var popUpView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 4

            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowRadius = 4
            newValue.layer.shadowColor = AppColor.cellShadow.color.cgColor
        }
    }

    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.textAlignment = .center
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 22)
        }
    }

    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.textAlignment = .center
            newValue.textColor = ColorConstants.darkText
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)
        }
    }

    @IBOutlet private weak var firstButton: UIButton! {
        willSet {
            newValue.setTitleColor(AppColor.marineTwoAndTealish.color, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.layer.cornerRadius = 25
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = AppColor.marineTwoAndTealish.color.cgColor
        }
    }

    @IBOutlet private weak var secondButton: UIButton! {
        willSet {
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.backgroundColor = AppColor.marineTwoAndTealish.color
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.layer.cornerRadius = 25
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.popUpBackground.color
        configureViews()
    }

    // MARK: - Actions
    @IBAction private func firstButtonTapped() {
        guard let type = self.type else { return }

        trackFirstButton()
        switch type {
        case .firstConfirmation:
            onProceedTapped?(self)

        case .finalConfirmation,
             .success:
            dismiss(animated: true)
        }
    }

    @IBAction private func secondButtonTapped() {
        guard let type = self.type else { return }

        trackSecondButton()
        switch type {
        case .finalConfirmation:
            onProceedTapped?(self)

        case .firstConfirmation,
             .success:
            dismiss(animated: true)
        }
    }

    // MARK: - Config
    private func configureViews() {
        guard let type = self.type else { return }

        setIconAndTitleStyle(for: type)

        switch type {
        case .firstConfirmation:
            titleLabel.text = localized(.deleteAccountFirstPopupTitle)
            messageLabel.text = localized(.deleteAccountFirstPopupMessage)
            firstButton.setTitle(localized(.deleteAccountDeleteButton), for: .normal)
            secondButton.setTitle(localized(.deleteAccountCancelButton), for: .normal)

        case .finalConfirmation:
            titleLabel.text = localized(.deleteAccountThirdPopupTitle)
            messageLabel.text = localized(.deleteAccountThirdPopupMessage)
            firstButton.setTitle(localized(.deleteAccountCancelButton), for: .normal)
            secondButton.setTitle(localized(.deleteAccountConfirmButton), for: .normal)

        case .success:
            titleLabel.text = localized(.deleteAccountFinalPopupTitle)
            let options = LocalizedAttributedStringOptions(
                font: .TurkcellSaturaFont(size: 18),
                boldFont: .TurkcellSaturaDemFont(size: 18)
            )
            messageLabel.attributedText = localizedAttributed(.deleteAccountFinalPopupMessage, withOptions: options)
            firstButton.setTitle(localized(.deleteAccountCloseButton), for: .normal)
            secondButton.isHidden = true
        }
    }

    private func setIconAndTitleStyle(for type: Type) {
        switch type {
        case .firstConfirmation,
             .finalConfirmation:
            iconView.image = UIImage(named: "customPopUpInfo")?.withRenderingMode(.alwaysTemplate)
            iconView.tintColor = ColorConstants.textOrange
            titleLabel.textColor = ColorConstants.textOrange

        case .success:
            iconView.image = UIImage(named: "successImage")?.withRenderingMode(.alwaysTemplate)
            iconView.tintColor = ColorConstants.aquaMarineTwo
            titleLabel.textColor = ColorConstants.aquaMarineTwo
        }
    }
}

// MARK: - Analytics
extension DeleteAccountPopUp {
    func trackFirstButton() {
        guard let type = type else { return }
        switch type {
        case .firstConfirmation:
            analyticsService.trackCustomGAEvent(eventCategory: .popUp,
                                                eventActions: .deleteMyAccountStep1,
                                                eventLabel: .deleteAccount)

        case .finalConfirmation:
            analyticsService.trackCustomGAEvent(eventCategory: .popUp,
                                                eventActions: .deleteMyAccountStep3,
                                                eventLabel: .cancel)

        case .success:
            break
        }
    }

    func trackSecondButton() {
        guard let type = type else { return }
        switch type {
        case .firstConfirmation:
            analyticsService.trackCustomGAEvent(eventCategory: .popUp,
                                                eventActions: .deleteMyAccountStep1,
                                                eventLabel: .cancel)

        case .finalConfirmation:
            analyticsService.trackCustomGAEvent(eventCategory: .popUp,
                                                eventActions: .deleteMyAccountStep3,
                                                eventLabel: .confirm)

        case .success:
            break
        }
    }
}

// MARK: - Initializer
extension DeleteAccountPopUp {
    enum `Type` {
        case firstConfirmation
        case finalConfirmation
        case success
    }

    static func with(type: Type, onProceedTapped: ProceedTappedHandler? = nil) -> DeleteAccountPopUp {
        let instance = DeleteAccountPopUp()
        instance.type = type
        instance.onProceedTapped = onProceedTapped
        instance.modalTransitionStyle = .crossDissolve
        instance.modalPresentationStyle = .overFullScreen
        return instance
    }
}

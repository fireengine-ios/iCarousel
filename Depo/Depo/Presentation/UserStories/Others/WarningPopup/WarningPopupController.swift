//
//  WarningPopupController.swift
//  Depo
//
//  Created by Andrei Novikau on 6/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum WarningPopupType {
    case contactPermissionDenied
    case lifeboxStorageLimit
    case photoPrintRedirection(photos: [WrapData])

    fileprivate var title: String {
        switch self {
        case .contactPermissionDenied:
            return TextConstants.warningPopupContactPermissionsTitle
        case .lifeboxStorageLimit:
            return TextConstants.warningPopupStorageLimitTitle
        case .photoPrintRedirection:
            return TextConstants.warningPopupPrintRedirectTitle
        }
    }
    
    fileprivate var message: String {
        switch self {
        case .contactPermissionDenied:
            return TextConstants.warningPopupContactPermissionsMessage
        case .lifeboxStorageLimit:
            return TextConstants.warningPopupStorageLimitMessage
        case .photoPrintRedirection:
            return TextConstants.warningPopupPrintRedirectMessage
        }
    }
    
    fileprivate var firstButtonTitle: String? {
        switch self {
        case .contactPermissionDenied:
            return TextConstants.warningPopupContactPermissionsStorageButton
        case .lifeboxStorageLimit:
            return TextConstants.warningPopupStorageLimitSettingsButton
        case .photoPrintRedirection:
            return TextConstants.warningPopupPrintRedirectProceedButton
        }
    }
    
    fileprivate var secondButtonTitle: String? {
        switch self {
        case .contactPermissionDenied:
            return nil
        case .lifeboxStorageLimit:
            return TextConstants.warningPopupContactPermissionsDeleteButton
        case .photoPrintRedirection:
            return TextConstants.warningPopupPrintRedirectCancelButton
        }
    }
}

final class WarningPopupController: BasePopUpController, NibInit {
    
    static func popup(type: WarningPopupType, closeHandler: @escaping VoidHandler) -> UIViewController {
        let popup = WarningPopupController.initFromNib()
        popup.loadViewIfNeeded()
        popup.setup(type: type)
        popup.dismissCompletion = closeHandler
        popup.modalTransitionStyle = .crossDissolve
        popup.modalPresentationStyle = .overFullScreen
        return popup
    }
    
    //MARK: IBOutlet
    
    @IBOutlet private weak var containerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowRadius = 10
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.duplicatesGray
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 20)
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.duplicatesGray
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 16)
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var buttonsStackView: UIStackView! {
        willSet {
            newValue.spacing = 2
        }
    }
    
    @IBOutlet private weak var firstButton: RoundedButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 16)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = ColorConstants.navy
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var secondButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaBolFont(size: 16)
            newValue.setTitleColor(ColorConstants.navy, for: .normal)
        }
    }
    
    private var router = RouterVC()
    private var popupType: WarningPopupType?
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(closeOnTap))
        view.addGestureRecognizer(recognizer)
    }
    
    @objc private func closeOnTap() {
        close()
    }
    
    private func setup(type: WarningPopupType) {
        popupType = type
        
        titleLabel.text = type.title
        messageLabel.text = type.message
        firstButton.setTitle(type.firstButtonTitle, for: .normal)
        secondButton.setTitle(type.secondButtonTitle, for: .normal)
        
        firstButton.isHidden = type.firstButtonTitle == nil
        secondButton.isHidden = type.secondButtonTitle == nil
    }
    
    @IBAction private func onFirstButtonTapped(_ sender: UIButton) {
        guard let type = popupType else {
            close()
            return
        }
        
        let action = { [weak self] in
            switch type {
            case .contactPermissionDenied:
                self?.openSettings()
            case .lifeboxStorageLimit:
                self?.openStorage()
            case .photoPrintRedirection(let photos):
                self?.openPrintPage(photos: photos)
                break
            }
        }
        handle(action)
    }
    
    @IBAction private func onSecondButtonTapped(_ sender: UIButton) {
        guard let type = popupType else {
            close()
            return
        }
        
        let action = { [weak self] in
            switch type {
            case .lifeboxStorageLimit:
                self?.openPhotoPage()
            default:
                break
            }
        }
        handle(action)
    }
    
    private func handle(_ action: @escaping VoidHandler) {
        close {
            action()
        }
    }
}

//MARK: - Actions

private extension WarningPopupController {
    
    func openStorage() {
        router.pushViewController(viewController: router.packages())
    }
    
    func openPhotoPage() {
        router.tabBarController?.showPhotoScreen()
    }
    
    func openSettings() {
        UIApplication.shared.openSettings()
    }

    func openPrintPage(photos: [WrapData]) {
        let vc = PrintInitializer.viewController(data: photos)
        router.pushViewController(viewController: vc)
    }
}

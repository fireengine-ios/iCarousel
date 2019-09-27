//
//  ChangeEmailViewController.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 7/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CredsUpdateCheckPopUp: BasePopUpController {
    
    //MARK: IBOutlet
    @IBOutlet private weak var messageLabel: UILabel!
    
    @IBOutlet private weak var mainLabel: UILabel! {
        willSet {
            let text = TextConstants.credUpdateCheckTitle
            let attributes: [NSAttributedStringKey : Any] = [
                .font : UIFont.TurkcellSaturaDemFont(size: 20),
                .foregroundColor : UIColor.black,
            ]
            
            let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
            
            if let range = text.range(of: TextConstants.enterYourEmail) {
                let nsRange = NSRange(range, in: text)
                
                let boldAttribute: [NSAttributedStringKey : Any] = [ .font : UIFont.TurkcellSaturaBolFont(size: 18) ]
                
                attributedString.addAttributes(boldAttribute, range: nsRange)
            }
            
            newValue.attributedText = attributedString
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var darkBackground: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.popUpBackground
        }
    }
    
    @IBOutlet private weak var popUpView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 4
            
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowRadius = 4
            newValue.layer.shadowColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet private weak var updateButton: WhiteButtonWithRoundedCorner! {
        willSet {
            newValue.setTitle(TextConstants.instapickUpgradePopupButton, for: .normal)
            newValue.setTitleColor(UIColor.lrTealish, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.layer.borderColor = UIColor.lrTealish.cgColor
            newValue.layer.borderWidth = 1
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var yesButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.errorAlertYesBtnBackupAlreadyExist, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setBackgroundColor(UIColor.lrTealish, for: .normal)
            newValue.setBackgroundColor(UIColor.lrTealish.withAlphaComponent(0.5), for: .disabled)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.isOpaque = true
        }
    }
    
    //MARK: Properties
    private let authenticationService = AuthenticationService()
    private let router = RouterVC()
    private var message: String = ""
    private var userInfo: AccountInfoResponse?
    
    private var isShown = false
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView = popUpView
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //MARK: Utility methods
    private func setup() {
        let attributes: [NSAttributedStringKey : Any] = [
            .font : UIFont.TurkcellSaturaFont(size: 18),
            .foregroundColor : ColorConstants.blueGrey,
        ]
        
        let attributedString = NSMutableAttributedString(string: message, attributes: attributes)
        messageLabel.attributedText = attributedString
    }
    
    private func showEmailVerifiedPopUp() {
        let popUp = EmailVerifiedPopUp.with(image: .custom(UIImage(named: "Path")),
                                            message: TextConstants.credUpdateCheckCompletionMessage,
                                            buttonTitle: TextConstants.accessibilityClose,
                                            buttonAction: dismissCompletion)
        
        popUp.modalPresentationStyle = .overFullScreen
        popUp.modalTransitionStyle = .crossDissolve
        
        router.presentViewController(controller: popUp)
    }
    
    private func openUserProfile() {
        if let accountInfo = userInfo {
            let viewController = router.userProfile(userInfo: accountInfo)
            router.pushViewController(viewController: viewController)
        }
    }
    
    private func updateInfoFeedbackRequest(isUpdated: Bool) {
        authenticationService.updateInfoFeedback(isUpdated: isUpdated) { response in
            switch response {
            case .success():
                break
            case .failed(_):
                break
            }
            
        }
    }
    
    //MARK: Actions
    @IBAction private func yesButtonPressed(_ sender: Any) {
        close(isFinalStep: false) { [weak self] in
            self?.showEmailVerifiedPopUp()
            self?.updateInfoFeedbackRequest(isUpdated: false)
        }
    }
    
    @IBAction private func updateButtonPressed(_ sender: Any) {
        close(isFinalStep: false) { [weak self] in
            self?.openUserProfile()
            self?.updateInfoFeedbackRequest(isUpdated: true)
        }
    }
}

//MARK: - Init
extension CredsUpdateCheckPopUp {
    static func with(message: String, userInfo: AccountInfoResponse?) -> CredsUpdateCheckPopUp {
        let controller = CredsUpdateCheckPopUp(nibName: nil, bundle: nil)
        controller.userInfo = userInfo
        controller.message = message
        
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        
        return controller
    }
}

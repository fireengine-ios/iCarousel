//
//  ChangeEmailViewController.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 7/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CredsUpdateCheckPopUp: UIViewController, NibInit {
    
    @IBOutlet private weak var scrollView: UIScrollView!
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
    
    @IBOutlet private weak var contentView: UIView! {
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
        
    private let authenticationService = AuthenticationService()
    private let router = RouterVC()
    private var message: String = ""
    private var userInfo: AccountInfoResponse?
    
    private var isShown = false
    
    static func with(message: String, userInfo: AccountInfoResponse) -> CredsUpdateCheckPopUp {
        let controller = CredsUpdateCheckPopUp.initFromNib()
        
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        controller.message = message
        controller.userInfo = userInfo
        
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        open()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
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
                                            buttonTitle: TextConstants.accessibilityClose)
        
        popUp.modalPresentationStyle = .overFullScreen
        popUp.modalTransitionStyle = .crossDissolve
        
        router.defaultTopController?.present(popUp, animated: true, completion: nil)
    }
    
    private func openUserProfile() {
        if let accountInfo = userInfo {
            let viewController = router.userProfile(userInfo: accountInfo)
            router.pushViewController(viewController: viewController)
        }
    }
    
    private func open() {
        if isShown {
            return
        }
        isShown = true
        contentView.transform = NumericConstants.scaleTransform
        view.alpha = 0
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
            self.contentView.transform = .identity
        }
    }
    
    private func close(completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.contentView.transform = NumericConstants.scaleTransform
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    private func updateInfoFeedbackRequest(isUpdated: Bool) {
        authenticationService.updateInfoFeedback(isUpdated: isUpdated) { response in
            switch response {
            case .success():
                debugLog("updateInfoFeedback - Success - \(isUpdated)")
            case .failed(let error):
                debugLog("updateInfoFeedback - Failure: \(error)")
            }
            
        }
    }
    
    //MARK: Actions

    @IBAction private func yesButtonPressed(_ sender: Any) {
        close { [weak self] in
            self?.showEmailVerifiedPopUp()
            self?.updateInfoFeedbackRequest(isUpdated: false)
        }
    }
    
    @IBAction private func updateButtonPressed(_ sender: Any) {
        close { [weak self] in
            self?.openUserProfile()
            self?.updateInfoFeedbackRequest(isUpdated: true)
        }
    }
}

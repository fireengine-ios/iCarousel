//
//  InstapickPopUpController.swift
//  Depo
//
//  Created by Harbros 3 on 1/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol InstapickPopUpControllerDelegate: class {
    func onConnectWithInsta()
    func onConnectWithoutInsta()
}

final class InstapickPopUpController: UIViewController {
    
    // MARK: Static
    static func with(instaNickname: String? = nil) -> InstapickPopUpController? {
        let vc = controllerWith(instaNickname: instaNickname)
        return vc
    }
    
    private static func controllerWith(instaNickname: String?) -> InstapickPopUpController {
        let vc = InstapickPopUpController(nibName: "InstapickPopUpController", bundle: nil)
        
        if let instaNickname = instaNickname {
            vc.setInstaNickname(instaNickname: instaNickname)
        }
        
        return vc
    }
    
    // MARK: IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var withoutConnectingButton: UIButton!
    @IBOutlet private weak var checkBoxLabel: UILabel!
    @IBOutlet private weak var darkView: UIView!
    @IBOutlet private weak var connectWithInstaView: ConnectWithInstaView!
    
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            containerView.layer.masksToBounds = true
            containerView.layer.cornerRadius = Device.isIpad ? 10 : 5
        }
    }
    
    @IBOutlet private weak var shadowView: UIView! {
        didSet {
            shadowView.layer.cornerRadius = 2
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowRadius = 10
            shadowView.layer.shadowOpacity = 0.5
            shadowView.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var checkBoxButton: UIButton! {
        didSet {
            checkBoxButton.layer.borderWidth = 1
            checkBoxButton.layer.borderColor = ColorConstants.switcherGrayColor.cgColor
        }
    }
    
    private lazy var instapickRoutingService = InstaPickRoutingService()
    private lazy var accountService = AccountService()
    
    private var instaNickname: String?
    private var doNotShowAgain: Bool = false

    weak var delegate: InstapickPopUpControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFonts()
        setupTextColors()
        setupWithoutConnectingButton()
        configure()
    }
    
    // MARK: Animation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)

        open()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if doNotShowAgain {
            instapickRoutingService.stopShowing()
        }
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private var isShown = false
    private func open() {
        if isShown {
            return
        }
        isShown = true
        shadowView.transform = NumericConstants.scaleTransform
        containerView.transform = NumericConstants.scaleTransform
        view.alpha = 0
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
            self.shadowView.transform = .identity
            self.containerView.transform = .identity
        }
    }
    
    private func close(completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.shadowView.transform = NumericConstants.scaleTransform
            self.containerView.transform = NumericConstants.scaleTransform
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    // MARK: Utility methods
    private func setInstaNickname(instaNickname: String) {
        self.instaNickname = instaNickname
    }
    
    private func configure() {
        connectWithInstaView.delegate = self
        connectWithInstaView.configure(instaNickname: instaNickname)
        
        let widthFactor: CGFloat = Device.isIpad ? 0.4 : 0.6
        descriptionLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width * widthFactor
        subtitleLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width * widthFactor
        
        let titleLabelWidthFactor: CGFloat = Device.isIpad ? 0.6 : 0.8
        titleLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width * titleLabelWidthFactor
        titleLabel.text = TextConstants.instaPickAnlyze
        
        let paragraphStyle = getParagraphStyle()
        subtitleLabel.attributedText = NSAttributedString(string: TextConstants.instaPickConnectedAccount,
                                                             attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle])
        descriptionLabel.attributedText = NSAttributedString(string: TextConstants.instaPickDescription,
                                                             attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle])
        descriptionLabel.text = TextConstants.instaPickDescription
        checkBoxLabel.text = TextConstants.instaPickDontShowThisAgain
    }
    
    private func setupFonts() {
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 28)
        subtitleLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        descriptionLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        checkBoxLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
    }
    
    private func setupTextColors() {
        titleLabel.textColor = ColorConstants.darkBlueColor
        subtitleLabel.textColor = ColorConstants.darkBlueColor
        descriptionLabel.textColor = ColorConstants.darkGrayTransperentColor
        checkBoxLabel.textColor = ColorConstants.textGrayColor
    }
    
    private func getParagraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = .center
        return paragraphStyle
    }
    
    private func setupWithoutConnectingButton() {
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : UIFont.TurkcellSaturaBolFont(size: 16),
                                          NSAttributedStringKey.foregroundColor : UIColor.lrTealishTwo,
                                          NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: TextConstants.instaPickConnectedWithoutInstagram,
                                                        attributes: attributes)
        withoutConnectingButton.setAttributedTitle(attributeString, for: .normal)
    }
    
    private func openInstagramAuth(param: InstagramConfigResponse) {
        let router = RouterVC()
        let controller = router.instagramAuth(fromSettings: false)
        if let controller = controller as? InstagramAuthViewController {
            controller.delegate = self
            controller.configure(clientId: param.clientID!, authpath: param.authURL!)
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func getInstagramConfig() {
        showSpinnerOnView(containerView)

        let instService = InstagramService()
        instService.getInstagramConfig(success: { [weak self] response in
            if let containerView = self?.containerView {
                self?.hideSpinerForView(containerView)
            }
            
            guard let response = response as? InstagramConfigResponse else {
                let error = CustomErrors.serverError("An error occurred while getting instagram details.")
                UIApplication.showErrorAlert(message: error.localizedDescription)
                return
            }
            
            DispatchQueue.toMain {
                self?.openInstagramAuth(param: response)
            }
            }, fail: { [weak self] errorResponse in
                if let containerView = self?.containerView {
                    self?.hideSpinerForView(containerView)
                }
                
                UIApplication.showErrorAlert(message: errorResponse.description)
        })
    }
    
    private func changeLikePermissionForInstagram() {
        showSpinnerOnView(containerView)

        accountService.changeInstapickAllowed(isInstapickAllowed: true) { [weak self] response in
            if let containerView = self?.containerView {
                self?.hideSpinerForView(containerView)
            }
            
            switch response {
            case .success(_):
                DispatchQueue.toMain {
                    self?.close { [weak self] in
                        self?.delegate?.onConnectWithInsta()
                    }
                }
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    // MARK: Actions
    @IBAction private func onWithoutConnectingTap(_ sender: Any) {
        close { [weak self] in
            self?.delegate?.onConnectWithoutInsta()
        }
    }
    
    @IBAction private func onCheckBoxTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        doNotShowAgain = sender.isSelected
    }
    
    @IBAction private func onCloseTap(_ sender: Any) {
        close()
    }
    
}

// MARK: - ConnectWithInstaViewDelegate
extension InstapickPopUpController: ConnectWithInstaViewDelegate {
    
    func onConnectTap() {
        getInstagramConfig()
    }
    
    func onConnectWithLoginInstaTap() {
        changeLikePermissionForInstagram()
    }
    
}

// MARK: - InstagramAuthViewControllerDelegate
extension InstapickPopUpController: InstagramAuthViewControllerDelegate {
    
    func instagramAuthSuccess() {
        accountService.changeInstapickAllowed(isInstapickAllowed: true) { [weak self] response in
            self?.hideSpinner()
            
            switch response {
            case .success(_):
                DispatchQueue.toMain {
                    self?.close { [weak self] in
                        self?.delegate?.onConnectWithInsta()
                    }
                }
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
        
        
    }
    
    func instagramAuthCancel() { }
    
}

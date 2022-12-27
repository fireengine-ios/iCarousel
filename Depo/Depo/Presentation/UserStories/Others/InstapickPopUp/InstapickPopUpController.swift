//
//  InstapickPopUpController.swift
//  Depo
//
//  Created by Harbros 3 on 1/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol InstapickPopUpControllerDelegate: AnyObject {
    func onConnectWithInsta()
    func onConnectWithoutInsta()
}

final class InstapickPopUpController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = AppColor.background.color
        sv.layer.cornerRadius = 16
        sv.clipsToBounds = true
        sv.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return sv
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 0
        view.text = TextConstants.instaPickAnlyze
        view.font = .appFont(.medium, size: 20)
        view.textColor = AppColor.label.color
        return view
    }()
    
    lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.text = TextConstants.instaPickConnectedAccount
        view.numberOfLines = 0
        view.font = .appFont(.medium, size: 16)
        view.textColor = AppColor.label.color
        return view
    }()
    
    lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.text = TextConstants.instaPickDescription
        view.numberOfLines = 0
        view.font = .appFont(.light, size: 16)
        view.textColor = AppColor.label.color
        return view
    }()
    
    lazy var withoutConnectingButton: UIButton = {
        let view = UIButton()
        return view
    }()
    
    lazy var withConnectingButton: DarkBlueButton = {
        let view = DarkBlueButton()
        return view
    }()
    
    lazy var checkBoxStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = 16
        return view
    }()
    
    lazy var checkBoxButton: UIButton = {
        let view = UIButton()
        view.setImage(Image.iconSelectEmpty.image, for: .normal)
        view.setImage(Image.iconSelectFills.image, for: .selected)
        return view
    }()
    
    lazy var checkBoxLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 0
        view.text = TextConstants.instaPickDontShowThisAgain
        view.font = .appFont(.regular, size: 14)
        view.textColor = AppColor.label.color
        return view
    }()
    
    lazy var closeButton: UIButton = {
        let view = UIButton()
        view.setImage(Image.iconCancelUnborder.image, for: .normal)
        return view
    }()
    
    private lazy var instapickRoutingService = InstaPickRoutingService()
    private lazy var accountService = AccountService()
    
    var isInstaExist: Bool = false
    private var doNotShowAgain: Bool = false

    weak var delegate: InstapickPopUpControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWithoutConnectingButton()
        setLayout()
        
        closeButton.addTarget(self, action: #selector(onCloseTap), for: .touchUpInside)
        checkBoxButton.addTarget(self, action: #selector(onCheckBoxTap), for: .touchUpInside)
        withoutConnectingButton.addTarget(self, action: #selector(onWithoutConnectingTap), for: .touchUpInside)
        withConnectingButton.addTarget(self, action: #selector(configureInsta), for: .touchUpInside)
        view.backgroundColor = .black.withAlphaComponent(0.6)
        
        withConnectingButton.setTitle(isInstaExist ? TextConstants.instaPickConnectedWithInstagramName : TextConstants.instaPickConnectedWithInstagram, for: .normal)
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
        containerView.transform = NumericConstants.scaleTransform
        view.alpha = 0
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    private func close(completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.containerView.transform = NumericConstants.scaleTransform
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    private func setupWithoutConnectingButton() {
        let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.appFont(.medium, size: 16),
                                                          .foregroundColor : AppColor.label.color,
                                          .underlineStyle : NSUnderlineStyle.single.rawValue]
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
    
    @objc private func configureInsta() {
        if isInstaExist {
            changeLikePermissionForInstagram()
        } else {
            getInstagramConfig()
        }
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
    
    @objc private func onWithoutConnectingTap(_ sender: Any) {
        close { [weak self] in
            self?.delegate?.onConnectWithoutInsta()
        }
    }
    
    @objc private func onCheckBoxTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        doNotShowAgain = sender.isSelected
    }
    
    @objc private func onCloseTap(_ sender: Any) {
        close()
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

extension InstapickPopUpController {
    func setLayout() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 270).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).isActive = true
        
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 60).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 60).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -60).isActive = true
        
        containerView.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 60).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -60).isActive = true
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 60).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -60).isActive = true
        
        containerView.addSubview(withConnectingButton)
        withConnectingButton.translatesAutoresizingMaskIntoConstraints = false
        withConnectingButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40).isActive = true
        withConnectingButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        withConnectingButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        withConnectingButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        containerView.addSubview(withoutConnectingButton)
        withoutConnectingButton.translatesAutoresizingMaskIntoConstraints = false
        withoutConnectingButton.topAnchor.constraint(equalTo: withConnectingButton.bottomAnchor, constant: 40).isActive = true
        withoutConnectingButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        withoutConnectingButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        containerView.addSubview(checkBoxStackView)
        checkBoxStackView.translatesAutoresizingMaskIntoConstraints = false
        checkBoxStackView.topAnchor.constraint(equalTo: withoutConnectingButton.bottomAnchor, constant: 81).isActive = true
        
        checkBoxStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        checkBoxStackView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        checkBoxStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40).isActive = true
        
        checkBoxStackView.addArrangedSubview(checkBoxButton)
        checkBoxStackView.addArrangedSubview(checkBoxLabel)
        
        containerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
    }
}

//
//  PermissionViewController.swift
//  Depo
//
//  Created by Darya Kuliashova on 6/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

protocol MobilePaymentPermissionProtocol: class {
    func approveTapped()
    func backTapped(url: String)
}

final class PermissionViewController: ViewController, ControlTabBarProtocol {
    private let accountService = AccountService()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var activityManager: ActivityIndicatorManager = {
        let manager = ActivityIndicatorManager()
        manager.delegate = self
        return manager
    }()
    
    private lazy var etkPermissionView: UIView & PermissionsViewProtocol = {
        let permissionView = PermissionsView.initFromNib()
        permissionView.type = .etk
        permissionView.delegate = self
        permissionView.textviewDelegate = self
        return permissionView
    }()
    
    private lazy var globalPermissionView: UIView & PermissionsViewProtocol = {
        let permissionView = PermissionsView.initFromNib()
        permissionView.type = .globalPermission
        permissionView.delegate = self
        return permissionView
    }()
    
    private lazy var mobilePaymentPermissionView: UIView & PermissionsViewProtocol = {
        let permissionView = PermissionsView.initFromNib()
        permissionView.type = .mobilePayment
        permissionView.delegate = self
        permissionView.textviewDelegate = self
        return permissionView
    }()
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        setupLayout()
        checkPermissionState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
        hideTabBar()
    }
    
    private func setupScreen() {
        view.clipsToBounds = true
        view.backgroundColor = .white
        
        setTitle(withString: TextConstants.settingsViewCellPermissions)
        navigationController?.navigationItem.title = TextConstants.backTitle
    }
    
    private func setupLayout() {
        view.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: view.topAnchor).activate()
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
    }
    
    private func checkPermissionState() {
        accountService.getPermissionsAllowanceInfo { [weak self] result in
            guard let `self` = self else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let result):
                    self?.setupPermissionViewFromResult(result, type: .etk)
                    self?.setupPermissionViewFromResult(result, type: .globalPermission)
                    self?.setupPermissionViewFromResult(result, type: .mobilePayment)
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                }
            }
        }
    }
    
    private func setupPermissionViewFromResult(_ result: [SettingsPermissionsResponse], type: PermissionType) {
        guard
            let permission = result.first(where: { $0.type == type }),
            permission.isAllowed == true
        else {
            return
        }
        
        let permissionView = viewForPermissionType(type)
        
        let isPendingApproval = (permission.isApprovalPending == true)
        let isOn = (permission.isApproved == true)
        permissionView.turnPermissionOn(isOn: isOn, isPendingApproval: isPendingApproval)
        if type == .mobilePayment {
            permissionView.urlString = permission.eulaURL
        }
        stackView.addArrangedSubview(permissionView)
    }
    
    private func viewForPermissionType(_ type: PermissionType) -> (UIView & PermissionsViewProtocol) {
        switch type {
        case .etk:
            return etkPermissionView
        case .globalPermission:
            return globalPermissionView
        case .mobilePayment:
            return mobilePaymentPermissionView
        }
    }
    
}

//MARK: - PermissionViewDelegate
extension PermissionViewController: PermissionViewDelegate {
    func permissionsView(_ permissionView: PermissionsView, didChangeValue isOn: Bool) {
        guard let type = permissionView.type else {
            permissionView.togglePermissionSwitch()
            return
        }
        switch type {
        case .mobilePayment:
            switch isOn {
            case true:
                showWarningPopUp()
            case false:
                let url = permissionView.urlString
                routeMobilePaymentPermission(url: url)
            }
        default:
            changePermissionsAllowed(permissionView: permissionView, type: type, isOn: isOn)
        }
    }
    
    private func changePermissionsAllowed(permissionView: PermissionsView, type: PermissionType, isOn: Bool) {
        activityManager.start()
        accountService.changePermissionsAllowed(type: type, isApproved: isOn) { [weak self] response in
            self?.activityManager.stop()
            switch response {
            case .success(_):
                self?.checkPermissionState()
            case .failed(let error):
                permissionView.togglePermissionSwitch()
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    private func showWarningPopUp() {
        let plainMessage = TextConstants.mobilePaymentClosePopupDescriptionLabel
        let range = (plainMessage as NSString).range(of: TextConstants.mobilePaymentClosePopupDescriptionBoldRangeLabel)
        let attributeMessage = NSMutableAttributedString(string: plainMessage)
        let attribute = [NSAttributedString.Key.font : UIFont.TurkcellSaturaDemFont(size: 16), NSAttributedString.Key.strokeColor : ColorConstants.marineTwo]
        attributeMessage.addAttributes(attribute, range: range)
        let popup = PopUpController.with(title: TextConstants.mobilePaymentClosePopupTitleLabel, attributedMessage: attributeMessage, image: .none, buttonTitle: TextConstants.ok)
        UIApplication.topController()?.present(popup, animated: false, completion: nil)
    }
}

//MARK: - PermissionViewTextViewDelegate
extension PermissionViewController: PermissionViewTextViewDelegate {
    func tappedOnURL(url: URL) -> Bool {
        switch url.absoluteString {
        case TextConstants.NotLocalized.termsAndUseEtkLinkTurkcellAndGroupCompanies:
            DispatchQueue.toMain {
                self.openTurkcellAndGroupCompanies()
            }
        case TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages:
            DispatchQueue.toMain {
                self.openCommercialEmailMessages()
            }
        case TextConstants.NotLocalized.mobilePaymentPermissionLink:
            DispatchQueue.toMain {
                self.openMobilePaymentAgreement()
            }
        default:
            UIApplication.shared.openSafely(url)
        }
        return true
    }
}

//MARK: - Router
extension PermissionViewController {
    
    private func openTurkcellAndGroupCompanies() {
        let vc = WebViewController(urlString: RouteRequests.turkcellAndGroupCompanies)
        RouterVC().pushViewController(viewController: vc)
    }
    
    private func openCommercialEmailMessages() {
        let vc = FullscreenTextController(text: TextConstants.commercialEmailMessages)
        RouterVC().pushViewController(viewController: vc)
    }
    
    private func openMobilePaymentAgreement() {
        guard let urlString = mobilePaymentPermissionView.urlString else {
            return
        }
        let vc = WebViewController(urlString: urlString)
        RouterVC().pushViewController(viewController: vc)
    }
    
    private func routeMobilePaymentPermission(url: String?) {
        let router = RouterVC()
        let viewController = router.mobilePaymentPermissionController()
        viewController.urlString = url
        viewController.delegate = self
        router.pushViewController(viewController: viewController)
    }
    
}

extension PermissionViewController: MobilePaymentPermissionProtocol {
    
    func approveTapped() {
        navigationController?.popViewController(animated: true)
        changePermissionsAllowed(permissionView: mobilePaymentPermissionView as! PermissionsView, type: .mobilePayment, isOn: true)
    }
    
    func backTapped(url: String) {}
    
}

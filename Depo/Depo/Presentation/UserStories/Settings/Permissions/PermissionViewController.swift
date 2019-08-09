//
//  PermissionViewController.swift
//  Depo
//
//  Created by Darya Kuliashova on 6/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

final class PermissionViewController: ViewController, PermissionViewTextViewDelegate {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScreen()
        setupLayout()
        
        checkPermissionState()
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
            
            switch result {
            case .success(let result):
                self.setupPermissionViewFromResult(result, type: .etk)
                self.setupPermissionViewFromResult(result, type: .globalPermission)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    private func setupPermissionViewFromResult(_ result: [SettingsPermissionsResponse], type: PermissionType) {
        if let permission = result.first(where: { $0.type == type }),
            permission.isAllowed == true,
            let permissionView = viewForPermissionType(type) {
            
            stackView.addArrangedSubview(permissionView)
            permissionView.turnPermissionOn(isOn: permission.isApproved ?? false,
                                            isPendingApproval: permission.isApprovalPending ?? false)
        }
    }
    
    private func viewForPermissionType(_ type: PermissionType) -> (UIView & PermissionsViewProtocol)? {
        if type == .etk {
            return etkPermissionView
        } else if type == .globalPermission {
            return globalPermissionView
        } else {
            return nil
        }
    }
    
// MARK: - PermissionViewTextViewDelegate
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
        default:
            UIApplication.shared.openSafely(url)
        }
        return true
    }
    
    private func openTurkcellAndGroupCompanies() {
        let vc = WebViewController(urlString: RouteRequests.turkcellAndGroupCompanies)
        RouterVC().pushViewController(viewController: vc)
    }
    
    private func openCommercialEmailMessages() {
        let vc = FullscreenTextController(text: TextConstants.commercialEmailMessages)
        RouterVC().pushViewController(viewController: vc)
    }
}

extension PermissionViewController: PermissionViewDelegate {
    func permissionsView(_ permissionView: PermissionsView, didChangeValue isOn: Bool) {
        activityManager.start()
        
        accountService.changePermissionsAllowed(type: permissionView.type, isApproved: isOn) { [weak self] response in
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
}

//
//  PermissionViewController.swift
//  Depo
//
//  Created by Darya Kuliashova on 6/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

final class PermissionViewController: ViewController {
    
    private let accountService = AccountService()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
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
        stackView.pinToSuperviewEdges()
    }
    
    private func checkPermissionState() {
        accountService.getPermissionsAllowanceInfo { [weak self] result in
            guard let `self` = self else {
                return
            }
            
            switch result {
            case .success(let result):
                if let etk = result.first(where: { $0.type == .etk }), etk.isAllowed == true {
                    self.stackView.insertArrangedSubview(self.etkPermissionView, at: 0)
                    self.etkPermissionView.turnPermissionOn(isOn: etk.isApproved ?? false)
                }
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
}

extension PermissionViewController: PermissionViewDelegate {
    func permissionsView(_ permissionView: PermissionsView, didChangeValue isOn: Bool) {
        activityManager.start()
        
        accountService.changePermissionsAllowed(type: permissionView.type, isApproved: isOn) { [weak self] response in
            self?.activityManager.stop()
            
            switch response {
            case .success(_):
                break
            case .failed(let error):
                permissionView.togglePermissionSwitch()
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
}

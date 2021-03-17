//
//  TwoFactorAuthenticationViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

enum TwoFAChallengingReason: String {
    case accountSetting = "ACCOUNT_SETTING"
    case newDevice = "NEW_DEVICE"
}

enum TwoFAChallengeType: String {
    case phone = "SMS_OTP"
    case email = "EMAIL_OTP"
    
    var typeDescription:String {
        switch self {
        case .phone:
            return TextConstants.a2FAFirstPageSendSecurityCodeToPhone
        case .email:
            return TextConstants.a2FAFirstPageSendSecurityCodeToEmail
        }
    }
    
    var GAAction: GAEventAction {
        switch self {
            case .phone:
                return .msisdn
            case .email:
                return .email
        }
    }

    func getMainTitle(for challengeStatus: TwoFAChallengeParametersResponse.ChallengeStatus) -> String {
        switch self {
        case .phone:
            return TextConstants.a2FASecondPageVerifyNumber
        case .email:
            return TextConstants.a2FASecondPageVerifyEmail
        }
    }
    
    func getOTPDescription(for challengeStatus: TwoFAChallengeParametersResponse.ChallengeStatus) -> String {
        switch self {
        case .phone:
            return challengeStatus == .new ?
                TextConstants.a2FASecondPageInfo : TextConstants.twoFAPhoneExistingOTPDescription
        case .email:
            return challengeStatus == .new ?
                TextConstants.a2FASecondPageInfo : TextConstants.twoFAEmailExistingOTPDescription
        }
    }
}

struct TwoFAChallengeModel {
    let challengeType: TwoFAChallengeType
    let typeDescription: String
    let userData: String
    let token: String
}

final class TwoFactorAuthenticationViewController: ViewController, NibInit {
    
    @IBOutlet private var designer: TwoFactorAuthenticationDesigner!
    @IBOutlet private weak var reasonOfAuthLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var errorView: ErrorBannerView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private var availableChallenges: [TwoFAChallengeModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var twoFactorAuthResponse: TwoFactorAuthErrorResponse?
    private var challengingReason: TwoFAChallengingReason?
    private var phoneNumber: String?
    private var email: String?
    
    private var selectedChallenge: TwoFAChallengeModel?
    private var selectedCellIndex: Int?
    
    private lazy var activityManager = ActivityIndicatorManager()
    private lazy var authenticationService = AuthenticationService()
    private lazy var router = RouterVC()
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()

    //MARK: lifecycle
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    init(response: TwoFactorAuthErrorResponse) {
        self.twoFactorAuthResponse = response
        self.challengingReason = response.reason
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        assertionFailure()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        trackScreen()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        title = TextConstants.a2FAFirstPageTitle
        whiteNavBarStyle(isLargeTitle: false)
//        tintColor: ColorConstants.infoPageItemBottomText,
//                         titleTextColor: ColorConstants.infoPageItemBottomText
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    //MARK: Utility methods
    private func setup() {
        createAvailableTypesArray(availableTypes: twoFactorAuthResponse?.challengeTypes)
        setReasonDescriptionLabel()
        
        activityManager.delegate = self
    }
    
    private func trackScreen() {
        analyticsService.logScreen(screen: .securityCheck)
    }
    
    private func setReasonDescriptionLabel() {
        reasonOfAuthLabel.text = TextConstants.a2FAFirstPageDescription
    }
    
    private func createAvailableTypesArray(availableTypes: [TwoFactorAuthErrorResponseChallengeType]?) {
        guard let types = availableTypes, let token = twoFactorAuthResponse?.twoFAToken else {
            assertionFailure()
            return
        }
        
        for item in types {
            guard let type = item.type else {
                assertionFailure("2FA type is nil")
                return
            }
            
            let authType = TwoFAChallengeModel(challengeType: type,
                                    typeDescription: type.typeDescription,
                                    userData: item.displayName ?? "",
                                    token: token)
            availableChallenges.append(authType)
        }
    
        if !availableChallenges.isEmpty {
            selectedCellIndex = availableChallenges.startIndex
            updateCellsAfterSelection()
        }
    }
    
    private func updateCellsAfterSelection() {
        guard let selectedCellIndex = selectedCellIndex else {
            assertionFailure()
            return
        }
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: selectedCellIndex, section: 0)) as? TwoFactorAuthenticationCell else {
            assertionFailure()
            return
        }
        
        selectedChallenge = availableChallenges[safe: selectedCellIndex]
        
        cell.setSelected(selected: true)
        
        /// deselect cells
        tableView.visibleCells
            .filter { $0 != cell }
            .compactMap { $0 as? TwoFactorAuthenticationCell }
            .forEach { $0.setSelected(selected: false) }
    }
    
    private func isSelected(index: Int) -> Bool {
        return selectedCellIndex == index
    }
    
    private func openTwoFactorChallenge(with otpParams: TwoFAChallengeParametersResponse, challenge: TwoFAChallengeModel) {
        let controller = router.twoFactorChallenge(otpParams: otpParams, challenge: challenge)
        router.pushViewController(viewController: controller)
    }
    
    private func prepareToTwoFactorChallenge(challenge: TwoFAChallengeModel) {
        startActivityIndicator()
        
        analyticsService.trackCustomGAEvent(eventCategory: .twoFactorAuthentication,
                                            eventActions: challenge.challengeType.GAAction,
                                            eventLabel: .send)
        
        authenticationService.twoFactorAuthChallenge(token: challenge.token,
                                                     authenticatorId: challenge.userData,
                                                     type: challenge.challengeType.rawValue) { [weak self] response in
            self?.stopActivityIndicator()
                                                        
            switch response {
            case .success(let model):
                DispatchQueue.main.async {
                    self?.openTwoFactorChallenge(with: model, challenge: challenge)
                }
                
            case .failed(let error):
                DispatchQueue.main.async {
                    if let serverError = error as? ServerError {
                        if serverError.code == TwoFAErrorCodes.unauthorized.statusCode {
                            self?.popToLogin()
                        } else if serverError.code == TwoFAErrorCodes.tooManyRequests.statusCode {
                            self?.showTooManyRequestsError(with: TextConstants.twoFATooManyRequestsErrorMessage)
                        } else {
                            UIApplication.showErrorAlert(message: error.description)
                        }
                    }
                }
            }
        }
    }
    
    private func showTooManyRequestsError(with text: String) {
        errorView.message = text
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorView.isHidden = false

            self.view.layoutIfNeeded()
        }

        let errorViewRect = self.view.convert(errorView.frame, to: self.view)
        scrollView.scrollRectToVisible(errorViewRect, animated: true)
    }
    
    private func popToLogin() {
        let popUp = PopUpController.with(title: TextConstants.errorAlert,
                                         message: TextConstants.twoFAInvalidSessionErrorMessage,
                                         image: .error,
                                         buttonTitle: TextConstants.ok) { [weak self] controller in
                                            controller.close { [weak self] in
                                                self?.router.popTwoFactorAuth()
                                            }
        }
        
        router.presentViewController(controller: popUp)
    }
    
    //MARK: Action
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let challenge = self.selectedChallenge else {
            assertionFailure()
            return
        }
        
        prepareToTwoFactorChallenge(challenge: challenge)
    }
}

//MARK: - UITableViewDataSource
extension TwoFactorAuthenticationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableChallenges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeue(reusable: TwoFactorAuthenticationCell.self, for: indexPath)
    }
}

//MARK: - UITableViewDelegate
extension TwoFactorAuthenticationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? TwoFactorAuthenticationCell else {
            assertionFailure()
            return
        }
        
        cell.selectionStyle = .none
        cell.delegate = self
        cell.setCellIndexPath(index: indexPath.row)
        
        let item = availableChallenges[indexPath.row]
        cell.setupCell(typeDescription: item.typeDescription,
                       userData: item.userData)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectButtonPressed(cell: indexPath.row)
    }
}

//MARK: - TwoFactorAuthenticationCellDelegate
extension TwoFactorAuthenticationViewController: TwoFactorAuthenticationCellDelegate {
    
    func selectButtonPressed(cell index: Int) {
        guard index != selectedCellIndex else {
            return
        }
        
        selectedCellIndex = index
        updateCellsAfterSelection()
    }
}

//MARK: - ActivityIndicator
extension TwoFactorAuthenticationViewController: ActivityIndicator {
    
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}

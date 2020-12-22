//
//  SettingsSettingsPresenter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//
import WidgetKit

final class SettingsPresenter: BasePresenter {
    
    weak var view: SettingsViewInput!
    var interactor: SettingsInteractorInput!
    var router: SettingsRouterInput!
    
    private let cameraService = CameraService()
    
    var isPasscodeEmpty: Bool {
        return interactor.isPasscodeEmpty
    }
    
    var isPremiumUser: Bool {
        return AuthoritySingleton.shared.accountType.isPremium
    }
    
    private var isMailVereficationRequired: Bool {
        return isTurkCellUser && interactor.isEmptyMail
    }
    
    var isMailRequired: Bool {
        return isMailVereficationRequired
    }
    
    var isTurkCellUser: Bool {
        return interactor.isTurkcellUser
    }
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
    func mailUpdated(mail: String) {
        view.profileInfoChanged()
        interactor.updateUserInfo(mail: mail)
    }
    
}

// MARK: - SettingsViewOutput
extension SettingsPresenter: SettingsViewOutput {
    
    func viewIsReady() {
        interactor.trackScreen()
        view.prepareCellsData(isPermissionShown: false)
    }
    
    func viewWillBecomeActive() {
        interactor.getCellsData()
        
        startAsyncOperation()
        interactor.getUserInfo()
    }
    
    func onLogout() {
        let controller = PopUpController.with(title: TextConstants.settingsViewLogoutCheckMessage,
                                              message: nil,
                                              image: .none,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              secondAction: { [weak self] vc in
                                                vc.close { [weak self] in
                                                    self?.startAsyncOperation()
                                                    self?.interactor.checkConnectedToNetwork()
                                                }
        })
        
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
    
    func goToConnectedAccounts() {
        router.goToConnectedAccounts()
    }
    
    func goToFaceImage() {
        router.goToFaceImage()
    }
    
    func goToPeriodicContactSync() {
        router.goToPeriodicContactSync()
    }
    
    func goToHelpAndSupport() {
        router.goToHelpAndSupport()
    }
    
    func goToTermsAndPolicy() {
        router.goToTermsAndPolicy()
    }
    
    func goToPermissions() {
        router.goToPermissions()
    }
    
    func onChangeUserPhoto(quotaInfo: QuotaInfoResponse?) {
        interactor.trackPhotoEdit()
        guard let userInfo = interactor.userInfoResponse else {
            return
        }
        view.showProfileAlertSheet(userInfo: userInfo, quotaInfo: quotaInfo, isProfileAlert: true)
    }
    
    func onChooseFromPhotoLibriary(onViewController viewController: UIViewController) {
        cameraService.showImagesPicker(onViewController: viewController)
    }
    
    func onChooseFromPhotoCamera(onViewController viewController: UIViewController) {
        cameraService.showCamera(onViewController: viewController)
    }
    
    func photoCaptured(data: Data) {
        interactor.uploadPhoto(withPhoto: data)
    }
    
    func goToActivityTimeline() {
        router.goToActivityTimeline()
    }
    
    func goToPackagesWith(quotaInfo: QuotaInfoResponse?) {
        router.goToPackagesWith(quotaInfo: quotaInfo)
    }
    
    func goToPremium() {
        router.goToPremium()
    }
    
    func goToPasscodeSettings(needReplaceOfCurrentController: Bool) {
        router.goToPasscodeSettings(isTurkcell: isTurkCellUser, inNeedOfMail: isMailVereficationRequired, needReplaceOfCurrentController: needReplaceOfCurrentController)
    }
    
    func openPasscode(handler: @escaping VoidHandler) {
           router.openPasscode(handler: handler)
    }
    
    func goTurkcellSecurity() {
        isMailVereficationRequired ? router.showMailUpdatePopUp(delegate: self) : router.goTurkcellSecurity(isTurkcell: isTurkCellUser)
    }
    
    func goToMyProfile(userInfo: AccountInfoResponse) {
        router.goToUserInfo(userInfo: userInfo)
    }
    
    func presentErrorMessage(errorMessage: String) {
        router.showError(errorMessage: errorMessage)
    }
    
    func presentActionSheet(alertController: UIAlertController) {
        router.presentAlertSheet(alertController: alertController)
    }
    
}

// MARK: - SettingsInteractorOutput
extension SettingsPresenter: SettingsInteractorOutput {
    
    func cellsDataForSettings(isPermissionShown: Bool) {
        view.prepareCellsData(isPermissionShown: isPermissionShown)
    }
    
    func goToOnboarding() {
        router.goToOnboarding()
    }
    
    func profilePhotoUploadSuccessed(image: UIImage?) {
        if let image = image {
            view.updatePhoto(image: image)
        } else {
            view.profileInfoChanged()
        }
    }
    
    func profilePhotoUploadFailed(error: Error) {
        view.profileWontChangeWith(error: error)
    }
    
    func connectToNetworkFailed() {
        asyncOperationSuccess()
        router.goToConnectedToNetworkFailed()
    }
    
    func asyncOperationStarted() {
        startAsyncOperation()
    }
    
    func asyncOperationStoped() {
        asyncOperationSuccess()
    }
    
    func didObtainUserStatus() {
        asyncOperationSuccess()
        view.updateStatusUser()
    }
    
    func didFailToObtainUserStatus(errorMessage: String) {
        asyncOperationSuccess()
        router.showError(errorMessage: errorMessage)
    }
    
}

// MARK: - SettingsModuleInput
extension SettingsPresenter: SettingsModuleInput { }

// MARK: - MailVerificationViewControllerDelegate
extension SettingsPresenter: MailVerificationViewControllerDelegate {
    func mailVerified(mail: String) {
        mailUpdated(mail: mail)
    }
    
    func mailVerificationFailed() {}
}

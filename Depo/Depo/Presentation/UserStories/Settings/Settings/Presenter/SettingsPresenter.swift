//
//  SettingsSettingsPresenter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SettingsPresenter: BasePresenter {
    
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
    
    var inNeedOfMailVerification: Bool {
        return isTurkCellUser && interactor.isEmptyMail
    }
    
    var inNeedOfMail: Bool {
        return inNeedOfMailVerification
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

// MARK: -SettingsViewOutput
extension SettingsPresenter: SettingsViewOutput {
    
    func viewIsReady() {
        interactor.trackScreen()
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
                                                    MenloworksTagsService.shared.onStartWithLogin(false)
                                                }
        })
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
    
    func goToContactSync() {
        router.goToContactSync()
    }
    
    func goToConnectedAccounts() {
        router.goToConnectedAccounts()
    }
    
    func goToAutoApload() {
        router.goToAutoApload()
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
    
    func goToUsageInfo() {
        router.goToUsageInfo()
    }
    
    func goToPermissions() {
        router.goToPermissions()
    }
    
    func onChangeUserPhoto() {
        interactor.trackPhotoEdit()
        guard let userInfo = interactor.userInfoResponse else {
            return
        }
        view.showProfileAlertSheet(userInfo: userInfo)
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
        router.goToPasscodeSettings(isTurkcell: isTurkCellUser, inNeedOfMail: inNeedOfMailVerification, needReplaceOfCurrentController: needReplaceOfCurrentController)
    }
    
    func openPasscode(handler: @escaping VoidHandler) {
           router.openPasscode(handler: handler)
    }
    
    func goTurkcellSecurity() {
        inNeedOfMailVerification ? router.showMailUpdatePopUp(delegate: self) : router.goTurkcellSecurity(isTurkcell: isTurkCellUser)
    }
    
    func goToMyProfile(userInfo: AccountInfoResponse) {
        router.goToUserInfo(userInfo: userInfo)
    }
    
}

// MARK: -SettingsInteractorOutput
extension SettingsPresenter: SettingsInteractorOutput {
    
    func cellsDataForSettings(array: [[String]]) {
        view.showCellsData(array: array)
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

// MARK: -SettingsModuleInput
extension SettingsPresenter: SettingsModuleInput { }

// MARK: -MailVerificationViewControllerDelegate
extension SettingsPresenter: MailVerificationViewControllerDelegate {
    func mailVerified(mail: String) {
        mailUpdated(mail: mail)
    }
    
    func mailVerificationFailed() {}
}

//
//  SettingsSettingsPresenter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SettingsPresenter: BasePresenter, SettingsModuleInput, SettingsViewOutput, SettingsInteractorOutput {
    
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
    
    func viewIsReady() {
        interactor.trackScreen()
    }
    
    func viewWillBecomeActive() {
        interactor.getCellsData()
        
        startAsyncOperation()
        interactor.getUserInfo()
    }
    
    func cellsDataForSettings(array: [[String]]) {
        view.showCellsData(array: array)
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
    
    func asyncOperationStarted() {
        startAsyncOperation()
    }
    
    func asyncOperationStoped() {
        asyncOperationSuccess()
    }
    
    func goToOnboarding() {
        router.goToOnboarding()
    }
    
    func goToContactSync() {
        router.goToContactSync()
    }
    
    func goToConnectedAccounts() {
        router.goToConnectedAccounts()
    }
    
    func goToPermissions() {
        router.goToPermissions()
    }
    
    func goToAutoApload() {
        router.goToAutoApload()
    }
    
    func goToPeriodicContactSync() {
        router.goToPeriodicContactSync()
    }
    
    func goToFaceImage() {
        router.goToFaceImage()
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
    
    var inNeedOfMailVerification: Bool {
        return isTurkCellUser && interactor.isEmptyMail
    }
    
    var inNeedOfMail: Bool {
        return inNeedOfMailVerification
    }
    
    var isTurkCellUser: Bool {
        return interactor.isTurkcellUser
    }
    
    func mailUpdated(mail: String) {
        view.profileInfoChanged()
        interactor.updateUserInfo(mail: mail)
    }
    
    func goTurkcellSecurity() {
        inNeedOfMailVerification ? router.showMailUpdatePopUp(delegate: self) : router.goTurkcellSecurity(isTurkcell: isTurkCellUser)
    }
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
    // MARK: View input / PHOTO releated
    
    func photoCaptured(data: Data) {
        interactor.uploadPhoto(withPhoto: data)
    }
    
    func onChangeUserPhoto() {
        interactor.trackPhotoEdit()
        view.showPhotoAlertSheet()
    }
    
    func onChooseFromPhotoLibriary(onViewController viewController: UIViewController) {
        cameraService.showImagesPicker(onViewController: viewController)
    }
    
    func onChooseFromPhotoCamera(onViewController viewController: UIViewController) {
        cameraService.showCamera(onViewController: viewController)
    }
    
    // MARK: - interactor output PhotoRelated
    
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
    
    func didObtainUserStatus() {
        asyncOperationSuccess()
        view.updateStatusUser()
    }
    
    func didFailToObtainUserStatus(errorMessage: String) {
        asyncOperationSuccess()
        router.showError(errorMessage: errorMessage)
    }
    
    func connectToNetworkFailed() {
        asyncOperationSuccess()
        router.goToConnectedToNetworkFailed()
    }
    
    func openPasscode(handler: @escaping VoidHandler) {
        router.openPasscode(handler: handler)
    }
}

extension SettingsPresenter: MailVerificationViewControllerDelegate {
    func mailVerified(mail: String) {
        mailUpdated(mail: mail)
    }
    
    func mailVerificationFailed() {}
}

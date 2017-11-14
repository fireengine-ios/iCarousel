//
//  SettingsSettingsPresenter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SettingsPresenter: BasePresenter, SettingsModuleInput, SettingsViewOutput, SettingsInteractorOutput, CustomPopUpAlertActions {
    
    weak var view: SettingsViewInput!
    
    var interactor: SettingsInteractorInput!
    
    var router: SettingsRouterInput!

    let customPopUp = CustomPopUp()
    
    func viewIsReady() {
        interactor.getCellsData()
    }
    
    func cellsDataForSettings(array: [[String]]){
        view.showCellsData(array: array)
    }
    
    func onLogout(){
        customPopUp.delegate = self
        customPopUp.showCustomAlert(withTitle: "",
                                    withText: TextConstants.settingsViewLogoutCheckMessage,
                                    firstButtonText: TextConstants.ok,
                                    secondButtonText: TextConstants.cancel)
        
    }
    
    func goToOnboarding(){
        router.goToOnboarding()
    }
    
    func goToContactSync() {
        router.goToContactSync()
    }
    
    func goToImportPhotos() {
        router.goToImportPhotos()
    }
    
    func goToAutoApload(){
        router.goToAutoApload()
    }
    
    func goToHelpAndSupport(){
        router.goToHelpAndSupport()
    }
    
    func goToUsageInfo() {
        router.goToUsageInfo()
    }
    
    func onUpdatUserInfo(userInfo: AccountInfoResponse){
        router.goToUserInfo(userInfo: userInfo)
    }
    
    func goToActivityTimeline() {
        router.goToActivityTimeline()
    }
    
    func goToPackages() {
        router.goToPackages()
    }
    
    func goToPasscode(delegate: PasscodeEnterDelegate?, type: PasscodeInputViewType) {
        router.goToPasscode(delegate: delegate, type: type)
    }
    
    func goToPasscodeSettings() {
        router.goToPasscodeSettings()
    }

    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
    //MARK: View input / PHOTO releated
    
    func photoCaptured(data: Data) {
        interactor.uploadPhoto(withPhoto: data)
    }
    func onChangeUserPhoto(){
        view.showPhotoAlertSheet()
    }
    
    func onChooseFromPhotoLibriary(onViewController viewController: UIViewController){
        CameraService().showImagesPicker(onViewController: viewController)//showCamera(onViewController: viewController)
        
    }
    
    func onChooseFromPhotoCamera(onViewController viewController: UIViewController){
        CameraService().showCamera(onViewController: viewController)
        
    }
    
    //MARK: - interactor output PhotoRelated
    
    func profilePhotoUploadSuccessed() {
        view.profileInfoChanged()
    }
    
    func profilePhotoUploadFailed(){
        view.profileWontChange()
    }

    //MARK: - CustomPopUpAlertActions

    func cancelationAction() {
        // Logout
        startAsyncOperation()
        interactor.onLogout()
    }
    
    func otherAction() {
        
    }
}

extension SettingsPresenter: PasscodeEnterDelegate {
    func finishPasscode(with type: PasscodeInputViewType) {
        router.closeEnterPasscode()
    }
}

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

    
    func viewIsReady() {
        interactor.getCellsData()
    }
    
    func cellsDataForSettings(array: [[String]]){
        view.showCellsData(array: array)
    }
    
    func onLogout(){
        startAsyncOperation()
        interactor.onLogout()
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
}

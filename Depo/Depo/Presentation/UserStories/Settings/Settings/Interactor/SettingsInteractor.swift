//
//  SettingsSettingsInteractor.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SettingsInteractor: SettingsInteractorInput {

    weak var output: SettingsInteractorOutput!
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    private var userInfoResponse: AccountInfoResponse?
    let authService = AuthenticationService()
    let accountSerivese = AccountService()
    
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    private lazy var storageVars: StorageVars = factory.resolve()
    
    var isPasscodeEmpty: Bool {
        return passcodeStorage.isEmpty
    }
    
    var isTurkcellUser: Bool {
        return (userInfoResponse?.accountType == "TURKCELL")
    }
    var isEmptyMail: Bool {
        return userInfoResponse?.email?.isEmpty ?? false
    }
    
    func updateUserInfo(mail: String) {
         userInfoResponse?.email = mail
    }
    
    func getCellsData() {
        let passcodeCellTitle = String(format: TextConstants.settingsViewCellPasscode, biometricsManager.biometricsTitle)
        
        let securityCells = [TextConstants.settingsViewCellActivityTimline,
                             TextConstants.settingsViewCellUsageInfo,
                             passcodeCellTitle]
        
        var array = [[TextConstants.settingsViewCellBeckup,
                      TextConstants.settingsViewCellImportPhotos,
                      TextConstants.settingsViewCellAutoUpload,
                      TextConstants.settingsViewCellFaceAndImageGrouping],
                     securityCells,
                     [TextConstants.settingsViewCellHelp,
                      TextConstants.settingsViewCellLogout]]
        accountSerivese.info(success: { [weak self] responce in
            guard let `self` = self else {
                return
            }
            DispatchQueue.main.async {
                self.userInfoResponse = responce as? AccountInfoResponse
                if self.isTurkcellUser {
                    array[1].append(TextConstants.settingsViewCellLoginSettings)
                }
                self.output.cellsDataForSettings(array: array)
            }
            
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output.cellsDataForSettings(array: array)
            }
        })
    }

    func onLogout() {
        authService.logout { [weak self] in
            self?.storageVars.autoSyncSet = false
            MenloworksEventsService.shared.onLoggedOut()
            self?.output.goToOnboarding()
        }
    }
    
    func uploadPhoto(withPhoto photo: Data) {
        accountSerivese.setProfilePhoto(param: UserPhoto(photo: photo), success: { [weak self] response in
            ImageDownloder().removeImageFromCache(url: self?.userInfoResponse?.urlForPhoto, completion: {
                DispatchQueue.main.async {
                    self?.output.profilePhotoUploadSuccessed()
                }
            })
            
            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.output.profilePhotoUploadFailed(error: error)
                }
                
        })
    }
    
    func checkConnectedToNetwork() {
        let reachability = ReachabilityService()
        let isWiFi = reachability.isReachable
        isWiFi ? onLogout() : output.connectToNetworkFailed()
    }
}

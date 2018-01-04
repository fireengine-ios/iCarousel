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
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    private lazy var tokenStorage: TokenStorage = TokenStorageUserDefaults()
    
    private var userInfoResponse: AccountInfoResponse?
    
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
    
    func getCellsData(){
        
        let securityCells = [TextConstants.settingsViewCellActivityTimline,
//                             TextConstants.settingsViewCellRecentlyDeletedFiles,
                             TextConstants.settingsViewCellUsageInfo,
                             TextConstants.settingsViewCellPasscode]
        
        var array = [[TextConstants.settingsViewCellBeckup,
                      TextConstants.settingsViewCellImportPhotos,
                      TextConstants.settingsViewCellAutoUpload],
                     securityCells,
                     [TextConstants.settingsViewCellHelp,
                      TextConstants.settingsViewCellLogout]]
        AccountService().info(success: { [weak self] (responce) in
            guard let `self` = self else {
                return
            }
            self.userInfoResponse = responce as? AccountInfoResponse
                if self.isTurkcellUser {
                    array[1].append(contentsOf: [TextConstants.settingsViewCellTurkcellPasscode,
                                                  TextConstants.settingsViewCellTurkcellAutoLogin])
                }
            DispatchQueue.main.async {
                self.requestTurkcellSecurityInfo()
                self.output.cellsDataForSettings(array: array)
            }  
        }, fail: { [weak self] (error) in
            DispatchQueue.main.async {
                self?.output.cellsDataForSettings(array: array)
            }
        })
    }
    
    private func requestTurkcellSecurityInfo() {
        AccountService().securitySettingsInfo(success: { [weak self] (response) in
            guard let unwrapedSecurityresponse = response as? SecuritySettingsInfoResponse,
                let turkCellPasswordOn = unwrapedSecurityresponse.turkcellPasswordAuthEnabled,
                let turkCellAutoLogin = unwrapedSecurityresponse.mobileNetworkAuthEnabled else {
                    return
            }
            DispatchQueue.main.async {
                self?.output.turkCellSecuritySettingsAccuered(passcode: turkCellPasswordOn, autoLogin: turkCellAutoLogin)
            }
            
        }) { (error) in
            
        }
    }
    
    func changeTurkcellSecurity(passcode: Bool, autoLogin: Bool) {
        AccountService().securitySettingsChange(turkcellPasswordAuthEnabled: passcode, mobileNetworkAuthEnabled: autoLogin, success: { [weak self] (response) in
            guard let unwrapedSecurityresponse = response as? SecuritySettingsInfoResponse,
                let turkCellPasswordOn = unwrapedSecurityresponse.turkcellPasswordAuthEnabled,
                let turkCellAutoLogin = unwrapedSecurityresponse.mobileNetworkAuthEnabled else {
                    return
            }
            DispatchQueue.main.async {
                self?.output.turkCellSecuritySettingsAccuered(passcode: turkCellPasswordOn, autoLogin: turkCellAutoLogin)
            }
            debugPrint("response")
        }) { (error) in
            debugPrint("error")
        }
    }
    
    func onLogout() {
        let authService = AuthenticationService()
        authService.logout { [weak self] in
            DispatchQueue.main.async {
                self?.passcodeStorage.clearPasscode()
                self?.biometricsManager.isEnabled = false
                self?.tokenStorage.clearTokens()
                CoreDataStack.default.clearDataBase()
                FreeAppSpace.default.clear()
                WrapItemOperatonManager.default.stopAllOperations()
                self?.output.goToOnboarding()
            }
        }
    }
    
    func uploadPhoto(withPhoto photo: Data) {
        AccountService().setProfilePhoto(param: UserPhoto(photo: photo), success: {[weak self] (response) in
            DispatchQueue.main.async {
                self?.output.profilePhotoUploadSuccessed()
            }
            }, fail: { [weak self] (error) in
                DispatchQueue.main.async {
                    self?.output.profilePhotoUploadFailed()
                }
                
        })
    }
    
    func checkConnectedToNetwork() {
        let reachability = ReachabilityService()
        let isWiFi = reachability.isReachable
        isWiFi ? onLogout() : output.connectToNetworkFailed()
    }
}

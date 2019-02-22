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
    
    private let analyticsManager: AnalyticsService = factory.resolve()
    
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
        
        let importAccountsCells = [TextConstants.settingsViewCellConnectedAccounts]
        
        var array = [[TextConstants.settingsViewCellBeckup,
                      TextConstants.settingsViewCellAutoUpload,
                      TextConstants.settingsViewCellContactsSync,
                      TextConstants.settingsViewCellFaceAndImageGrouping],
                     importAccountsCells,
                     securityCells,
                     [TextConstants.settingsViewCellHelp,
                      TextConstants.settingsViewCellLogout]]
        
        SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] response in
            guard let `self` = self else {
                return
            }
            DispatchQueue.toMain {
                self.userInfoResponse = response
                if self.isTurkcellUser {
                    /// add to the securityCells section
                    array[2].append(TextConstants.settingsViewCellLoginSettings)
                }
                self.output.cellsDataForSettings(array: array)
            }
        }, fail: { [weak self] error in
            DispatchQueue.toMain {
                self?.output.cellsDataForSettings(array: array)
            }

        })
    }

    func onLogout() {
        output.asyncOperationStarted()
        authService.serverLogout(complition: { [weak self] success in
            self?.output.asyncOperationStoped()
            if success {
                self?.analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .logout, eventLabel: .success)
            }
            self?.authService.logout { [weak self] in
                MenloworksEventsService.shared.onLoggedOut()
                self?.output.goToOnboarding()
            }
        })
    }
    
    func uploadPhoto(withPhoto photo: Data) {
        accountSerivese.setProfilePhoto(param: UserPhoto(photo: photo), success: { [weak self] response in
            self?.analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .photoEdit)
            ImageDownloder().removeImageFromCache(url: self?.userInfoResponse?.urlForPhoto, completion: {
                self?.analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .profilePhoto, eventLabel: .profilePhotoUpload)
                DispatchQueue.main.async {
                    self?.output.profilePhotoUploadSuccessed(image: UIImage(data: photo))
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
    
    func trackScreen() {
        analyticsManager.logScreen(screen: .settings)
        analyticsManager.trackDimentionsEveryClickGA(screen: .settings)
    }
    
    func trackPhotoEdit() {
        analyticsManager.logScreen(screen: .settingsPhotoEdit)
        analyticsManager.trackDimentionsEveryClickGA(screen: .settingsPhotoEdit)
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .profilePhoto, eventLabel: .profilePhotoClick)
    }
    
    func getUserStatus() {
        accountSerivese.permissions { [weak self] response in
            switch response {
            case .success(let result):
                AuthoritySingleton.shared.refreshStatus(with: result)
                DispatchQueue.toMain {
                    self?.output.didObtainUserStatus()
                }
            case .failed(let error):
                DispatchQueue.toMain {
                    self?.output.didFailToObtainUserStatus(errorMessage: error.description)
                }
            }
        }
    }
}

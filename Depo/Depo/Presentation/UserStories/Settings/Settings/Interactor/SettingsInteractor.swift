//
//  SettingsSettingsInteractor.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class SettingsInteractor: SettingsInteractorInput {

    weak var output: SettingsInteractorOutput!
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    private let authService = AuthenticationService()
    private let accountService = AccountService()
    
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    private lazy var storageVars: StorageVars = factory.resolve()
    
    private let analyticsManager: AnalyticsService = factory.resolve()
    
    private var isNeedShowPermissions: Bool?

    var isPasscodeEmpty: Bool {
        return passcodeStorage.isEmpty
    }
    
    private(set) var userInfoResponse: AccountInfoResponse?
    private var isChatMenuEnabled = false
    
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
        checkNeedShowPermissions()
    }

    func onLogout() {
        output.asyncOperationStarted()
        authService.serverLogout(complition: { [weak self] success in
            if success {
                self?.analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .logout, eventLabel: .success)
            }
            
            self?.authService.logout { [weak self] in
                self?.output.asyncOperationStoped()
                self?.output.goToOnboarding()
            }
        })
    }
    
    func uploadPhoto(withPhoto photo: Data) {
        accountService.setProfilePhoto(param: UserPhoto(photo: photo), success: { [weak self] response in
            self?.analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .photoEdit)
            ImageDownloder.removeImageFromCache(url: self?.userInfoResponse?.urlForPhoto, completion: {
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
        let reachability = ReachabilityService.shared
        let isWiFi = reachability.isReachable
        isWiFi ? onLogout() : output.connectToNetworkFailed()
    }
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.SettingsScreen())
        analyticsManager.logScreen(screen: .settings)
        analyticsManager.trackDimentionsEveryClickGA(screen: .settings)
    }
    
    func trackPhotoEdit() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ProfileEditScreen())
        analyticsManager.logScreen(screen: .settingsPhotoEdit)
        analyticsManager.trackDimentionsEveryClickGA(screen: .settingsPhotoEdit)
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .profilePhoto, eventLabel: .profilePhotoClick)
    }
    
    func getUserInfo() {
        SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] accountInfo in
            self?.userInfoResponse = accountInfo
            self?.getUserStatus()
            self?.populateDataForCells()
        }, fail: { [weak self] errorResponse in
            self?.output.didFailToObtainUserStatus(errorMessage: errorResponse.errorDescription ?? TextConstants.errorServer)
            
        })
    }

    func fetchChatbotRemoteConfig() {
        #if LIFEBOX
        FirebaseRemoteConfig.shared.fetchChatbotMenuEnable { [weak self] in
            self?.isChatMenuEnabled = $0
            self?.populateDataForCells()
        }
        #endif
    }

    private func getUserStatus() {
        accountService.permissions { [weak self] response in
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
    
    private func checkNeedShowPermissions() {
        guard isNeedShowPermissions == nil else {
            populateDataForCells()
            return
        }
        
        output.asyncOperationStarted()
        accountService.getPermissionsAllowanceInfo { [weak self] response in
            DispatchQueue.main.async {
                switch response {
                case .success(let permissions):
                    
                    self?.isNeedShowPermissions = permissions.contains(where: { $0.isAllowed == true })
                    self?.populateDataForCells()

                case .failed(let error):
                    debugPrint("get Permissions error \(error.localizedDescription)")
                }
                
                self?.output.asyncOperationStoped()
            }
        }
    }
    
    func populateDataForCells() {
        let isPermissionShown = self.isNeedShowPermissions ?? false
        let isInvitationShown = self.userInfoResponse?.showInvitation ?? false
        let isChatMenuEnabled = self.isChatMenuEnabled

        output.cellsDataForSettings(isPermissionShown: isPermissionShown, isInvitationShown: isInvitationShown, isChatbotShown: isChatMenuEnabled)
    }
}

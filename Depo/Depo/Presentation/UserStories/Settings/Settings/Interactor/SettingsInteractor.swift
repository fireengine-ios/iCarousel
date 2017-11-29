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
    
    private var userInfoResponse: AccountInfoResponse?
    
    var isPasscodeEmpty: Bool {
        return passcodeStorage.isEmpty
    }
    
    func getCellsData(){
        
        var securityCells = [TextConstants.settingsViewCellActivityTimline,
                             TextConstants.settingsViewCellRecentlyDeletedFiles,
                             TextConstants.settingsViewCellUsageInfo,
                             TextConstants.settingsViewCellPasscode]
        
//        AccountService().securitySettingsInfo(success: { (response) in
//            debugPrint(response)
//        }) { (error) in
//
//        }

//        AccountService().securitySettingsChange(turkcellPasswordAuthEnabled: true, mobileNetworkAuthEnabled: false, success: { (response) in
//            debugPrint(response)
//        }) { (error) in
//
//        }
        
//        AccountService().info(success: { [weak self] (responce) in
//            self?.userInfoResponse = responce as? AccountInfoResponse
//                if self?.userInfoResponse?.accountType == "TURKCELL" {
                    securityCells.append(contentsOf: [TextConstants.settingsViewCellTurkcellPasscode,
                                                      TextConstants.settingsViewCellTurkcellAutoLogin])
//                }
//
//            DispatchQueue.main.async {
                let array = [[TextConstants.settingsViewCellBeckup,
                              TextConstants.settingsViewCellImportPhotos,
                              TextConstants.settingsViewCellAutoUpload],
                             securityCells,
                             [TextConstants.settingsViewCellHelp,
                              TextConstants.settingsViewCellLogout]]
//
                output.cellsDataForSettings(array: array)
//            }
//        }, fail: { [weak self] (error) in
//
//
//        })
    }
    
    func onLogout() {
        let authService = AuthenticationService()
        authService.logout {
            DispatchQueue.main.async { [weak self] in
                self?.passcodeStorage.clearPasscode()
                self?.biometricsManager.isEnabled = false
                CoreDataStack.default.clearDataBase()
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

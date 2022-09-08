//
//  PasscodeSettingsPasscodeSettingsInteractor.swift
//  Depo
//
//  Created by Yaroslav Bondar on 03/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PasscodeSettingsInteractor {
    weak var output: PasscodeSettingsInteractorOutput?
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    private let analyticsManager: AnalyticsService = factory.resolve()
    
    var isEmptyMail: Bool?
    var isTurkcellUser: Bool?
    
    var turkcellPassword: Bool?
    var turkcellLogin: Bool?
    var twoFactorAuthEnabled: Bool?
    
    private var touchIDEnabled: Bool
    private var passcodeEnabled: Bool
    
    init() {
        let isEnabledKey = "isEnabledKey"
        let passcodeKey = "passcodeKey"
        
        if let passcodeKey = UserDefaults.standard.string(forKey: passcodeKey) {
            passcodeEnabled = !passcodeKey.isEmpty
        } else {
            passcodeEnabled = false
        }
        
        touchIDEnabled = UserDefaults.standard.bool(forKey: isEnabledKey)
    }
}

// MARK: PasscodeSettingsInteractorInput
extension PasscodeSettingsInteractor: PasscodeSettingsInteractorInput {
    func clearPasscode() {
        biometricsManager.isEnabled = false
        passcodeStorage.clearPasscode()
    }
    
    func trackScreen() {
        analyticsManager.logScreen(screen: .appTouchIdPasscode)
        analyticsManager.trackDimentionsEveryClickGA(screen: .appTouchIdPasscode)
    }
    
    var biometricsStatus: BiometricsStatus {
        return biometricsManager.status
    }
    
    var isBiometricsEnabled: Bool {
        get { return biometricsManager.isEnabled }
        set { biometricsManager.isEnabled = newValue }
    }
    
    var isAvailableFaceID: Bool {
        return biometricsManager.isAvailableFaceID
    }
    
    var isPasscodeEmpty: Bool {
        return passcodeStorage.isEmpty
    }
    
    var inNeedOfMailVerification: Bool {
        get { return isEmptyMail ?? false }
        set { isEmptyMail = newValue }
    }
    
    var isTurkcellUserFlag: Bool { return isTurkcellUser ?? false }
    
    func requestTurkcellSecurityState() {
        AccountService().securitySettingsInfo(success: { [weak self] response in
            guard
                let unwrapedSecurityresponse = response as? SecuritySettingsInfoResponse,
                let turkCellPasswordOn = unwrapedSecurityresponse.turkcellPasswordAuthEnabled,
                let turkCellAutoLogin = unwrapedSecurityresponse.mobileNetworkAuthEnabled,
                let twoFactorAuthEnabled = unwrapedSecurityresponse.twoFactorAuthEnabled
            else {
                assertionFailure("server returned wrong/updated response")
                return
            }
            
            self?.turkcellPassword = turkCellPasswordOn
            self?.turkcellLogin = turkCellAutoLogin
            self?.twoFactorAuthEnabled = twoFactorAuthEnabled
            
            SingletonStorage.shared.isTwoFactorAuthEnabled = twoFactorAuthEnabled
            
            DispatchQueue.main.async {
                self?.output?.acquiredTurkcellSecurityState(passcode: turkCellPasswordOn,
                                                            autoLogin: turkCellAutoLogin,
                                                            twoFactorAuth: twoFactorAuthEnabled)
            }
            
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.failedToAcquireTurkcellSecurityState()
            }
        })
    }
    
    func changeTurkcellSecurity(passcode: Bool, autoLogin: Bool, twoFactorAuth: Bool) {
        AccountService().securitySettingsChange(turkcellPasswordAuthEnabled: passcode,
                                                mobileNetworkAuthEnabled: autoLogin,
                                                twoFactorAuthEnabled: twoFactorAuth,
                                                success: { [weak self] response in
            guard
                let unwrapedSecurityresponse = response as? SecuritySettingsInfoResponse,
                let turkCellPasswordOn = unwrapedSecurityresponse.turkcellPasswordAuthEnabled,
                let turkCellAutoLogin = unwrapedSecurityresponse.mobileNetworkAuthEnabled,
                let twoFactorAuth = unwrapedSecurityresponse.twoFactorAuthEnabled
            else {
                assertionFailure("server returned wrong/updated response")
                return
            }
                        
            self?.turkcellPassword = turkCellPasswordOn
            self?.turkcellLogin = turkCellAutoLogin
            self?.twoFactorAuthEnabled = twoFactorAuth
                                                    
            SingletonStorage.shared.isTwoFactorAuthEnabled = twoFactorAuth
            
            DispatchQueue.main.async {
                self?.output?.acquiredTurkcellSecurityState(passcode: turkCellPasswordOn,
                                                            autoLogin: turkCellAutoLogin,
                                                            twoFactorAuth: twoFactorAuth)
            }
        },fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.changeTurkcellSecurityFailed(error: error)
            }
        })
    }
    
    var turkcellPasswordOn: Bool {
        return turkcellPassword ?? false
    }
    
    var turkcellAutoLoginOn: Bool {
        return turkcellLogin ?? false
    }
    
    var twoFactorAuth: Bool {
        return twoFactorAuthEnabled ?? false
    }
    
    var isPasscodeEnabled: Bool {
        return touchIDEnabled || passcodeEnabled
    }
}

//
//  LoginSettingsInteractor.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class LoginSettingsInteractor {
    weak var output: LoginSettingsInteractorOutput?
    
    private let analyticsManager: AnalyticsService = factory.resolve()
    
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

// MARK: LoginSettingsInteractorInput
extension LoginSettingsInteractor: LoginSettingsInteractorInput {
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.LoginSettingsScreen())
        analyticsManager.logScreen(screen: .turkcellSecurity)
        analyticsManager.trackDimentionsEveryClickGA(screen: .turkcellSecurity)
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

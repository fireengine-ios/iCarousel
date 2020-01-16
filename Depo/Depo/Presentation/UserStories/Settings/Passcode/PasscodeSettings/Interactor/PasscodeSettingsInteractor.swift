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
}

// MARK: PasscodeSettingsInteractorInput
extension PasscodeSettingsInteractor: PasscodeSettingsInteractorInput {
    func clearPasscode() {
        biometricsManager.isEnabled = false
        passcodeStorage.clearPasscode()
    }
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.PasscodeScreen())
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
}

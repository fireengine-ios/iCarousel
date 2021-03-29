//
//  FastLoginSettings.swift
//  Depo_LifeTech
//
//  Created by Anton Ignatovich on 29.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import DigitalGate

struct FastLoginSettings {
    static let disableCell = true
    static let autoLoginOnly = false
    static let disableAutoLogin = true

    private static var iPadAppId: String {
        return TextConstants.NotLocalized.ipadFastLoginAppIdentifier
    }

    private static var iPhoneAppId: String {
        return TextConstants.NotLocalized.iPhoneFastLoginAppIdentifier
    }

    static var appId: String {
        return Device.isIpad ? iPadAppId : iPhoneAppId
    }

    static var currentFastLoginServerType: DGEnvironment {
        return RouteRequests.currentServerEnvironment == RouteRequests.ServerEnvironment.production ? .prod : .prp
    }

    static var language: String {
        Locale.current.isTurkishLocale ? "TR" : "EN"
    }

    static func setupFastLoginCoordinator(_ loginCoordinator: DGLoginCoordinator) {
        loginCoordinator.appID = FastLoginSettings.appId
        loginCoordinator.language = FastLoginSettings.language
        loginCoordinator.environment = FastLoginSettings.currentFastLoginServerType
        loginCoordinator.disableCell = FastLoginSettings.disableCell
        loginCoordinator.autoLoginOnly = FastLoginSettings.autoLoginOnly
        loginCoordinator.disableAutoLogin = FastLoginSettings.disableAutoLogin
    }
}

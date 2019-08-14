//
//  LoginSettingsRouterInput.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LoginSettingsRouterInput {
    func presentErrorPopup(title: String, message: String, buttonTitle: String, buttonAction: VoidHandler?)
}

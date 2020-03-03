//
//  SettingsSettingsViewInput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SettingsViewInput: class {
    func prepareCellsData(isPermissionShown: Bool)
    func showProfileAlertSheet(userInfo: AccountInfoResponse, isProfileAlert: Bool)
    func updatePhoto(image: UIImage)
    func profileInfoChanged()
    func profileWontChangeWith(error: Error)
    func updateStatusUser()
}

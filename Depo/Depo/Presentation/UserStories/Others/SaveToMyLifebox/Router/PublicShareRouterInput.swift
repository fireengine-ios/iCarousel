//
//  PublicShareRouterInput.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol PublicShareRouterInput: AnyObject {
    func onSelect(item: WrapData, itemCount: Int)
    func onSelect(item: WrapData, items: [WrapData])
    func popToRoot()
    func popViewController()
    func navigateToOnboarding()
    func navigateToAllFiles()
    func navigateToHomeScreen()
    func presentFullQuotaPopup()
    func openFilesToSave(with url: URL)
    func showDownloadCompletePopup(isSuccess: Bool, message: String)
}

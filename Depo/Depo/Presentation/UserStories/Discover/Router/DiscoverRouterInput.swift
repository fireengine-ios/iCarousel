//
//  DiscoverRouterInput.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol DiscoverRouterInput {
    func moveToSettingsScreen()
    func moveToSearchScreen(output: UIViewController?)
    func moveToSyncContacts()
    func moveToAllFilesPage()
    func moveToFavouritsFilesPage()
    func moveToCreationStory()
    func showError(errorMessage: String)
    func showPopupForNewUser(with message: String, title: String, headerTitle: String, completion: VoidHandler?)
    func presentSmallFullOfQuotaPopUp()
    func presentFullOfQuotaPopUp(with type: LargeFullOfQuotaPopUpType)
    func presentEmailVerificationPopUp()
    func presentRecoveryEmailVerificationPopUp()
    func presentCredsUpdateCkeckPopUp(message: String, userInfo: AccountInfoResponse?)
    func presentPopUps()
    func openCampaignDetails()
    func presentMobilePaymentPermissionPopUp(url: String, isFirstAppear: Bool)
    func presentSuccessMobilePaymentPopUp()
    func moveToReferance()
    func openTabBarItem(index: TabScreenIndex, segmentIndex: Int?)
    func presentFullQuotaPopup()
    func presentSecurityInfoViewController()
}

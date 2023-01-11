//
//  DiscoverInteractorOutput.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol DiscoverInteractorOutput: AnyObject {
    func stopRefresh()
    func didObtainError(with text: String, isNeedStopRefresh: Bool)
    func didObtainHomeCards(_ cards: [HomeCardResponse])
    func fillCollectionView(isReloadAll: Bool)
    func didObtainQuotaInfo(usagePercentage: Float)
    func didObtainAccountInfo(accountInfo: AccountInfoResponse)
    func didObtainAccountInfoError(with text: String)
    func didObtainInstaPickStatus(status: InstapickAnalyzesCount)
    func showGiftBox()
    func hideGiftBox()
    func didObtainPermissionAllowance(response: SettingsPermissionsResponse)
    func showSuccessMobilePaymentPopup()
    func showSpinner()
    func hideSpinner()
    func showSnackBarWith(message: String)
    func publicShareSaveSuccess()
    func publicShareSaveFail(message: String)
    func publicShareSaveStorageFail()
}

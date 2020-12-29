//
//  PopUpService.swift
//  Depo_LifeTech
//
//  Created by Oleg on 13.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PopUpService {
    static let shared = PopUpService()
    
    private var getKeyForLoginCountForUser: String {
        return "loginCountForUser" + SingletonStorage.shared.uniqueUserID
    }
    
    func resetLoginCountForUploadOffPopUp() {
        UserDefaults.standard.set(1, forKey: getKeyForLoginCountForUser)
    }
    
    func setLoginCountForShowImmediately() {
        UserDefaults.standard.set(NumericConstants.countOfLoginBeforeNeedShowUploadOffPopUp, forKey: getKeyForLoginCountForUser)
    }
    
    func checkIsNeedShowUploadOffPopUp() {
        SingletonStorage.shared.getAccountInfoForUser(success: { _ in
//            CardsManager.default.startOperationWith(type: .autoUploadIsOff, allOperations: nil, completedOperations: nil)
        }, fail: { _ in })
    }
    
}

//
//  PopUpService.swift
//  Depo_LifeTech
//
//  Created by Oleg on 13.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PopUpService{
    static let shared = PopUpService()
    
    private var getKeyForLoginCountForUser: String{
        return "loginCountForUser" + SingletonStorage.shared.unigueUserID
    }
    
    private func incrementLoginCountForUser(){
        let count = getLoginCountForUser() + 1
        UserDefaults.standard.set(count, forKey: getKeyForLoginCountForUser)
        UserDefaults.standard.synchronize()
    }
    
    private func getLoginCountForUser() -> Int{
        let countOfSuccesfulLoginForUser = UserDefaults.standard.integer(forKey: getKeyForLoginCountForUser)
        return countOfSuccesfulLoginForUser
    }
    
    private func resetLoginCountForUser(){
        UserDefaults.standard.set(0, forKey: getKeyForLoginCountForUser)
        UserDefaults.standard.synchronize()
    }
    
    func checkIsNeedShowUploadOffPopUp(){
        SingletonStorage.shared.getAccountInfoForUser(success: { (success) in
            PopUpService.shared.incrementLoginCountForUser()
            let count = PopUpService.shared.getLoginCountForUser()
            if count >= NumericConstants.countOfLoginBeforeNeedShowUploadOffPopUp {
                WrapItemOperatonManager.default.startOperationWith(type: .autoUploadIsOff , allOperations: nil, completedOperations: nil)
                PopUpService.shared.resetLoginCountForUser()
            }
        }) { (fail) in
            
        }
    }
    
}

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
        let userDef = UserDefaults.standard
        let count = getLoginCountForUser() + 1
        userDef.set(count, forKey: getKeyForLoginCountForUser)
        userDef.synchronize()
    }
    
    private func getLoginCountForUser() -> Int{
        let userDef = UserDefaults.standard
        let countOfSuccesfulLoginForUser = userDef.integer(forKey: getKeyForLoginCountForUser)
        return countOfSuccesfulLoginForUser + 1
    }
    
    private func resetLoginCountForUser(){
        let userDef = UserDefaults.standard
        let number = NSNumber(value: 0)
        userDef.setValue(number, forKey: getKeyForLoginCountForUser)
        userDef.synchronize()
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

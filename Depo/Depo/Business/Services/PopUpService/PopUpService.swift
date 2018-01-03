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
    }
    
    private func getLoginCountForUser() -> Int{
        let countOfSuccesfulLoginForUser = UserDefaults.standard.integer(forKey: getKeyForLoginCountForUser)
        return countOfSuccesfulLoginForUser
    }
    
    func resetLoginCountForUploadOffPopUp(){
        UserDefaults.standard.set(1, forKey: getKeyForLoginCountForUser)
    }
    
    func setLoginCountForShowImmediately(){
        UserDefaults.standard.set(NumericConstants.countOfLoginBeforeNeedShowUploadOffPopUp, forKey: getKeyForLoginCountForUser)
    }
    
    func checkIsNeedShowUploadOffPopUp(){
        SingletonStorage.shared.getAccountInfoForUser(success: { (success) in
            WrapItemOperatonManager.default.startOperationWith(type: .autoUploadIsOff , allOperations: nil, completedOperations: nil)
            
            //Old logic with checking login count
//            let count = PopUpService.shared.getLoginCountForUser()
//            if (count == 0){
//                WrapItemOperatonManager.default.startOperationWith(type: .autoUploadIsOff , allOperations: nil, completedOperations: nil)
//                return
//            }
//            if count >= NumericConstants.countOfLoginBeforeNeedShowUploadOffPopUp {
//                WrapItemOperatonManager.default.startOperationWith(type: .autoUploadIsOff , allOperations: nil, completedOperations: nil)
//                return
//            }
//
//            PopUpService.shared.incrementLoginCountForUser()
        }) { (fail) in
            
        }
    }
    
}

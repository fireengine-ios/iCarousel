//
//  SingletonStorage.swift
//  Depo
//
//  Created by Oleg on 01.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SingletonStorage {
    
    var isAppraterInited: Bool = false
    
    var accountInfo: AccountInfoResponse?
    
    static let shared = SingletonStorage()
    
    func getAccountInfoForUser(success:@escaping (AccountInfoResponse) -> Swift.Void, fail: @escaping (ErrorResponse?) -> Swift.Void ){
        if let info = accountInfo{
            success(info)
        }else{
            AccountService().info(success: { (accountInfoResponce) in
                if let resp = accountInfoResponce as? AccountInfoResponse{
                    self.accountInfo = resp
                    DispatchQueue.main.async {
                        success(resp)
                    }
                }else{
                    DispatchQueue.main.async {
                        fail(nil)
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    fail(error)
                }
            }
        }
    }
    
    var unigueUserID: String{
        return accountInfo?.projectID ?? ""
    }
    
    private var getKeyForLoginCountForUser: String{
        let key = "loginCountForUser" + unigueUserID
        return key
    }
    
    private func incrementLoginCountForUser(){
        let userDef = UserDefaults.standard
        let count = getLoginCountForUser() + 1
        let number = NSNumber(value: count)
        userDef.setValue(number, forKey: getKeyForLoginCountForUser)
        userDef.synchronize()
    }
    
    private func getLoginCountForUser() -> Int{
        let userDef = UserDefaults.standard
        let countOfSuccesfulLoginForUser = userDef.object(forKey: getKeyForLoginCountForUser) as? NSNumber
        return countOfSuccesfulLoginForUser?.intValue ?? 0 + 1
    }
    
    private func resetLoginCountForUser(){
        let userDef = UserDefaults.standard
        let number = NSNumber(value: 0)
        userDef.setValue(number, forKey: getKeyForLoginCountForUser)
        userDef.synchronize()
    }
    
    func checkIsNeedShowUploadOffPopUp(){
        getAccountInfoForUser(success: { (success) in
            SingletonStorage.shared.incrementLoginCountForUser()
            let count = SingletonStorage.shared.getLoginCountForUser()
            if count >= NumericConstants.countOfLoginBeforeNeedShowUploadOffPopUp {
                WrapItemOperatonManager.default.startOperationWith(type: .autoUploadIsOff , allOperations: nil, completedOperations: nil)
                SingletonStorage.shared.resetLoginCountForUser()
            }
        }) { (fail) in
            
        }
    }
    
}

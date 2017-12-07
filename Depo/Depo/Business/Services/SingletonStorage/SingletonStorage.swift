//
//  SingletonStorage.swift
//  Depo
//
//  Created by Oleg on 01.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SingletonStorage: NSObject {
    
    private static var uniqueInstance: SingletonStorage?
    
    var isAppraterInited: Bool = false
    
    var accountInfo: AccountInfoResponse?
    
    private override init() {}
    
    static func shared() -> SingletonStorage {
        if uniqueInstance == nil {
            uniqueInstance = SingletonStorage()
        }
        return uniqueInstance!
    }
    
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
    
    func getUnigueUserID() -> String{
        return accountInfo?.cellografId ?? ""
    }
    
}

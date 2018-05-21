//
//  SingletonStorage.swift
//  Depo
//
//  Created by Oleg on 01.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SingletonStorage {
    
    static let shared = SingletonStorage()
    
    var isAppraterInited: Bool = false
    var accountInfo: AccountInfoResponse?
    var signUpInfo: RegistrationUserInfoModel?
    var referenceToken: String?
    var progressDelegates = MulticastDelegate<OperationProgressServiceDelegate>()
    
    
    func updateAccountInfo() {
        AccountService().info(success: { [weak self] accountInfoResponce in
            if let resp = accountInfoResponce as? AccountInfoResponse {
                self?.accountInfo = resp
            }
            }, fail: { _ in } ) 
    }
    
    func getAccountInfoForUser(success:@escaping (AccountInfoResponse) -> Void, fail: @escaping (ErrorResponse) -> Void ) {
        if let info = accountInfo {
            success(info)
        } else {
            AccountService().info(success: { accountInfoResponce in
                if let resp = accountInfoResponce as? AccountInfoResponse {
                    self.accountInfo = resp
                    //remove user photo from cache on start application
                    ImageDownloder().removeImageFromCache(url: resp.urlForPhoto, completion: {
                        DispatchQueue.toMain {
                            success(resp)
                        }
                    })
                } else {
                    DispatchQueue.toMain {
                        fail(ErrorResponse.string(TextConstants.errorServer))
                    }
                }
            }) { error in
                DispatchQueue.toMain {
                    fail(error)
                }
            }
        }
    }
    
    var uniqueUserID: String {
        return accountInfo?.projectID ?? ""
    }
    
    func getUniqueUserID(success:@escaping ((_ unigueUserID: String) -> Void), fail:@escaping VoidHandler) {
        if !uniqueUserID.isEmpty {
            success(uniqueUserID)
            return
        }
        
        getAccountInfoForUser(success: { info in
            success(info.projectID ?? "")
        }) { error in
            fail()
        }
    }
    
}

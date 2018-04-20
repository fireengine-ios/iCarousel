//
//  UserInfoSubViewUserInfoSubViewInteractor.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UserInfoSubViewInteractor: UserInfoSubViewInteractorInput {

    weak var output: UserInfoSubViewInteractorOutput!

    private var userInfoResponse: AccountInfoResponse? = SingletonStorage.shared.accountInfo
    
    func onStartRequests() {
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: DispatchQueueLabels.getUserInfo)
        
        group.enter()
        group.enter()
        
        AccountService().info(success: { [weak self] response in
            if let userInfo = response as? AccountInfoResponse {
                self?.userInfoResponse = userInfo
                SingletonStorage.shared.accountInfo = userInfo
                DispatchQueue.main.async {
                    self?.output.setUserInfo(userInfo: userInfo)
                }
            }
            group.leave()
            
        }, fail: { [weak self] error in
            self?.output.failedWith(error: error)
            group.leave()
        })
        
        AccountService().quotaInfo(success: { [weak self] response in
            DispatchQueue.main.async {
                self?.output.setQuotaInfo(quotoInfo: response as! QuotaInfoResponse)
            }
            group.leave()
        }, fail: { [weak self] error in
            self?.output.failedWith(error: error)
            group.leave()
        })
        
        group.notify(queue: queue) { [weak self] in
            self?.output.requestsFinished()
        }
    }    
}

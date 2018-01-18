//
//  UserInfoSubViewUserInfoSubViewInteractor.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UserInfoSubViewInteractor: UserInfoSubViewInteractorInput {

    weak var output: UserInfoSubViewInteractorOutput!

    private var userInfoResponse: AccountInfoResponse?
    
    func onStartRequests() {
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "GetUserInfo")
        
        group.enter()
        group.enter()
        
        
        AccountService().info(success: { [weak self] (response) in
            self?.userInfoResponse = response as? AccountInfoResponse
            DispatchQueue.main.async {
                self?.output.setUserInfo(userInfo: response as! AccountInfoResponse)
                group.leave()
            }
        }) { (error) in
            group.leave()
        }
        
        AccountService().quotaInfo(success: { [weak self] (response) in
            DispatchQueue.main.async {
                self?.output.setQuotaInfo(quotoInfo: response as! QuotaInfoResponse)
            }
            group.leave()
        }) { (error) in
            group.leave()
        }
        
        group.notify(queue: queue) { [weak self] in
            self?.output.requestsFinished()
        }
    }
    
}

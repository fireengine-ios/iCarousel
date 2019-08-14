//
//  UserInfoSubViewUserInfoSubViewViewOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol UserInfoSubViewViewOutput {
    
    func reloadUserInfoRequired()
    func loadingIndicatorRequired()
    
    func loadingIndicatorDismissalRequired()
    
    var isPremiumUser: Bool { get }
    var isMiddleUser: Bool { get }
    var quotaInfo: QuotaInfoResponse? { get }
}

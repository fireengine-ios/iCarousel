//
//  PackagesPackagesInteractorOutput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PackagesInteractorOutput: AnyObject {
    func successedGotUserAuthority()
    func failed(with errorMessage: String)
    func setQuotaInfo(quotoInfo: QuotaInfoResponse)
}

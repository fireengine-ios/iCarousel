//
//  UsageInfoInteractorOutput.swift
//  Depo
//
//  Created by Maksim Rahleev on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol UsageInfoInteractorOutput: AnyObject {
    func successed(usage: UsageResponse)
    func failedUsage(with error: ErrorResponse)
}

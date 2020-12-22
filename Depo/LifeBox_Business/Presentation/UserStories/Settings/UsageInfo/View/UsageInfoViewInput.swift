//
//  UsageInfoViewInput.swift
//  Depo
//
//  Created by Maksim Rahleev on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol UsageInfoViewInput: class, Waiting {
    func display(usage: UsageResponse)
    func display(error: ErrorResponse)
}

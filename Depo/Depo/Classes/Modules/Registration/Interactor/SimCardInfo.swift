//
//  SimCardInfo.swift
//  Depo
//
//  Created by Aleksandr on 6/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import CoreTelephony

class SimCardInfo {
    static func isSimDetected() -> Bool {
        let simInfo = CTTelephonyNetworkInfo()

        let carrier: CTCarrier? = simInfo.subscriberCellularProvider
        
        if (carrier?.isoCountryCode != nil) {
            return true
        }
        return false
    }
}

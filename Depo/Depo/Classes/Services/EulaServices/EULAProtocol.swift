//
//  EULAProtocol.swift
//  Depo
//
//  Created by Oleg on 14.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

typealias SuccesEULABlock = (_ eula:Eula ) -> Swift.Void
typealias FailBlock = (_ fail:String) -> Swift.Void

protocol EULAProtocol {
    
    func requestEulaForLocale(localeString: String, success: @escaping SuccesEULABlock, fail:@escaping FailBlock)
    
}


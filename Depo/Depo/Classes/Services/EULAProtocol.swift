//
//  EULAProtocol.swift
//  Depo
//
//  Created by Oleg on 14.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol EULAProtocol {
    
    func requestEulaForLocale(success:@escaping (Eula)-> (), fail:@escaping (String)->())
    
}


//
//  PrintInteractorOutput.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 17.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol PrintInteractorOutput: AnyObject {
    
    func urlDidForm(urlRequest: URLRequest)

    func failedToCreateFormData()
    
}

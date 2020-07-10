//
//  OperationProgressService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 12/11/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol OperationProgressServiceDelegate: class {
    func didSend(ratio: Float, bytes: Int, for url: URL)
}

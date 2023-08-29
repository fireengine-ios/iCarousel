//
//  PhotoPrintViewInput.swift
//  Depo
//
//  Created by Ozan Salman on 22.08.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

protocol PhotoPrintViewInput: AnyObject, Waiting {
    func didFinishedAllRequests()
}

//
//  DiscoverViewInput.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol DiscoverViewInput: AnyObject, Waiting {
    func didFinishedAllRequests()
    func stopRefresh()
}

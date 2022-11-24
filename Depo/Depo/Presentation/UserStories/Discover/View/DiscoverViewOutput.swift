//
//  DiscoverViewOutput.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol DiscoverViewOutput: AnyObject {
    func viewIsReady()
    func getModelCards() -> Any?
    func navigate(for view: HomeCardTypes)
}

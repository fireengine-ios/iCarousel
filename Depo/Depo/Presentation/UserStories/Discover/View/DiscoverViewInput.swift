//
//  DiscoverViewInput.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol DiscoverViewInput: AnyObject, CurrentNavController {
    func stopRefresh()
    func startSpinner()
    func needShowSpotlight(type: SpotlightType)
    func showGiftBox()
    func hideGiftBox()
    func closePermissionPopUp()    
    func showSnackBarWithMessage(message: String)
}

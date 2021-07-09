//
//  UploadFromLifeBoxViewIO.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol UploadFromLifeBoxViewInput: AnyObject {
    func getNavigationController() -> UINavigationController?
    func getDestinationUUID() -> String
    func hideView()
    func showOutOfSpaceAlert()
}

//protocol UploadFromLifeBoxViewOutput: AnyObject {
//    func viewIsReady()
//}

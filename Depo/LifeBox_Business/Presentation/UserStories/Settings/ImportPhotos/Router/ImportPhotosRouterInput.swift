//
//  ImportPhotosRouterInput.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

//protocol ImportFromFBRouterInput {
//    func goToOnboarding()
//}
//
//protocol ImportFromDropboxRouterInput {
//    func goToOnboarding()
//}

protocol ImportFromInstagramRouterInput {
    func openInstagramAuth(param: InstagramConfigResponse, delegate: InstagramAuthViewControllerDelegate?)
}

//
//  ForYouViewInput.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol ForYouViewInput: AnyObject, Waiting {
    func getFIRResponse(isAllowed: Bool)
    func didFinishedAllRequests()
    func didGetUpdateData()
    func saveCardFailed(section: ForYouSections)
}

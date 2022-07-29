//
//  ForYouViewOutput.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol ForYouViewOutput: AnyObject {
    func onSeeAllButton(for view: ForYouViewEnum)
    func checkFIRisAllowed()
}

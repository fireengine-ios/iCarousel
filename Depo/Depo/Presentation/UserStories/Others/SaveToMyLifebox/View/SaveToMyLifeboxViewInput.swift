//
//  SaveToMyLifeboxViewInput.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol SaveToMyLifeboxViewInput: AnyObject, Waiting {

    func sharedItemsDidGet(items: [SharedFileInfo])
}

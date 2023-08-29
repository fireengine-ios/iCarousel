//
//  PhotoPrintRouter.swift
//  Depo
//
//  Created by Ozan Salman on 22.08.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class PhotoPrintRouter: PhotoPrintRouterInput {
    
    private let router = RouterVC()
    weak var presenter: PhotoPrintPresenter!
}

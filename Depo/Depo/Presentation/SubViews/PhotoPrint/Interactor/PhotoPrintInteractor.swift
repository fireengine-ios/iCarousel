//
//  PhotoPrintInteractor.swift
//  Depo
//
//  Created by Ozan Salman on 22.08.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class PhotoPrintInteractor {
    weak var output: PhotoPrintInteractorOutput!
    private let service = PhotoPrintService()
    private var address: [AddressResponse]?
}

extension PhotoPrintInteractor: PhotoPrintInteractorInput {
    func viewIsReady() {
    }
}

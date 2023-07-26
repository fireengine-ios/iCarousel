//
//  StringConstants.swift
//  Depo
//
//  Created by Ozan Salman on 11.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

struct StringConstants {
    static var collageName: String = localized(.createCollagePreviewMainTitle)
    static var createCollageSelectPhotoType = PhotoSelectType.newPhotoSelection //New -> new select photo, Change-> change selected photo
    static var onlyOfficeCreateFile: Bool = false
    static var onlyOfficeDocumentsFilter: Bool = true
}

struct CreateCollageConstants {
    static var selectedChangePhotoItems = [SearchItemResponse]()
}

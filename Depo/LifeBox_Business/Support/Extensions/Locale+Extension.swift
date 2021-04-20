//
//  Locale+Extension.swift
//  Depo
//
//  Created by Anton Ignatovich on 17.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

extension Locale {
    var isTurkishLocale: Bool {
        return Locale.current.languageCode?.lowercased().elementsEqual("tr") ?? false
    }
}

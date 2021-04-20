//
//  LifeboxWidget.swift
//  LifeboxWidget
//
//  Created by Roman Harhun on 29/08/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import WidgetKit
import SwiftUI
import KeychainSwift

@main
struct LIfeWidget: Widget {
    private static let key = "LifeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.key, provider: WidgetProvider()) { entry in
            WidgetView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .description(TextConstants.widgetDescription)
        .configurationDisplayName(TextConstants.widgetDisplayName)
    }
}

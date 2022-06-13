//
//  ImageTextSelectionData.swift
//  Depo
//
//  Created by Hady on 1/13/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

public struct ImageTextSelectionData {
    /// The **sorted** list of recognized lines.
    public let lines: [RecognizedLine]
    /// The **sorted** list of recognized words.
    public let words: [RecognizedText]

    public init(lines: [RecognizedLine]) {
        self.lines = lines
        self.words = lines.reduce([]) { $0 + $1.words }
    }

    public static var empty: ImageTextSelectionData {
        ImageTextSelectionData(lines: [])
    }
}

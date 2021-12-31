//
//  RecognizedBlock.swift
//  TextSelection
//
//  Created by Hady on 12/30/21.
//

import Foundation

struct RecognizedBlock {
    let lines: [RecognizedLine]

    var firstLine: RecognizedLine {
        return lines.first!
    }

    var lastLine: RecognizedLine {
        return lines.last!
    }
}

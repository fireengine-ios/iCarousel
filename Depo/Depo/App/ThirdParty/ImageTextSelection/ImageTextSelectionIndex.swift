//
//  ImageTextSelectionIndex.swift
//  TextSelection
//
//  Created by Hady on 1/4/22.
//

import Foundation

struct ImageTextSelectionIndex: Comparable, Equatable {
    let line: Int
    let word: Int

    static func == (lhs: ImageTextSelectionIndex, rhs: ImageTextSelectionIndex) -> Bool {
        return lhs.line == rhs.line && lhs.word == rhs.word
    }

    static func < (lhs: ImageTextSelectionIndex, rhs: ImageTextSelectionIndex) -> Bool {
        if lhs.line == rhs.line {
            return lhs.word < rhs.word
        }

        return lhs.line < rhs.line
    }
}

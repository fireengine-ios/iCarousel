//
//  ToolbarButtonOptions.swift
//  Mantis
//
//  Created by Echo on 5/30/20.
//

import Foundation

public struct ToolbarButtonOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static public let counterclockwiseRotate = ToolbarButtonOptions(rawValue: 1 << 0)
    static public let clockwiseRotate = ToolbarButtonOptions(rawValue: 1 << 1)
    static public let reset = ToolbarButtonOptions(rawValue: 1 << 2)
    static public let ratio = ToolbarButtonOptions(rawValue: 1 << 3)
    
    static public let `default`: ToolbarButtonOptions = [counterclockwiseRotate, reset, ratio]
    static public let all: ToolbarButtonOptions = [counterclockwiseRotate, clockwiseRotate, reset, ratio]
}

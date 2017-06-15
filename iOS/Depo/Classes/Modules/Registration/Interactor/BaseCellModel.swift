//
//  BaseCellModel.swift
//  Depo
//
//  Created by Aleksandr on 6/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class BaseCellModel {
    var title = ""
    var inputText = ""
    var type: CellTypes = .base
    
    init(withTitle title: String, initialText text: String, cellType type: CellTypes) {
        self.title = title
        self.inputText = text
        self.type = type
    }
    
}

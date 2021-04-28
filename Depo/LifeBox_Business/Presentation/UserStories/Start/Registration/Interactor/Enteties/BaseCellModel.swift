//
//  BaseCellModel.swift
//  Depo
//
//  Created by Aleksandr on 6/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

struct BaseCellModel {
    let title: String
    let inputText: String
    
    
    init(withTitle title: String, initialText text: String) {
        self.title = title
        self.inputText = text
    }
    
}

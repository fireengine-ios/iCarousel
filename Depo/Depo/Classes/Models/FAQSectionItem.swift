//
//  FAQSectionItem.swift
//  Depo
//
//  Created by Ryhor on 25.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class FAQSectionItem {

    var selected: Bool
    var name: String = ""

    init(title: String) {
        name = title
        selected = false;
    }
    
}

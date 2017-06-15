//
//  LoginDataStorage.swift
//  Depo
//
//  Created by Oleg on 13.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class LoginDataStorage: NSObject {
    var loginModels:[BaseCellModel] = []
    
    override init(){
        let names = [NSLocalizedString("E-Mail or GSM Number", comment: ""),
                     NSLocalizedString("Password", comment: "")]
        let defaultTexts = [NSLocalizedString("E-Mail or GSM Number", comment: ""),
                            NSLocalizedString("", comment: "")]
        let cellTypes = [CellTypes.base, CellTypes.base]
        
        for i in 0...names.count - 1{
            let model = BaseCellModel(withTitle: names[i], initialText: defaultTexts[i], cellType: cellTypes[i])
            loginModels.append(model)
        }
    }
    
    func getModels()->[BaseCellModel]{
        return loginModels
    }
}

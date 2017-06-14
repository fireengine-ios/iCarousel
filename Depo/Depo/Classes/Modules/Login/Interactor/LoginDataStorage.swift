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
        
        for i in 1...names.count{
            let model = BaseCellModel(withTitle: names[i - 1], initialText: "", cellType: CellTypes.base)
            loginModels.append(model)
        }
    }
    
    func getModels()->[BaseCellModel]{
        return loginModels
    }
}

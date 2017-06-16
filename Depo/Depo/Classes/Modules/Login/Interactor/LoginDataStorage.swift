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
        
        loginModels.append(BaseCellModel(withTitle: TextConstants.loginCellTitleEmail,
                                         initialText: TextConstants.loginCellEmailPlaceholder))
        
        loginModels.append(BaseCellModel(withTitle: TextConstants.loginCellTitlePassword,
                                         initialText: TextConstants.loginCellPasswordPlaceholder))
        
        super.init()
    }
    
    func getModels()->[BaseCellModel]{
        return loginModels
    }
}

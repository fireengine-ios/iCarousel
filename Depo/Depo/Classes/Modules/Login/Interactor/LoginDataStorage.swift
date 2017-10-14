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
    
    var blockedUsers: NSMutableDictionary? {
        get {
            guard let blockedUsers = UserDefaults.standard.value(forKey: "BlockedUsers") as? NSMutableDictionary else {
                return nil
            }
            return blockedUsers
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "BlockedUsers")
        }
    }
    
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

//
//  EULA.swift
//  Depo
//
//  Created by Oleg on 14.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class EULA: NSObject, EULAProtocol, DaoDelegate {
    
    let eulaDao = EulaDao()
    var success:((Eula)->())?
    var fail:((String)->())?
    
    func requestEulaForLocale(success:@escaping (Eula)-> (), fail:@escaping (String)->()){
        self.eulaDao.delegate = self
        self.success = success
        self.fail = fail
        self.eulaDao.requestEula(forLocale: Util.readLocaleCode())
    }
    
    //MARK: EULADao delegate
    
    func onSucces(_ successObject: NSObject!) {
        let eula = successObject as! Eula
        guard let s:((Eula) ->()) = self.success else {
            return
        }
        s(eula)
    }
    
    func onFail(_ failString: String!) {
        guard let f:((String) ->()) = self.fail else {
            return
        }
        f(failString)
    }
    
}

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
    
    var success: SuccesEULABlock?
    var fail: FailBlock?
    
    func requestEulaForLocale(localeString: String, success: @escaping SuccesEULABlock, fail:@escaping FailBlock){
        self.eulaDao.delegate = self
        self.success = success
        self.fail = fail
        self.eulaDao.requestEula(forLocale: localeString)
    }
    
    //MARK: EULADao delegate
    
    func onSucces(_ successObject: NSObject!) {
        guard let eula = successObject as? Eula else{
            self.fail?("wrong type of answer")
            return
        }
        self.success?(eula)
    }
    
    func onFail(_ failString: String!) {
        self.fail?(failString)
    }
    
}

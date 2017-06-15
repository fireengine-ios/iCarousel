//
//  EULA.swift
//  Depo
//
//  Created by Oleg on 14.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class EULA: NSObject, EULAProtocol, DaoDelegate {
    
    private let eulaDao = EulaDao()
    
    internal var successBl: SuccesEULABlock?
    internal var failBl: FailBlock?
    
    func requestEulaForLocale(localeString: String, success: @escaping SuccesEULABlock, fail:@escaping FailBlock){
        self.eulaDao.delegate = self
        successBl = success
        failBl = fail
        self.eulaDao.requestEula(forLocale: localeString)
    }
    
    //MARK: EULADao delegate
    
    func onSucces(_ successObject: NSObject!) {
        guard let eula = successObject as? Eula else{
            failBl?(NSLocalizedString(TextConstants.serverResponceError, comment: ""))
            return
        }
        successBl?(eula)
    }
    
    func onFail(_ failString: String!) {
        failBl?(failString)
    }
    
}

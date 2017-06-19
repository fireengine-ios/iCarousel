//
//  SignUp.swift
//  Depo
//
//  Created by Aleksandr on 6/18/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

//eula.requestEulaForLocale(localeString: Util.readLocaleCode(), success: {[weak self] (eula) in
//    DispatchQueue.main.async {
//        self?.output.showLoadedTermsAndUses(eula: eula)
//    }
//}) { [weak self] (failString) in
//    DispatchQueue.main.async {
//        self?.output.failLoadTermsAndUses(errorString: failString)
//    }
//}
//import SignUp
class SignUp: NSObject, SignUpProtocol, DaoDelegate { //TODO: Rewrite current dao, remove nsobject dependency
    func requestTriggerSignup(withEmail email: String, phoneNumber phone: String, _ password: String, _ eulaID: String, SignUpSuccesCallback succesCalback: SuccesCallback?, SignUpFailCallback failCallback: FailCallback?) {
        
    }

    func onSucces(_ successObject: NSObject!) {
        
    }
    
    func onFail(_ failString: String!) {
        
    }
}

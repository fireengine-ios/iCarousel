//
//  SignUpProtocol.swift
//  Depo
//
//  Created by Aleksandr on 6/18/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol SignUpProtocol {
//    - (void) requestTriggerSignupForEmail:(NSString *) email forPhoneNumber:(NSString *) phoneNumber withPassword:(NSString *) password withEulaId:(int) eulaId {

    typealias SuccesCallback = (_ result: Any) -> Void
    typealias FailCallback = (_ response: URLResponse) -> Void
    func requestTriggerSignup(withEmail email: String, phoneNumber phone: String, _ password: String, _ eulaID: String, SignUpSuccesCallback succesCalback: SuccesCallback?, SignUpFailCallback failCallback: FailCallback?)
    
}

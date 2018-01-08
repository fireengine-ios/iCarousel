//
//  AuthenticationServiceResponse.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/27/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON

class ObjectRequestResponse: ObjectFromRequestResponse {
    var json: JSON?
    var response: HTTPURLResponse?
    var jsonString: String?
    
    required init(json: Data?, headerResponse: HTTPURLResponse?) {
        if let data = json {
            let jsonFromData:JSON = JSON(data: data)
            self.json = jsonFromData
            
            /// JSON(data: data) can not correct string
            if ((json?.count)!>0  && jsonFromData.type == Type.null){
                jsonString = String.init(data: json! as Data, encoding: .utf8)
            }
            
        } else {
            self.json = nil
        }
        response = headerResponse
        mapping()
    }
    
    required init(withJSON: JSON?) {
        self.json = withJSON
        self.response = nil
        mapping()
    }
    
    init() {

    }
    
    func mapping() {}
    
    var isOkStatus: Bool {
        
        guard let status = json?[LbResponseKey.status].string else {
                return false
        }
        return Bool(status.uppercased() == "OK")
    }
    
    var valueDict: [String : JSON]? {
        
        guard let value = json?[LbResponseKey.value].dictionary else {
            return nil
        }
        return value
    }
    
    var responseHeader: [AnyHashable:Any]? {
        return response?.allHeaderFields
    }
}

class LoginResponse: ObjectRequestResponse {
    
    var rememberMeToken: String?
    var token: String?
    var newUser: Bool?
    var migration: Bool?
    var accountWarning: String?

    override func mapping() {

        rememberMeToken = self.responseHeader?[HeaderConstant.RememberMeToken] as? String
        
        //Need set remember me Token because we need to store it.
        //As we can understand API documentation, we should receive it but server did not send X-Remember-Me-Token in remember me login method
        if (rememberMeToken == nil){
            rememberMeToken = ApplicationSession.sharedSession.session.rememberMeToken
        }
        
        token = self.responseHeader?[HeaderConstant.AuthToken] as? String
        newUser = self.responseHeader?[HeaderConstant.newUser] as? Bool
        migration = self.responseHeader?[HeaderConstant.migration] as? Bool
        accountWarning = self.responseHeader?[HeaderConstant.accountWarning] as? String
    }
}

class FailLoginResponse: ObjectRequestResponse {
    
    override func mapping() {
    }
}

class SignUpSuccessResponse: ObjectRequestResponse {
    
    var action : String?
    var referenceToken : String?
    var remainingTimeInMinutes : Int?
    var expectedInputLength : Int?
    
    override func mapping(){
        if (isOkStatus && valueDict != nil) {
            action = valueDict![LbResponseKey.action]?.string
            referenceToken = valueDict![LbResponseKey.referenceToken]?.string
            remainingTimeInMinutes = valueDict![LbResponseKey.remainingTimeInMinutes]?.int
            expectedInputLength = valueDict![LbResponseKey.expectedInputLength]?.int
        }
    }
}

class SignUpFailResponse:ObjectRequestResponse {
    override func mapping() {
    }
}

enum ExpectedDataFormat {
    case JSONFormat
    case DataFormat
    case NoneFormat
}

class BaseResponseHandler <SuceesObj:ObjectFromRequestResponse, FailObj:ObjectFromRequestResponse> {
    
    var response: RequestResponse {
        return wrapRequestResponse
    }
    
    private var success:SuccessResponse?
    private var fail: FailResponse?
    private let expectedDataFormat: ExpectedDataFormat
    
    lazy var wrapRequestResponse: RequestResponse = { (data, response, error) in
        
        if self.notError(error: error) {
            self.handleSuccess(data: data, response: response)
        }
    }
    
    init(success:SuccessResponse?, fail: FailResponse?, expectedDataFormat: ExpectedDataFormat = .JSONFormat) {
        self.expectedDataFormat = expectedDataFormat
        self.success = success
        self.fail = fail
    }
    
    private func notError(error: Error?) -> Bool {
        guard let err = error else  {
            return true
        }
        fail?(.error(err))
        return false
    }
    
    private func handleSuccess(data: Data?, response:URLResponse?) {
        if let httpResponse = response as? HTTPURLResponse {
            if 200...299 ~= httpResponse.statusCode {
                
                switch expectedDataFormat {
                    case .JSONFormat, .DataFormat:
                        let sucessObj = SuceesObj(json: data, headerResponse: httpResponse)
                        success?(sucessObj)
                        return
                    case .NoneFormat: break
                }

            } else if let data = data {
                if let value = JSON(data: data)["value"].string {
                    let error = ServerValueError(value: value, code: httpResponse.statusCode)
                    fail?(.error(error))
                } else if let status = JSON(data: data)["status"].string {
                    let error = ServerStatusError(status: status, code: httpResponse.statusCode)
                    fail?(.error(error))
                } else if let text = String(data: data, encoding: .utf8) {
                    fail?(.string(text))
                }
            } else {
                fail?(.httpCode(httpResponse.statusCode))
            }
        }
    }
}



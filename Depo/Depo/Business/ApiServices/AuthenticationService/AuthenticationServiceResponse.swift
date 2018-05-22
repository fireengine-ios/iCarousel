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
            let jsonFromData: JSON = JSON(data: data)
            self.json = jsonFromData
            
            /// JSON(data: data) can not correct string
            if ((json?.count)!>0 && jsonFromData.type == Type.null) {
                jsonString = String(data: json! as Data, encoding: .utf8)
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
    
    var valueDict: [String: JSON]? {
        
        guard let value = json?[LbResponseKey.value].dictionary else {
            return nil
        }
        return value
    }
    
    var responseHeader: [AnyHashable: Any]? {
        return response?.allHeaderFields
    }
}

extension JsonMap where Self: ObjectRequestResponse {
    init?(json: JSON) {
        self.init(withJSON: json)
    }
}

class SignUpSuccessResponse: ObjectRequestResponse {
    
    var action: String?
    var referenceToken: String?
    var remainingTimeInMinutes: Int?
    var expectedInputLength: Int?
    
    override func mapping() {
        if (isOkStatus && valueDict != nil) {
            action = valueDict![LbResponseKey.action]?.string
            referenceToken = valueDict![LbResponseKey.referenceToken]?.string
            remainingTimeInMinutes = valueDict![LbResponseKey.remainingTimeInMinutes]?.int
            expectedInputLength = valueDict![LbResponseKey.expectedInputLength]?.int
        }
    }
}

class SignUpFailResponse: ObjectRequestResponse {
    override func mapping() {
    }
}

enum ExpectedDataFormat {
    case JSONFormat
    case DataFormat
    case NoneFormat
}

class BaseResponseHandler <SuceesObj: ObjectFromRequestResponse, FailObj: ObjectFromRequestResponse> {
    
    var response: RequestResponse {
        return wrapRequestResponse
    }
    
    private var success: SuccessResponse?
    private var fail: FailResponse?
    private let expectedDataFormat: ExpectedDataFormat
    
    lazy var wrapRequestResponse: RequestResponse = { data, response, error in
        self.handleResponse(data: data, response: response, error: error)
    }
    
    init(success: SuccessResponse?, fail: FailResponse?, expectedDataFormat: ExpectedDataFormat = .JSONFormat) {
        self.expectedDataFormat = expectedDataFormat
        self.success = success
        self.fail = fail
    }

    private func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        if let httpResponse = response as? HTTPURLResponse {
            if 200...299 ~= httpResponse.statusCode {
                
                switch expectedDataFormat {
                    case .JSONFormat, .DataFormat:
                        DispatchQueue.toBackground { [weak self] in
                            let sucessObj = SuceesObj(json: data, headerResponse: httpResponse)
                            DispatchQueue.toMain {
                                self?.success?(sucessObj)
                            }
                        }
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
                } else if let message = JSON(data: data)["errorMsg"].string {
                    let error = ServerMessageError(message: message, code: httpResponse.statusCode)
                    fail?(.error(error))
                } else {
                    #if DEBUG
                        if let text = String(data: data, encoding: .utf8) {
                            fail?(.string(text))
                        } else {
                            fail?(.string(TextConstants.errorServer))
                        }
                    #else
                        fail?(.string(TextConstants.errorServer))
                    #endif
                }
            } else {
                fail?(.httpCode(httpResponse.statusCode))
            }
        } else if let error = error {
            fail?(.error(error))
        }
    }
}

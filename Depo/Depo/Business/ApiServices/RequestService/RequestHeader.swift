//
//  RequestHeader.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/27/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

typealias RequestHeaderParametrs = [String: String]

struct HeaderConstant {
    
    static let Accept = "Accept"
    static let ApplicationJson = "application/json"
    
    static let ContentType = "Content-Type"
    static let ContentRange = "Content-Range"
    static let ApplicationJsonUtf8 = "application/json; encoding=utf-8"
    
    
    static let XMetaStrategy = "X-Meta-Strategy"
    static let XMetaRecentServerHash = "X-Meta-Recent-Server-Hash"
    static let XObjectMetaFileName = "X-Object-Meta-File-Name"
    static let XObjectMetaParentUuid = "X-Object-Meta-Parent-Uuid"
    static let XObjectMetaFavorites = "X-Object-Meta-Favourite"
    static let Expect = "Expect"
    
    static let XObjectMetaSpecialFolder = "X-Object-Meta-Special-Folder"
    
    static let ContentLength = "Content-Length"
    static let XObjectMetaIosMetadataHash = "X-Object-Meta-Ios-Metadata-Hash"
    static let XObjectMetaDeviceType = "X-Object-Meta-Device-Type"
//    static let XObjectMetaAlbumLabel = "X-Object-Meta-Album-Label"
//    static let XObjectMetaFolderLabel = "X-Object-Meta-Folder-Label"
//    static let Etag = "ETag"
    
    static let CaptchaId = "X-Captcha-Id"
    static let CaptchaAnswer = "X-Captcha-Answer"
    
    static let AuthToken = "X-Auth-Token"
    static let RememberMeToken = "X-Remember-Me-Token"
    static let migration = "X-Migration-User"
    static let accountWarning = "X-Account-Warning"
    
    static let Authorization = "Authorization"
    
    static let emptyMSISDN = "EMPTY_MSISDN"
    static let emptyEmail = "EMPTY_EMAIL"
    
    static let objecMetaDevice = "X-Object-Meta-Device-UUID"
    
    static let transId = "X-Trans-Id"
    
    static let silentToken = "X-Silent-Token"
    static let accountStatus = "X-Account-Status"
}

class RequestHeaders {
    
    private static let tokenStorage: TokenStorage = factory.resolve()
    
    static func captchaHeader(id: String, answer: String) -> RequestHeaderParametrs {
        return [ HeaderConstant.CaptchaId     : id,
                 HeaderConstant.CaptchaAnswer : answer]
    }
    
    static func base() -> RequestHeaderParametrs {
        return [ HeaderConstant.Accept      : HeaderConstant.ApplicationJson,
                 HeaderConstant.ContentType : HeaderConstant.ApplicationJsonUtf8]
    }
    
    static func authification() -> RequestHeaderParametrs {
        var result = base()
        if let accessToken = tokenStorage.accessToken {
            result = result + [HeaderConstant.AuthToken: accessToken]
        }
        return result 
    }
    
    static func authificationWithCaptcha(id: String, answer: String)  -> RequestHeaderParametrs {
        return RequestHeaders.authification() + RequestHeaders.captchaHeader(id: id, answer: answer)
    }
    
    static func authificationByRememberMe() -> RequestHeaderParametrs {
        var result = base()
        #if MAIN_APP
        debugLog("authificationByRememberMe()")

        #endif
        if let refreshToken = tokenStorage.refreshToken {
            result = result + [HeaderConstant.RememberMeToken: refreshToken]
        }
        return result
    }
    
    static func logout() -> RequestHeaderParametrs {
        var result = authification()
        result = result + authificationByRememberMe()
        return result
    }

}

//
//  RequestHeader.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/27/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

struct HeaderConstant {
    
    static let Accept = "Accept"
    static let ApplicationJson = "application/json"
    
    static let ContentType = "Content-Type"
    static let ApplicationJsonUtf8 = "application/json; encoding=utf-8"
    static let ApplicationImagePng = "image/png"
    static let ApplicationAudioWave  = "audio/wave"
    
    static let ContentLength = "Content-Length"
    static let XMetaStrategy = "X-Meta-Strategy"
    static let XMetaRecentServerHash = "X-Meta-Recent-Server-Hash"
    static let XObjectMetaFileName = "X-Object-Meta-File-Name"
    static let XObjectMetaParentUuid = "X-Object-Meta-Parent-Uuid"
    static let XObjectMetaSpecialFolder = "X-Object-Meta-Special-Folder"
    static let XObjectMetaIosMetadataHash = "X-Object-Meta-Ios-Metadata-Hash"
    static let XObjectMetaAlbumLabel = "X-Object-Meta-Album-Label"
    static let XObjectMetaFolderLabel = "X-Object-Meta-Folder-Label"
    static let XObjectMetaFavorites = "X-Object-Meta-Favourite"
    static let Expect = "Expect"
    static let Etag = "ETag"
    
    static let CaptchaId = "X-Captcha-Id"
    static let CaptchaAnswer = "X-Captcha-Answer"
    
    static let AuthToken = "X-Auth-Token"
    static let RememberMeToken = "X-Remember-Me-Token"
    static let newUser = "X-New-User"
    static let migration = "X-Migration-User"
    static let accountWarning = "X-Account-Warning"
    
    static let Authorization = "Authorization"

}

class RequestHeaders {
    
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
        let token = ApplicationSession.sharedSession.session.authToken ?? ""
        result = result + [HeaderConstant.AuthToken : token]
        return result 
    }
    
    static func authificationByRememberMe() -> RequestHeaderParametrs {
        var result = base()
        let token = ApplicationSession.sharedSession.session.rememberMeToken ?? ""
        result = result + [HeaderConstant.RememberMeToken : token]
        return result
    }
    
    static func logout() -> RequestHeaderParametrs {
        var result = authification()
        result = result + authificationByRememberMe()
        return result
    }

}



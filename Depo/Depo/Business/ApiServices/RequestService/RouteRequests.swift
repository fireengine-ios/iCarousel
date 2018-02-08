//
//  RouteRequests.swift
//  Depo
//
//  Created by Alexander Gurin on 6/20/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

struct RouteRequests {
    
    // MARK: Authentication
    
    static let BaseUrl: URL = URL(string: "https://adepo.turkcell.com.tr/")!
    static let BaseContactsUrl: URL = URL(string: "https://contactsync.turkcell.com.tr/ttyapi/")!
    static let NewURL: URL = URL(string: "https://mylifebox.com/")!
    
    static let httpAuthification = "http://adepo.turkcell.com.tr/api/auth/gsm/login?rememberMe=%@"
    static let httpsAuthification = "/api/auth/token?rememberMe=%@"
    static let authificationByRememberMe = "/api/auth/rememberMe"
    static let authificationByToken = "/api/auth/token"
    static let signUp = "/api/signup"
    static let logout = "/api/auth/logout"
    
    static let phoneVerification = "/api/verify/phoneNumber"
    static let resendVerificationSMS = "api/verify/sendVerificationSMS"
    
    static let forgotPassword = "/api/account/forgotPassword"
    static let mailVerefication = "/api/verify/sendVerificationEmail"
    static let mailUpdate = "/api/account/email"
    
    //MARK: EULA 
    static let eulaGet     = "api/eula/get/%@"
    static let eulaCheck   = "api/eula/check/%@"
    static let eulaApprove = "api/eula/approve/%i"
    
    // MARK: Dropbox
    
    static let dropboxAuthUrl: URL = URL(string: "https://api.dropboxapi.com/1/oauth2/token_from_oauth1")!
    static let dropboxConnect = "api/migration/dropbox/connect?accessToken=%@"
    static let dropboxStatus  = "api/migration/dropbox/status"
    static let dropboxStart   = "api/migration/dropbox/start"
    
    // MARK: - FB
    static let fbPermissions = "api/migration/facebook/permissions"
    static let fbConnect     = "api/migration/facebook/connect?accessToken=%@"
    static let fbStatus      = "api/migration/facebook/status"
    static let fbStart       = "api/migration/facebook/start"
    static let fbStop        = "api/migration/facebook/stop"
    
    //MARK: -  Instagram
    static let socialStatus = "/api/share/social/status"
    static let instagramConfig = "/api/share/social/instagram/config"
    static let instagramSyncStatus = "/api/share/social/instagram/syncStatus"
    static let instagramCreateMigration = "/api/share/social/instagram/migration/create"
    static let instagramCancelMigration = "/api/share/social/instagram/migration/cancel"
    
    // MARK: Captcha
    
    static let captcha = "/api/captcha/%@/%@"
    
    
    //MARK: Search
    
    static let search = "/api/search/byField?fieldName=%@&fieldValue=%@&sortBy=%@&sortOrder=%@&page=%@&size=%@"
    
    static let advanceSearch = "/api/search/unified?text=%@&sortBy=%@&sortOrder=%@&page=%d&size=%d"
    static let unifiedSearch = "/api/search/unified?text=%@&category=%@&page=%@&size=%@"
    static let unifiedSearchWithoutCategory = "/api/search/unified?text=%@&page=%@&size=%@"
    static let suggestion    = "/api/search/unified/suggest?text=%@"
    
    // MARK: Album
    
    static let albumList    = "/api/album?contentType=%@&page=%@&size=%@&sortBy=%@&sortOrder=%@"
    static let details      = "/api/album/%@?page=%@&size=%@&sortBy=%@&sortOrder=%@"
    
    // MARK: My Streams
    
    static let people = "/api/person/"
    static let things = "/api/object/"
    static let places = "/api/location/"
    
    //MARK : Share
    
    static let share = "/api/share/%@"
    
    //MARK : Faq 
    
    static let faqUrl = "api/faq/url/%@"

    //MARK: - Contacts
    static let getContacts = "contact?sortField=firstname&sortOrder=ASC&maxResult=16&currentPage=%d"
    static let searchContacts = "search?sortField=firstname&sortOrder=ASC&maxResult=16&query=%@&currentPage=%d"
    static let deleteContacts = "contact"
    
    
    struct HomeCards {
        static let all = BaseUrl +/ "api/assistant/v1"
        static func card(with id: Int) -> URL {
            return all +/ String(id)
        }
    }
}

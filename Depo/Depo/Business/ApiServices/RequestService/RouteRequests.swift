//
//  RouteRequests.swift
//  Depo
//
//  Created by Alexander Gurin on 6/20/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

struct RouteRequests {
    
    enum ServerEnvironment {
        case test
        case preProduction
        case production
    }
    
    // MARK: Environment

    static var currentServerEnvironment: ServerEnvironment = .production

    private static let applicationTarget = TextConstants.NotLocalized.appName
    
    static var baseShortUrlString: String {
        switch currentServerEnvironment {
        case .test: return "https://tcloudstb.turkcell.com.tr/"
        case .preProduction: return "https://adepotest.turkcell.com.tr/"
        case .production: return "https://adepo.turkcell.com.tr/"
        }
    }
    
    static var baseUrl: URL {
        return URL(string: "\(baseShortUrlString)api/")!
    }
    
    static var unsecuredAuthenticationUrl: String {
        switch currentServerEnvironment {
        case .test: return "http://tcloudstb.turkcell.com.tr/api/auth/gsm/login?rememberMe=%@"
        case .preProduction: return "http://adepotest.turkcell.com.tr/api/auth/gsm/login?rememberMe=%@"
        case .production: return "http://adepo.turkcell.com.tr/api/auth/gsm/login?rememberMe=%@"
        }
    }
    
    static var baseContactsUrl: URL {
        switch currentServerEnvironment {
        case .test: return URL(string: "https://tcloudstb.turkcell.com.tr/ttyapi/")!
        case .preProduction: return URL(string: "https://adepotest-contactsync.turkcell.com.tr/ttyapi/")!
        case .production: return URL(string: "https://contactsync.turkcell.com.tr/ttyapi/")!
        }
    }
    
    static var launchCampaignDetail: URL? {
        switch currentServerEnvironment {
        case .test:
            return URL(string: "https://prv.turkcell.com.tr/kampanyalar/diger-kampanyalarimiz/lifebox-cekilis-kampanyasi")
        case .preProduction:
            return URL(string: "https://prv.turkcell.com.tr/kampanyalar/diger-kampanyalarimiz/lifebox-cekilis-kampanyasi")
        case .production:
            return URL(string: "https://www.turkcell.com.tr/kampanyalar/diger-kampanyalarimiz/lifebox-cekilis-kampanyasi")
        }
    }
    
    static var privacyPolicy: String {
        switch currentServerEnvironment {
        case .test: return "https://adepotest.turkcell.com.tr/policy/?lang="
        case .preProduction: return "https://adepotest.turkcell.com.tr/policy/?lang="
        case .production: return "https://mylifebox.com/policy/?lang="
        }
    }
    
    static var silentLogin: String { return RouteRequests.baseShortUrlString + "api/auth/silent/token?rememberMe=on" }
    
    // MARK: Authentication
    
    static let httpsAuthification = "auth/token?rememberMe=%@"
    static let authificationByRememberMe = "auth/rememberMe"
    static let signUp = "signup"
    static let logout = "auth/logout"
    
    static let phoneVerification = "verify/phoneNumber"
    static let resendVerificationSMS = "verify/sendVerificationSMS"
    
    static let forgotPassword = "account/forgotPassword"
    static let mailVerification = "verify/sendVerificationEmail"
    static let mailUpdate = "account/email"
    
    static var twoFactorAuthChallenge: URL { return baseUrl +/ "auth/2fa/challenge" }
    static var twoFactorAuthLogin: URL { return baseUrl +/ "auth/2fa/token" }

    // MARK: EULA 
    static var eulaGet: String { return "eula/get/%@?brand=" + applicationTarget }
    static let eulaCheck   = "eula/check/%@"
    static let eulaApprove = "eula/approve"
    static var eulaGetEtkAuth: URL { return baseUrl +/ "eula/getEtkAuth" }
    static var eulaGetGlobalPermAuth: URL { return baseUrl +/ "eula/getGlobalPermAuth" }
    
    //MARK: Social Connections
    static let socialStatus = "share/social/status"
    
    // MARK: Dropbox
    static let dropboxAuthUrl: URL = URL(string: "https://api.dropboxapi.com/1/oauth2/token_from_oauth1")!
    static let dropboxConnect = "migration/dropbox/connect?accessToken=%@"
    static var dropboxDisconnect: URL { return baseUrl +/ "migration/dropbox/disconnect" }
    static let dropboxStatus  = "migration/dropbox/status"
    static let dropboxStart   = "migration/dropbox/start"
    
    // MARK: - FB
    static let fbPermissions = "migration/facebook/permissions"
    static let fbConnect     = "migration/facebook/connect?accessToken=%@"
    static var fbDisconnect: URL { return baseUrl +/ "connect/c/facebook" }
    static let fbStatus      = "migration/facebook/status"
    static let fbStart       = "migration/facebook/start"
    static let fbStop        = "migration/facebook/stop"
    
    // MARK: - Instagram
    static let instagramConfig = "share/social/instagram/config"
    static var instagramConnect: URL { return baseUrl +/ "share/social/instagram/connect" }
    static var instagramDisconnect: URL { return baseUrl +/ "share/social/instagram/disconnect" }
    static let instagramSyncStatus = "share/social/instagram/syncStatus"
    static let instagramCreateMigration = "share/social/instagram/migration/create"
    static let instagramCancelMigration = "share/social/instagram/migration/cancel"
    
    // MARK: Captcha
    
    static let captcha = "captcha/%@/%@"
    
    static let captchaRequired = "captcha/required"
    
    // MARK: Search
    
    static let search = "search/byField?fieldName=%@&fieldValue=%@&sortBy=%@&sortOrder=%@&page=%@&size=%@"
    
    static let advanceSearch = "search/unified?text=%@&sortBy=%@&sortOrder=%@&page=%d&size=%d"
    static let unifiedSearch = "search/unified?text=%@&category=%@&page=%@&size=%@"
    static let unifiedSearchWithoutCategory = "search/unified?text=%@&page=%@&size=%@"
    static let suggestion    = "search/unified/suggest?text=%@"
    
    // MARK: Album
    
    static let albumList    = "album?contentType=%@&page=%@&size=%@&sortBy=%@&sortOrder=%@"
    static let details      = "album/%@?page=%@&size=%@&sortBy=%@&sortOrder=%@"
    
    // MARK: My Streams
    
    static let people = "person/"
    static let peopleThumbnails = "person/thumbnails"
    static let peoplePage = "person/page?pageSize=%d&pageNumber=%d"
    static let peopleAlbum = "album?contentType=album/person&sortBy=createdDate&sortOrder=DESC&page=0&size=1&personInfoId=%d"
    static let peopleAlbums = "person/relatedAlbums/%d"
    static let personVisibility = "person/visibility/"
    static let peopleSearch = "person/label/%@"
    static let peopleMerge = "person/%d"
    static let peopleChangeName = "person/label/%d"
    static let peopleDeletePhotos = "person/photo/delete/%d"
//    static let peopleDeletePhoto = "/person/photo/%d/%d"
    static let things = "object/"
    static let thingsThumbnails = "object/thumbnails"
    static let thingsPage = "object/page?pageSize=%d&pageNumber=%d"
    static let thingsAlbum = "album?contentType=album/object&sortBy=createdDate&sortOrder=DESC&page=0&size=1&objectInfoId=%d"
    static let thingsDeletePhotos = "object/photo/%d"
//    static let thingsDeletePhoto = "object/photo/%d/%d"
    static let places = "location/"
    static let placesThumbnails = "location/thumbnails"
    static let placesPage = "location/page?pageSize=%d&pageNumber=%d"
    static let placesAlbum = "album?contentType=album/location&sortBy=createdDate&sortOrder=DESC&page=0&size=1&locationInfoId=%d"
//    static let placesDeletePhotos = "location/%d"
    
    //MARK : Share
    static let share = "share/%@"
    
    //MARK: Feedback
    static var feedbackEmail: URL { return baseUrl +/ "feedback/contact-mail" }
    
    //MARK : Faq 
    static let faqContentUrl = "https://mylifebox.com/faq/?lang=%@"

    // MARK: - Contacts
    static let getContacts = "contact?sortField=firstname&sortOrder=ASC&maxResult=32&currentPage=%d"
    static let searchContacts = "search?sortField=firstname&sortOrder=ASC&maxResult=16&query=%@&currentPage=%d"
    static let deleteContacts = "contact"
    
    // MARK: - Quick Scroll

    static let quickScrollGroups = "scroll/groups"
    static let quickScrollGroupsList = "scroll/groups/list"
    static let quickScrollRangeList = "scroll/range/list"
    
    // MARK: - Spotify
    
    enum Spotify {
        static var spotifyApi: URL { return baseUrl +/ "migration/spotify" }
        static var connect: URL { return spotifyApi +/ "connect" }
        static var disconnect: URL { return spotifyApi +/ "disconnect" }
        static var start: URL { return spotifyApi +/ "start" }
        static var stop: URL { return spotifyApi +/ "stop" }
        static var authorizeUrl: URL { return spotifyApi +/ "authorizeUrl" }
        static var status: URL { return spotifyApi +/ "status" }
        static var playlists: URL { return spotifyApi +/ "playlist" }
        static var tracks: URL { return playlists +/ "track" }
        static var importedPlaylists: URL { return spotifyApi +/ "provider/playlist" }
        static var importedTracks: URL { return importedPlaylists +/ "track" }
    }
    
    //MARK: - Turkcell Updater
    
    static func updaterUrl() -> String {
        #if LIFEBOX
            let jsonName = "download/update_ios.json"
        #elseif LIFEDRIVE
            let jsonName = "download/update_lifedrive_ios.json"
        #else
            let jsonName = "unknown"
            debugPrint("⚠️: unknown turkcell updater url")
        #endif
        
        return baseShortUrlString + jsonName
    }
    
    struct HomeCards {
        static var all: URL { return baseUrl +/ "assistant/v1" }
        static func card(with id: Int) -> URL {
            return all +/ String(id)
        }
    }
    
    /// upload
    static var uploadContainer: URL { return baseUrl +/ "container/baseUrl" }
    static let uploadNotify = "notification/onFileUpload?parentFolderUuid=%@&fileName=%@"
    
    static var updateLanguage: URL { return baseUrl +/ "account/language" }
    
    enum Account {
        static var accountApi: URL { return baseUrl +/ "account" }
        
        static var updatePassword: URL { return accountApi +/ "updatePassword" }
        static var updateBirthday: URL { return accountApi +/ "birthday" }
        static var getFaqUrl: URL { return accountApi +/ "faq" }
        
        enum Settings {
            static var settingsApi: URL { return Account.accountApi +/ "setting" }/// without "s" at the end
            
            static var accessInformation: URL { return baseUrl +/ "account/setting" }
            static var facebookTaggingEnabled: URL { return settingsApi +/ "facebookTaggingEnabled" }
        }
        
        enum Permissions {
            static var authority: URL { return Account.accountApi +/ "authority" }
            static var featurePacks: URL { return Account.accountApi +/ "feature-packs/IOS" }
            static var availableOffers: URL { return  Account.accountApi +/ "available-offers/IOS" }
            static var features: URL { return  baseUrl +/ "features" }
            
            static var permissionsList: URL { return  Account.accountApi +/ "permission/list" }
            static var permissionsUpdate: URL { return  Account.accountApi +/ "permission/update" }
        }
    }
    
    enum Instapick {
        static var instapickApi: URL { return baseUrl +/ "instapick" }
        static var thumbnails: URL { return instapickApi +/ "thumbnails" }
        static var analyzesCount: URL { return instapickApi +/ "getCount" }
        static var analyze: URL { return instapickApi +/ "analyze" }
        static var analyzeHistory: URL { return instapickApi +/ "getAnalyzeHistory" }
        static var analyzeDetails: URL { return instapickApi +/ "getAnalyzeDetails" }
        static var removeAnalyzes: URL { return instapickApi +/ "deleteAnalyze" }
    }

    static var launchCampaignImage: URL { return baseUrl.deletingLastPathComponent() +/ "assets/images/campaign/lansmanm1.jpg" }
    
    static let turkcellAndGroupCompanies = "https://www.turkcell.com.tr/tr/hakkimizda/genel-bakis/istiraklerimiz"
    
    static var globalPermissionsDetails: String {
        switch currentServerEnvironment {
        case .production: return "https://mylifebox.com/portal/global_ops.html?lang=\(Device.locale)"
        case .preProduction: return "https://adepotest.turkcell.com.tr/portal/global_ops.html?lang=\(Device.locale)"
        case .test: return ""
        }   
    }
    
    static var verifyEmail: URL { return  baseUrl +/ "verify/emailAddress" }
    static var sendEmailVerificationCode: URL { return  baseUrl +/ "verify/sendVerificationEmail" }
}

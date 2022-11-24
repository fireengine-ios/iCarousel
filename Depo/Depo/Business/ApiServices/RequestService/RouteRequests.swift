//
//  RouteRequests.swift
//  Depo
//
//  Created by Alexander Gurin on 6/20/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

struct RouteRequests {
    
    static let isBillo: Bool = {
        #if LIFEDRIVE
        return true
        #else
        return false
        #endif
    }()
    
    enum ServerEnvironment {
        case test
        case preProduction
        case production
    }
    
    // MARK: Environment
    
    static var currentServerEnvironment = ServerEnvironment.test
    private static let applicationTarget = TextConstants.NotLocalized.appName
    
    static let baseShortUrlString: String = {
        switch currentServerEnvironment {
        case .test: return "https://adepodev.turkcell.com.tr/"
        case .preProduction: return "https://adepotest.turkcell.com.tr/"
        case .production: return "https://adepo.turkcell.com.tr/"
        }
    }()
    
    static let paycellShortUrlString: String = {
        switch currentServerEnvironment {
        case .test: return "https://tcloudstb.turkcell.com.tr/"
        case .preProduction: return "https://adepotest.turkcell.com.tr/"
        case .production: return "https://mylifebox.com/"
        }
    }()
    
    static let baseUrl = URL(string: "\(baseShortUrlString)api/")!
        
    static let baseContactsUrl: URL = baseContactsUrlShort +/ "ttyapi/"
    
    static let baseContactsUrlShort: URL = {
        switch currentServerEnvironment {
        case .test: return URL(string: "https://adepodev-contactsync.turkcell.com.tr/")!
        case .preProduction: return URL(string: "https://adepotest-contactsync.turkcell.com.tr/")!
        case .production: return URL(string: "https://contactsync.turkcell.com.tr/")!
        }
    }()
    
    static let launchCampaignDetail: URL? = {
        switch currentServerEnvironment {
        case .test:
            return URL(string: "https://prv.turkcell.com.tr/kampanyalar/diger-kampanyalarimiz/lifebox-cekilis-kampanyasi")
        case .preProduction:
            return URL(string: "https://prv.turkcell.com.tr/kampanyalar/diger-kampanyalarimiz/lifebox-cekilis-kampanyasi")
        case .production:
            return URL(string: "https://www.turkcell.com.tr/kampanyalar/diger-kampanyalarimiz/lifebox-cekilis-kampanyasi")
        }
    }()

    static let chatbotCookieDomain: String = {
        switch currentServerEnvironment {
        case .test: return "chatbottest.turkcell.com.tr"
        case .preProduction: return "dsschatbot.turkcell.com.tr"
        case .production: return "dsschatbot.turkcell.com.tr"
        }
    }()

    static let chatbotBaseDomain: String = {
        switch currentServerEnvironment {
        case .test: return "https://chatbottest.turkcell.com.tr/index.html?"
        case .preProduction: return "https://dsschatbot.turkcell.com.tr/index.html?"
        case .production: return "https://dsschatbot.turkcell.com.tr/index.html?"
        }
    }()
    
    static let dynamicLinkDomain: String = {
        if isBillo {
            return "https://billo.page.link"
        } else {
            switch currentServerEnvironment {
            case .test: return "https://testlifebox.page.link"
            case .preProduction: return "https://testlifebox.page.link"
            case .production: return "https://mylifebox.page.link"
            }
        }
    }()
    
    static let appLinkDomain: String = {
        return "https://mylifeboxpaycell.dre.agconnect.link"
    }()

    private static let privacyPolicySubDomain = "privacyPolicy/get/\(Device.locale)?brand=" + applicationTarget
    static let privacyPolicy = URL(string: privacyPolicySubDomain, relativeTo: baseUrl)!

    static let silentLogin: String = RouteRequests.baseShortUrlString + "api/auth/silent/token?rememberMe=on"

    // MARK: Authentication
    
    static let httpsAuthification = "auth/token?rememberMe=%@"
    static let authificationByRememberMe = "auth/rememberMe"
    static let signUp = baseUrl +/ "v2/signup"
    static let signUpSendVerification = baseUrl +/ "v2/signup/sendVerification"
    static let signUpValidateOTP = baseUrl +/ "v2/signup/validate"
    static let logout = "auth/logout"

    static let forgotPassword = "account/forgotPassword"

    static let mailVerification = "verify/sendVerificationEmail"
    static let mailUpdate = "account/email"
    
    static let twoFactorAuthChallenge = baseUrl +/ "auth/2fa/challenge"
    static let twoFactorAuthLogin = baseUrl +/ "auth/2fa/token"

    enum ForgotMyPassword {
        static let link = baseUrl +/ "account/forgotMyPassword"
        static let sendEmail = baseUrl +/ "forgotMyPassword/sendEmail"
        static let sendRecoveryEmail = baseUrl +/ "forgotMyPassword/sendRecoveryEmail"
        static let sendSMS = baseUrl +/ "forgotMyPassword/sendSms"
        static let validatePhoneNumber = baseUrl +/ "forgotMyPassword/validatePhoneNumber"
        static let checkStatus = baseUrl +/ "forgotMyPassword/checkStatus"
        static let continueWithEmail = baseUrl +/ "forgotMyPassword/continueWithEmail"
        static let continueWithRecoveryEmail = baseUrl +/ "forgotMyPassword/continueWithRecoveryEmail"
        static let validateSecurityQuestion = baseUrl +/ "forgotMyPassword/validateSecurityQuestion"
        static let change = baseUrl +/ "forgotMyPassword/change"
    }

    // MARK: EULA 
    static let eulaGet     = "eula/get/%@?brand=" + applicationTarget
    static let eulaCheck   = "eula/check/%@"
    static let eulaApprove = "eula/approve"
    static let eulaGetEtkAuth = baseUrl +/ "eula/getEtkAuth/v2"
    static let eulaGetGlobalPermAuth = baseUrl +/ "eula/getGlobalPermAuth"
    
    //MARK: Social Connections
    static let socialStatus = "share/social/status"
    
    // MARK: Dropbox
    static let dropboxAuthUrl: URL = URL(string: "https://api.dropboxapi.com/1/oauth2/token_from_oauth1")!
    static let dropboxConnect = "migration/dropbox/connect?accessToken=%@"
    static let dropboxConnectV2 = "migration/dropbox/connect/v2"
    static let dropboxDisconnect = baseUrl +/ "migration/dropbox/disconnect"
    static let dropboxStatus  = "migration/dropbox/status"
    static let dropboxStart   = "migration/dropbox/start"
    
    // MARK: - FB
    static let fbPermissions = "migration/facebook/permissions"
    static let fbConnect     = "migration/facebook/connect?accessToken=%@"
    static let fbDisconnect  =  baseUrl +/ "connect/c/facebook"
    static let fbStatus      = "migration/facebook/status"
    static let fbStart       = "migration/facebook/start"
    static let fbStop        = "migration/facebook/stop"
    
    // MARK: - Instagram
    static let instagramConfig = "share/social/instagram/config/v2"
    static let instagramConnect =  baseUrl +/ "share/social/instagram/connect/v2"
    static let instagramDisconnect =  baseUrl +/ "share/social/instagram/disconnect"
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
    static let albumListWithStatus = baseUrl.absoluteString + albumList + "&status=%@"
    static let details      = "album/%@?page=%@&size=%@&sortBy=%@&sortOrder=%@&count=false"
    static let albumHide = baseUrl +/ "album/hide"
    static let albumRecover = baseUrl +/ "album/recover"
    
    // MARK: My Streams
    
    // FIXME: pass paramaerts as request paramerts
    static let people = "person/"
    static let peopleThumbnails = "person/thumbnails"
    static let peoplePage = "person/page?pageSize=%d&pageNumber=%d"
    static let peoplePageWithStatus = baseUrl.absoluteString + peoplePage + "&status=%@"
    static let peopleAlbum = "album?contentType=album/person&sortBy=createdDate&sortOrder=DESC&page=0&size=1&personInfoId=%d&count=false"
    static let peopleAlbumWithStatus = baseUrl.absoluteString + peopleAlbum + "&status=%@"
    static let peopleAlbums = "person/relatedAlbums/%d"
    static let personVisibility = "person/visibility/"
    static let peopleSearch = "person/label/%@"
    static let peopleMerge = "person/%d"
    static let peopleChangeName = "person/label/%d"
    static let peopleDeletePhotos = "person/photo/delete/%d"
    static let peopleRecovery = baseUrl.absoluteString + people + "recover"
    static let peopleTrash = baseUrl.absoluteString + people + "trash"
    static let peopleDelete = baseUrl.absoluteString + people + "delete"
    static let peoplePhotoWithMedia = people + "media?fileUuid=%@"
    static let peopleChangeThumbnail = people + "thumbnail/%d"
//    static let peopleDeletePhoto = "/person/photo/%d/%d"
    static let things = "object/"
    static let thingsThumbnails = "object/thumbnails"
    static let thingsPage = "object/page?pageSize=%d&pageNumber=%d"
    static let thingsPageWithStatus = baseUrl.absoluteString + thingsPage + "&status=%@"
    static let thingsAlbum = "album?contentType=album/object&sortBy=createdDate&sortOrder=DESC&page=0&size=1&objectInfoId=%d&count=false"
    static let thingsAlbumWithStatus = baseUrl.absoluteString + thingsAlbum + "&status=%@"
    static let thingsDeletePhotos = "object/photo/%d"
    static let thingsRecovery = baseUrl.absoluteString + things + "recover"
    static let thingsTrash = baseUrl.absoluteString + things + "trash"
    static let thingsDelete = baseUrl.absoluteString + things + "delete"
//    static let thingsDeletePhoto = "object/photo/%d/%d"
    static let places = "location/"
    static let placesThumbnails = "location/thumbnails"
    static let placesPage = "location/page?pageSize=%d&pageNumber=%d"
    static let placesPageWithStatus = baseUrl.absoluteString + placesPage + "&status=%@"
    static let placesAlbum = "album?contentType=album/location&sortBy=createdDate&sortOrder=DESC&page=0&size=1&locationInfoId=%d&count=false"
    static let placesAlbumWithStatus = baseUrl.absoluteString + placesAlbum + "&status=%@"
    static let placesRecovery = baseUrl.absoluteString + places + "recover"
    static let placesTrash = baseUrl.absoluteString + places + "trash"
    static let placesDelete = baseUrl.absoluteString + places + "delete"
//    static let placesDeletePhotos = "location/%d"
    
    //MARK : Share
    static let share = "share/%@"
    
    //MARK: Feedback
    static let feedbackEmail = baseUrl +/ "feedback/contact-mail"
    static let feedbackLog = baseUrl +/ "feedback/log"
    
    //MARK : Faq
    static var faqContentUrl: String {
        switch currentServerEnvironment {
        case .production: return isBillo ? "https://mybilloapp.com/faq/?lang=%@)" :
                                           "https://mylifebox.com/faq/?lang=%@"
            
        case .preProduction: return isBillo ? "https://prp.mylifebox.com/faq/?lang=%@" :
                                              "https://mylifebox.com/faq/?lang=%@"
            
        case .test: return isBillo ? "https://dev.mylifebox.com/faq/?lang=%@" :
                                     "https://mylifebox.com/faq/?lang=%@"
        }
    }

    // MARK: - Contacts
    static let getContacts = "contact?sortField=firstname&sortOrder=ASC&maxResult=32&currentPage=%d"
    static let searchContacts = "search?sortField=firstname&sortOrder=ASC&maxResult=16&query=%@&currentPage=%d"
    static let deleteContacts = "contact"
    
    enum ContactSync {
        static let contactAPI = baseContactsUrlShort +/ "ttyapi"
        static let contact = contactAPI +/ "contact"
        static let search = contactAPI +/ "search"
        static let backup = contactAPI +/ "backup_version"
        static let backupContacts = baseContactsUrlShort.absoluteString + "ttyapi/backup_version/%d"
    }
    
    // MARK: - Quick Scroll

    static let quickScrollGroups = "scroll/groups"
    static let quickScrollGroupsList = "scroll/groups/list"
    static let quickScrollRangeList = "scroll/range/list"
    
    // MARK: - Spotify
    
    enum Spotify {
        static let spotifyApi = baseUrl +/ "migration/spotify"
        static let connect = spotifyApi +/ "connect"
        static let disconnect = spotifyApi +/ "disconnect"
        static let start = spotifyApi +/ "start"
        static let stop = spotifyApi +/ "stop"
        static let authorizeUrl = spotifyApi +/ "authorizeUrl"
        static let status = spotifyApi +/ "status"
        static let playlists = spotifyApi +/ "playlist"
        static let tracks = playlists +/ "track"
        static let importedPlaylists = spotifyApi +/ "provider/playlist"
        static let importedTracks = importedPlaylists +/ "track"
    }
    
    // MARK: - Smash
    
    static let smashAnimation = baseUrl +/ "external/file/list"
    // MARK: - Campaign
    
    static let campaignApi = baseUrl +/ "campaign"
    static let campaignPhotopick = campaignApi +/ "photopick/v2"
    
    
    //MARK: - Private Share
    
    enum PrivateShare {
        static let suggestions = baseUrl +/ "invitees"
        static let share = baseUrl +/ "shares"
        
        enum Shared {
            private static let baseShares = share.absoluteString
            static let withMe = baseShares + "?sharedWith=me&size=%d&page=%d&sortBy=%@&sortOrder=%@&objectType=FILE"
            static let byMe = baseShares + "?sharedBy=me&size=%d&page=%d&sortBy=%@&sortOrder=%@&objectType=FILE"
            //"https://run.mocky.io/v3/8d9274fb-3149-452b-9d7f-ef8b1ea20195"//
        }
    }
    
    //MARK: - Save To My Lifebox
    static let publicShareItemList = baseUrl.absoluteString + "share/public/list?publicToken=%@&language=tr&sortBy=%@&sortOrder=%@&page=%d&size=%d"
    static let publicShareInnerFolder = "%@&sortBy=%@&sortOrder=%@&page=%d&size=%d"
    static let publicShareSave = baseUrl.absoluteString + "share/save?publicToken=%@"
    static let publicShareDownloadLink = baseUrl.absoluteString + "share/public/downloadFilesAsZip?publicToken=%@"
    static let publicSharedItemsCount = baseUrl.absoluteString + "share/public/count?publicToken=%@"
    
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
        static let all = baseUrl +/ "assistant/v1"
        static func card(with id: Int) -> URL {
            return all +/ String(id)
        }
    }

    // MARK: - Print
    enum Print {
        private static let printApi = baseUrl +/ "sosyopix"

        static let log = printApi +/ "history"
    }
    
    /// upload
    static let uploadContainer = baseUrl +/ "container/baseUrl"
    static let uploadNotify = "notification/onFileUpload?parentFolderUuid=%@&fileName=%@"
    
    static let updateLanguage = baseUrl +/ "account/language"
    
    enum Account {
        static let accountApi = baseUrl +/ "account"
        
        static let updatePassword = accountApi +/ "updatePassword"
        static let updatePasswordV2 = baseUrl +/ "v2/account/updatePassword"
        static let updateBirthday = accountApi +/ "birthday"
        static let getFaqUrl = accountApi +/ "faq"

        static let getSecurityQuestion = baseUrl +/ "securityQuestion/%@"
        static let updateSecurityQuestion = accountApi +/ "updateSecurityQuestion"
        static let updateInfoFeedback = accountApi +/ "updateInfoFeedback"
        static let updateAddress = accountApi +/ "address"
        static let info = accountApi +/ "info"
        static let ticket = accountApi +/ "ticket"

        static let delete = accountApi +/ "delete"

        enum Settings {
            /// without "s" at the end
            static let settingsApi = Account.accountApi +/ "setting" 
            
            static let accessInformation = baseUrl +/ "account/setting"
            static let facebookTaggingEnabled = settingsApi +/ "facebookTaggingEnabled"
            static let autoSyncStatus = settingsApi +/ "autoSyncStatus"
        }
        
        enum Permissions {
            static let authority = Account.accountApi +/ "authority"
            static let featurePacks = Account.accountApi +/ "feature-packs/IOS"
            static let featurePacksV2 = Account.accountApi +/ "feature-packs/v2/IOS"
            static let availableOffers = Account.accountApi +/ "available-offers/IOS"
            static let features = baseUrl +/ "features"
            
            static let permissionsList = Account.accountApi +/ "permission/list"
            static let permissionWithType = Account.accountApi.absoluteString + "/permission/list?permissionType=%@"
            static let permissionsUpdate = Account.accountApi +/ "permission/update"
            static let mobilePaymentPermissionFeedback = Account.accountApi +/ "updateMobilePaymentPermissionFeedback"
        }
    }
    
    enum Instapick {
        static let instapickApi = baseUrl +/ "instapick"
        static let thumbnails = instapickApi +/ "thumbnails"
        static let analyzesCount = instapickApi +/ "getCount"
        static let analyze = instapickApi +/ "analyze"
        static let analyzeHistory = instapickApi +/ "getAnalyzeHistory"
        static let analyzeDetails = instapickApi +/ "getAnalyzeDetails"
        static let removeAnalyzes = instapickApi +/ "deleteAnalyze"
    }
    
    enum FileSystem {
        static let fileList = "filesystem?parentFolderUuid=%@&sortBy=%@&sortOrder=%@&page=%@&size=%@&folderOnly=%@"
        static let trashedList = "filesystem/trashed?parentFolderUuid=%@&sortBy=%@&sortOrder=%@&page=%@&size=%@&folderOnly=%@"
        static let hiddenList = baseUrl.absoluteString + "filesystem/hidden?sortBy=%@&sortOrder=%@&page=%@&size=%@&category=photos_and_videos"
        
        static let filesystemBase = "filesystem/"
        
        static let create = filesystemBase + "createFolder?parentFolderUuid=%@"
        static let delete = filesystemBase + "delete"
        static let rename = filesystemBase + "rename/%@"
        static let move = filesystemBase + "move?targetFolderUuid=%@"
        static let copy = filesystemBase + "copy?targetFolderUuid=%@"
        static let details = filesystemBase + "details?minified=true"
        static let detail = filesystemBase + "detail/%@"
        static let metaData = filesystemBase + "metadata"
        static let description = (baseUrl +/ metaData).absoluteString + "/%@"
        static let trash = filesystemBase + "trash"
        static let emptyTrash = baseUrl +/ "trash/empty"
        static let hide = baseUrl +/ (filesystemBase + "hide")
        static let recover = (baseUrl +/ filesystemBase) +/ "recover"
        
        enum Version_2 {
            private static let baseV2Url = baseUrl +/ "v2/files/%@"
            static let baseV2UrlString = baseV2Url.absoluteString
            private static let baseV2UrlBulk = baseUrl +/ "v2/files/_bulk"
            
            static let filesFromFolder = baseV2UrlString + "?size=%d&page=%d&sortBy=%@&sortOrder=%@&parentFolderUuid=%@"
            static let sharingInfo = baseV2UrlString + "/%@"
            static let shareAcls = baseV2UrlString + "/%@/acls"
            static let shareAcl = shareAcls + "/%d"
            static let leaveShare = baseV2UrlString + "/%@/acls?subjectType=USER&subjectId=%@"
            static let rename = sharingInfo + "/name"
            
            static let createDownloadUrl = baseV2UrlBulk +/ "create-download-url"
            static let move = baseV2UrlBulk +/ "move"
            static let delete = baseV2UrlBulk +/ "delete"
            static let trash = baseV2UrlBulk +/ "trash"
        }
    }

    // MARK:- Invitation

    enum Invitation {
        static let link = baseUrl +/ "invitation/link"
        static let campaign = baseUrl +/ String(format: "invitation/detail/%@", Device.locale)
        static let acceptedInvitationList = "invitation/registered?pageNumber=%d&pageSize=%d"
        static let subscriptions = baseUrl +/ "invitation/subscriptions"
    }

    static let launchCampaignImage = baseUrl.deletingLastPathComponent() +/ "assets/images/campaign/lansmanm1.jpg"
    
    static let turkcellAndGroupCompanies = "https://www.turkcell.com.tr/tr/hakkimizda/genel-bakis/istiraklerimiz"
    
    static let turkcellPermissionsPolicy = "https://www.turkcell.com.tr/tr/hakkimizda/duyurular/izin-politikasi"
    
    static var globalPermissionsDetails: String {
        switch currentServerEnvironment {
        case .production: return isBillo ? "https://mybilloapp.com/global_ops.html?lang=\(Device.locale)" :
                                           "https://mylifebox.com/portal/global_ops.html?lang=\(Device.locale)"
                                            
        case .preProduction: return isBillo ? "https://prp.mylifebox.com/global_ops.html?lang=\(Device.locale)" :
                                "https://adepotest.turkcell.com.tr/portal/global_ops.html?lang=\(Device.locale)"
            
        case .test: return isBillo ? "https://dev.mylifebox.com/global_ops.html?lang=\(Device.locale)" :  ""
        }
    }
    
    static let verifyEmail = baseUrl +/ "verify/emailAddress"
    static let sendEmailVerificationCode = baseUrl +/ "verify/sendVerificationEmail"
    static let verifyRecoveryEmail = baseUrl +/ "verify/recoveryEmailAddress"
    static let sendRecoveryEmailVerificationCode = baseUrl +/ "verify/sendVerificationRecoveryEmail"

    static let healthCheck = baseUrl +/ "health/check"
    
    static let paycellWebUrl = paycellShortUrlString + "#!/settings/packages?cpcmOfferId=%d&redirect_uri=https://google.com"

    static let resolveDeepLink = baseUrl +/ "deeplink"

    // MARK: - Map
    static let map = "map/%f,%f/%f,%f/%d"
    static let mapList = "map/list/%@?page=%d&size=%d"

    // MARK: - OCR
    static let ocrProcess = baseUrl +/ "ocr/process"
    
    // MARK: - Google Login
    static let googleLogin = "auth/google?rememberMe=true"
    static let googleLoginStatus = baseUrl +/ "google/login/status"
    static let googleLoginDisconnect = baseUrl +/ "google/login/disconnect"
    static let googleLoginConnect = baseUrl +/ "google/login/connect"
    
    // MARK: - Apple Login
    static let appleLogin = "auth/apple?rememberMe=true"
    static let appleLoginStatus = baseUrl +/ "apple/login/status"
    static let appleLoginDisconnect = baseUrl +/ "apple/login/disconnect"
    static let appleLoginConnect = baseUrl +/ "apple/login/connect"
    
    // MARK: - Paycell Campaign
    static let paycellLink = baseUrl +/ "paycell/link"
    static let paycellDetail = baseUrl +/ "paycell/detail/\(Device.locale)"
    static let paycellConsent = baseUrl +/ "paycell/consent"
    static let paycellGain = baseUrl +/ "paycell/gain"
    static let paycellAcceptedFriends = "paycell/sold?pageNumber=%d&pageSize=%d"
    
    // MARK: - For You
    static let forYouCollages = baseUrl +/ "foryou/collages"
    static let forYouAnimations = baseUrl +/ "foryou/animations"
    static let forYouStories = baseUrl +/ "foryou/stories"
    static let forYouCollageCards = baseUrl +/ "foryou/collages/generated"
    static let forYouAlbumCards = baseUrl +/ "foryou/albums/generated"
    static let forYouAnimationCards = baseUrl +/ "foryou/animations/generated"
    static let forYouThrowback = baseUrl +/ "foryou/years-ago"
    static let forYouThrowbackDetail = "foryou/years-ago/%d"
    
}

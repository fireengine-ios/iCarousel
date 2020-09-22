//
//  WidgetServerService.swift
//  todat
//
//  Created by Roman Harhun on 9/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

protocol RequestParameters {
    var requestURL: URL { get }
    var headers: [String: Any] { get }
}

final class WidgetServerService {
    
    static let shared = WidgetServerService(
        tokenStorage: TokenKeychainStorage(),
        sessionManager: SessionManager.customDefault
    )
    
    enum ServerEnvironment {
        case test
        case preProduction
        case production
    }

    private static var environment = ServerEnvironment.production
    private static let baseShortUrlString: String = {
        switch environment {
        case .test: return "https://tcloudstb.turkcell.com.tr/"
        case .preProduction: return "https://adepotest.turkcell.com.tr/"
        case .production: return "https://adepo.turkcell.com.tr/"
        }
    }()

    private let sessionManager: SessionManager
    private let tokenStorage: TokenStorage

    private lazy var tokenService = WidgetTokenService(tokenStorage: tokenStorage)
    
    var isAuthorized: Bool { tokenService.isAuthorized }

    init(tokenStorage: TokenStorage, sessionManager: SessionManager) {
        self.tokenStorage = tokenStorage
        self.sessionManager = sessionManager
        self.sessionManager.adapter = self
    }

    func getQuotaInfo(handler: @escaping ResponseHandler<QuotaInfoResponse>) {
        sessionManager
            .request("\(Self.baseShortUrlString)api/account/quotaInfo")
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let response = QuotaInfoResponse(json: data, headerResponse: nil)
                    handler(.success(response))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }

    func getSettingsInfoPermissions(handler: @escaping ResponseHandler<SettingsInfoPermissionsResponse>) {
        sessionManager
            .request("\(Self.baseShortUrlString)api/account/setting")
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let faceImageAllowed = SettingsInfoPermissionsResponse(json: data, headerResponse: nil)
                    handler(.success(faceImageAllowed))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }

    func permissions(handler: @escaping (ResponseResult<PermissionsResponse>) -> Void) {
        sessionManager
            .request("\(Self.baseShortUrlString)api/account/authority")
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let permissions = PermissionsResponse(json: data, headerResponse: nil)
                    handler(.success(permissions))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    func getBackUpStatus(completion: @escaping (ContantBackupResponse) -> Void, fail: @escaping VoidHandler) {
        tokenService.refreshTokens { (_, accesToken, _) in
            SyncSettings.shared().token = accesToken
            SyncSettings.shared().url = RouteRequests.baseContactsUrl.absoluteString
            SyncSettings.shared().depo_URL = RouteRequests.baseShortUrlString
            switch RouteRequests.currentServerEnvironment {
            case .production:
                SyncSettings.shared().environment = .productionEnvironment
            case .preProduction:
                SyncSettings.shared().environment = .developmentEnvironment
            case .test:
                SyncSettings.shared().environment = .testEnvironment
            }

            ContactSyncSDK.getBackupStatus { result in
                guard
                    let response                = result                as? [String: Any],
                    let contactsAmount          = response["contacts"]  as? Int,
                    let updatedContactsAmount   = response["updated"]   as? Int,
                    let createdContactsAmount   = response["created"]   as? Int,
                    let deletedContactsAmount   = response["deleted"]   as? Int,
                    let time                    = response["timestamp"] as? TimeInterval
                else {
                    fail()
                    return
                }
                let date = Date(timeIntervalSince1970: time / 1000)
                let syncModel = ContantBackupResponse(
                    totalNumberOfContacts: contactsAmount,
                    newContactsNumber: createdContactsAmount,
                    duplicatesNumber: updatedContactsAmount,
                    deletedNumber: deletedContactsAmount,
                    date: date
                )
                completion(syncModel)
            }
        }
    }
    
    func getPeopleInfo(handler: @escaping ResponseHandler<PeopleResponse>) {
        sessionManager
            .request("\(Self.baseShortUrlString)/api/person/page?pageSize=3&pageNumber=0")
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let object = try JSONDecoder().decode(PeopleResponse.self, from: data)
                        handler(.success(object))
                    } catch let error {
                        handler(.failed(error))
                    }
                case .failure(let error):
                    handler(.failed(error))
                }
            }
    }
    
    func loadImage(url: URL, completion: @escaping ValueHandler<UIImage?>) -> URLSessionTask? {
        return sessionManager
                .request(url)
                .customValidate()
                .responseData(completionHandler: { dataResponse in
                    guard let data = dataResponse.value, let image = UIImage(data: data) else {
                        completion(nil)
                        return
                    }
                    completion(image)
                })
                .task
    }
}

extension WidgetServerService: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard
            urlRequest.url?.absoluteString != nil,
            let accessToken = tokenStorage.accessToken
            else { return urlRequest }
        var urlRequest = urlRequest
        urlRequest.setValue(accessToken, forHTTPHeaderField: WidgetHeaderConstant.AuthToken)
        return urlRequest
    }
}

typealias QuotaInfoResponse = ServerResponse.QuotaInfoResponse
typealias PermissionsResponse = ServerResponse.PermissionsResponse
typealias ContantBackupResponse = ServerResponse.ContantBackupResponse
typealias SettingsInfoPermissionsResponse = ServerResponse.SettingsInfoPermissionsResponse
typealias PeopleResponse = ServerResponse.PeopleResponse
typealias PeopleInfo = ServerResponse.PeopleInfo

struct ServerResponse {
    final class QuotaInfoResponse: ObjectRequestResponse {
        var bytes: Int64?
        var bytesUsed: Int64?
        var exceeded: Bool?
        var objectsCount: Int64?
        
        override func mapping() {
            if let quotaBytes = json?["quotaBytes"].string {
                bytes = Int64(quotaBytes)
            }
            if let bytesUsed = json?["bytesUsed"].string {
                self.bytesUsed = Int64(bytesUsed)
            }
            exceeded = json?["quotaExceeded"].bool
            if let objectCount = json?["objectCount"].int64 {
                self.objectsCount = Int64(objectCount)
            }
        }
    }

    final class SettingsInfoPermissionsResponse: ObjectRequestResponse {
        private static let jsonStatusOK = "OK"

        var isFaceImageAllowed: Bool?
        var isFaceImageRecognitionAllowedStatus: Bool?
        var isFacebookAllowed: Bool?
        var isFacebookTaggingEnabledStatus: Bool?
        var isInstapickAllowed: Bool?
        
        override func mapping() {
            isFaceImageAllowed = json?["faceImageRecognitionAllowed"].bool
            isFaceImageRecognitionAllowedStatus = json?["faceImageRecognitionAllowedStatus"].string == Self.jsonStatusOK

            isFacebookAllowed = json?["facebookTaggingEnabled"].bool
            isFacebookTaggingEnabledStatus = json?["facebookTaggingEnabledStatus"].string == Self.jsonStatusOK

            isInstapickAllowed = json?["instapickAllowed"].bool
        }
    }

    final class PermissionsResponse: ObjectRequestResponse {
        final class PermissionResponse: ObjectRequestResponse {
            private enum ResponseKeys {
                static let type = "type"
            }
            
            var type: AuthorityType?
            
            override func mapping() {
                let typeRawValue = json?[ResponseKeys.type].string
                if let rawValue = typeRawValue, let type = AuthorityType(rawValue: rawValue) {
                    self.type = type
                }
            }
        }

        var permissions: [PermissionResponse]?
        
        func hasPermissionFor(_ type: AuthorityType) -> Bool {
            let hasPermission = permissions?.contains(where: { $0.type == type })
            return hasPermission ?? false
        }

        override func mapping() {
            let jsonArray = json?.array
            let approximatePermissionsList = jsonArray?.compactMap { PermissionResponse(withJSON: $0) }
            if let permissionsList = approximatePermissionsList {
                permissions = permissionsList
            }
        }
    }

    struct ContantBackupResponse: Equatable {
        var totalNumberOfContacts: Int
        let newContactsNumber: Int
        let duplicatesNumber: Int
        let deletedNumber: Int
        let date: Date?
    }
    
    struct PeopleInfo: Codable {
        var id: Int64?
        var ugglaId: String?
        var name: String?
        var thumbnail: URL?
        var visible: Bool?
        var demo: Bool?
        var rank: Int64?
        var alternateThumbnail: URL?
    }
    
    struct PeopleResponse: Codable {
        var personInfos = [PeopleInfo]()
    }
}

extension URL {
    private static let tempURLExpirationDateKey = "temp_url_expires"
    
    
    var byTrimmingQuery: URL? {
        if let substring = absoluteString.split(separator: "?").first {
            let stringValue = String(substring)
            return URL(string: stringValue)
        }
        return nil
    }
}

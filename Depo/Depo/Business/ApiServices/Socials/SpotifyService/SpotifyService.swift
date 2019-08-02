//
//  SpotifyService.swift
//  Depo
//
//  Created by Andrei Novikau on 7/26/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Alamofire
import SwiftyJSON

protocol SpotifyService: class {
    var delegates: MulticastDelegate<SpotifyServiceDelegate> { get }
    
    func socialStatus(success: SuccessResponse?, fail: FailResponse?)
    func connect(code: String, handler: @escaping ResponseVoid)
    func disconnect(handler: @escaping ResponseVoid)
    func start(playlistIds: [String],  handler: @escaping ResponseVoid)
    func stop(handler: @escaping ResponseVoid)
    func getAuthUrl(handler: @escaping ResponseHandler<URL>)
    func getStatus(handler: @escaping ResponseHandler<SpotifyStatus>)
    func getPlaylists(page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyPlaylist]>)
    func getPlaylistTracks(playlistId: String, page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyTrack]>)
}

protocol SpotifyServiceDelegate: class {
    func importDidComplete()
    func importDidFailed(error: Error)
    func importDidCanceled()
    func sendImportToBackground()
    func spotifyStatusDidChange()
}

final class SpotifyStatus {
    
    enum JobStatus: String {
        case unowned = "UNKNOWN"
        case pending = "PENDING"
        case running = "RUNNING"
        case finished = "FINISHED"
        case cancelled = "CANCELED"
        case failed = "FAILED"
    }
    
    let jobStatus: JobStatus
    let isConnected: Bool
    let lastModifiedDate: Date?
    let userName: String?
    
    init(jobStatus: JobStatus, isConnected: Bool, lastModifiedDate: Date?, userName: String?) {
        self.jobStatus = jobStatus
        self.isConnected = isConnected
        self.lastModifiedDate = lastModifiedDate
        self.userName = userName
    }
    
    convenience init?(json: JSON) {
        guard
            let jobStatusString = json["jobStatus"].string,
            let jobStatus = JobStatus(rawValue: jobStatusString),
            let isConnected = json["connected"].bool
        else {
            assertionFailure()
            return nil
        }
        
        let lastModifiedDate = json["lastModifiedDate"].date
        let userName = json["userName"].string
        
        self.init(jobStatus: jobStatus, isConnected: isConnected, lastModifiedDate: lastModifiedDate, userName: userName)
    }
}

class SpotifyObject: Equatable {
    
    final class SpotifyImage {
        let height: Int?
        let width: Int?
        let url: URL?
        
        init?(json: JSON) {
            height = json["height"].int
            width = json["width"].int
            url = json["url"].url
        }
    }
    
    let id: String
    let name: String
    let image: SpotifyImage?
    
    init(id: String, name: String, image: SpotifyImage?) {
        self.id = id
        self.name = name
        self.image = image
    }
    
    static func == (lhs: SpotifyObject, rhs: SpotifyObject) -> Bool {
        return lhs.id == rhs.id
    }
}

final class SpotifyPlaylist: SpotifyObject {

    let count: Int
    
    init(id: String, name: String, count: Int, image: SpotifyImage?) {
        self.count = count
        super.init(id: id, name: name, image: image)
    }
    
    convenience init?(json: JSON) {
        guard
            let id = json["playlistId"].string,
            let name = json["name"].string,
            let count = json["count"].int
        else {
            assertionFailure()
            return nil
        }
        let image = SpotifyImage(json: json["image"])
        self.init(id: id, name: name, count: count, image: image)
    }
}

final class SpotifyTrack: SpotifyObject {
    
    let albumName: String
    let artistName: String
    
    init(id: String, name: String, albumName: String, artistName: String, image: SpotifyImage?) {
        self.albumName = albumName
        self.artistName = artistName
        super.init(id: id, name: name, image: image)
    }
    
    convenience init?(json: JSON) {
        guard
            let id = json["isrc"].string,
            let name = json["name"].string,
            let albumName = json["albumName"].string,
            let artistName = json["artistName"].string
        else {
            assertionFailure()
            return nil
        }
        
        let image = SpotifyImage(json: json["image"])
        self.init(id: id, name: name, albumName: albumName, artistName: artistName, image: image)
    }
}

final class SpotifyServiceImpl: BaseRequestService, SpotifyService {
    
    private enum Keys {
        static let serverValue = "value"
    }
    
    private let sessionManager: SessionManager
    private var importTask: DataRequest?
    var delegates = MulticastDelegate<SpotifyServiceDelegate>()
    
    required init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }
    
    func socialStatus(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("SpotifyService socialStatus")
        let params = SocialStatusParametrs()
        let handler = BaseResponseHandler<SocialStatusResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: params, handler: handler)
    } 
    
    func connect(code: String, handler: @escaping ResponseVoid) {
        sessionManager
            .request(RouteRequests.Spotify.connect,
                     method: .post,
                     parameters: ["code": code],
                     encoding: URLEncoding.default)
            .customValidate()
            .responseVoid(handler)
    }
    
    func disconnect(handler: @escaping ResponseVoid) {
        sessionManager
            .request(RouteRequests.Spotify.disconnect,
                     method: .post,
                     encoding: URLEncoding.default)
            .customValidate()
            .responseVoid(handler)
    }
    
    func start(playlistIds: [String], handler: @escaping ResponseVoid) {
        importTask = sessionManager
                    .request(RouteRequests.Spotify.start,
                             method: .post,
                             parameters: playlistIds.asParameters(),
                             encoding: ArrayEncoding())
                    .customValidate()
                    .responseData { [weak self] response in
                        switch response.result {
                        case .success(_):
                            self?.delegates.invoke(invocation: { $0.importDidComplete() })
                            handler(.success(()))
                        case .failure(let error):
                            //import is not cancelled
                            guard self?.importTask != nil else {
                                return
                            }
                            self?.delegates.invoke(invocation: { $0.importDidFailed(error: error) })
                            handler(.failed(error))
                        }
                        
                        self?.importTask = nil
        }
    }
    
    func stop(handler: @escaping ResponseVoid) {
        importTask?.cancel()
        importTask = nil
        
        delegates.invoke(invocation: { $0.importDidCanceled() })
        
        sessionManager
            .request(RouteRequests.Spotify.stop, method: .post)
            .customValidate()
            .responseVoid(handler)
    }
    
    func getAuthUrl(handler: @escaping ResponseHandler<URL>) {
        sessionManager
            .request(RouteRequests.Spotify.authorizeUrl)
            .customValidate()
            .responseString(completionHandler: { response in
                switch response.result {
                case .success(let string):
                    guard let url = URL(string: string) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Spotify.authorizeUrl) not URL in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                    handler(.success(url))
                case .failure(let error):
                    let backendError = ResponseParser.getBackendError(data: response.data,
                                                                      response: response.response)
                    handler(.failed(backendError ?? error))
                }
            })
    }
    
    func getStatus(handler: @escaping ResponseHandler<SpotifyStatus>) {
        sessionManager
            .request(RouteRequests.Spotify.status)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data: data)[Keys.serverValue]
                    guard let status = SpotifyStatus(json: json) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Spotify.status) not Spotify Status in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                    
                    handler(.success(status))
                case .failure(let error):
                    let backendError = ResponseParser.getBackendError(data: response.data,
                                                                      response: response.response)
                    handler(.failed(backendError ?? error))
                }
            }
    }
    
    func getPlaylists(page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyPlaylist]>) {
        sessionManager
            .request(RouteRequests.Spotify.playlists,
                     parameters: ["page": page,
                                  "size": size],
                     encoding: URLEncoding.default)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data: data)[Keys.serverValue]
                    guard let playlists = json.array?.compactMap({ SpotifyPlaylist(json: $0) }) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Spotify.playlists) not [SpotifyPlaylist] in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }

                    handler(.success(playlists))
                case .failure(let error):
                    let backendError = ResponseParser.getBackendError(data: response.data,
                                                                      response: response.response)
                    handler(.failed(backendError ?? error))
                }
            }
    }
    
    func getPlaylistTracks(playlistId: String, page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyTrack]>) {
        sessionManager
            .request(RouteRequests.Spotify.tracks,
                     parameters: ["playlistId": playlistId,
                                  "page": page,
                                  "size": size],
                     encoding: URLEncoding.default)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data: data)[Keys.serverValue]
                    guard let tracks = json.array?.compactMap({ SpotifyTrack(json: $0) }) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Spotify.tracks) not [SpotifyTrack] in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                    
                    handler(.success(tracks))
                case .failure(let error):
                    let backendError = ResponseParser.getBackendError(data: response.data,
                                                                      response: response.response)
                    handler(.failed(backendError ?? error))
                }
            }
    }
}

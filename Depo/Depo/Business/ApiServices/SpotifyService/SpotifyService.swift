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
    func connect(code: String, handler: @escaping ResponseVoid)
    func start(playlistId: Int,  handler: @escaping ResponseVoid)
    func stop(handler: @escaping ResponseVoid)
    func getAuthUrl(handler: @escaping ResponseHandler<URL>)
    func getStatus(handler: @escaping ResponseHandler<SpotifyStatus>)
    func getPlaylists(page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyPlaylist]>)
    func getPlaylistTracks(playlistId: String, page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyTrack]>)
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

struct SpotifyImage {
    let height: Int?
    let width: Int?
    let url: URL?
    
    init?(json: JSON) {
        height = json["height"].int
        width = json["width"].int
        url = json["url"].url
    }
}

final class SpotifyPlaylist {
    let id: String
    let name: String
    let count: Int
    let image: SpotifyImage?
    
    init(id: String, name: String, count: Int, image: SpotifyImage?) {
        self.id = id
        self.name = name
        self.count = count
        self.image = image
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
    
    static func testData() -> [SpotifyPlaylist] {
        var result = [SpotifyPlaylist]()
        for index in 1...20 {
            result.append(SpotifyPlaylist(id: String(index), name: "Name \(index)", count: 5, image: nil))
        }
        return result
    }
}

extension SpotifyPlaylist: Equatable {
    static func == (lhs: SpotifyPlaylist, rhs: SpotifyPlaylist) -> Bool {
        return lhs.id == rhs.id
    }
}

final class SpotifyTrack {
    let id: String
    let name: String
    let albumName: String
    let artistName: String
    let image: SpotifyImage?
    
    init(id: String, name: String, albumName: String, artistName: String, image: SpotifyImage?) {
        self.id = id
        self.name = name
        self.albumName = albumName
        self.artistName = artistName
        self.image = image
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

extension SpotifyTrack: Equatable {
    static func == (lhs: SpotifyTrack, rhs: SpotifyTrack) -> Bool {
        return lhs.id == rhs.id
    }
}

final class SpotifyServiceImpl: SpotifyService {
    
    private enum Keys {
        static let serverValue = "value"
    }
    
    private let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
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
    
    func start(playlistId: Int, handler: @escaping ResponseVoid) {
        sessionManager
            .request(RouteRequests.Spotify.start,
                     method: .post,
                     parameters: ["playlistId": playlistId],
                     encoding: URLEncoding.default)
            .customValidate()
            .responseVoid(handler)
    }
    
    func stop(handler: @escaping ResponseVoid) {
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
        handler(.success(SpotifyPlaylist.testData()))
        return
        
//        sessionManager
//            .request(RouteRequests.Spotify.playlists,
//                     parameters: ["page": page,
//                                  "size": size],
//                     encoding: URLEncoding.default)
//            .customValidate()
//            .responseData { response in
//                switch response.result {
//                case .success(let data):
//                    let json = JSON(data: data)[Keys.serverValue]
//                    guard let playlists = json.array?.compactMap({ SpotifyPlaylist(json: $0) }) else {
//                        let error = CustomErrors.serverError("\(RouteRequests.Spotify.playlists) not [SpotifyPlaylist] in response")
//                        assertionFailure(error.localizedDescription)
//                        handler(.failed(error))
//                        return
//                    }
//
//                    handler(.success(playlists))
//                case .failure(let error):
//                    let backendError = ResponseParser.getBackendError(data: response.data,
//                                                                      response: response.response)
//                    handler(.failed(backendError ?? error))
//                }
//        }
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

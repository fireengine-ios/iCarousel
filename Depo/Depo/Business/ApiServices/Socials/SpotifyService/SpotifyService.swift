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
    func socialStatus(success: SuccessResponse?, fail: FailResponse?)
    func connect(code: String, handler: @escaping ResponseVoid)
    func disconnect(handler: @escaping ResponseVoid)
    func start(playlistIds: [String], handler: @escaping ResponseVoid)
    func stop(handler: @escaping ResponseVoid)
    func getAuthUrl(handler: @escaping ResponseHandler<URL>)
    func getStatus(handler: @escaping ResponseHandler<SpotifyStatus>)
    func getPlaylists(page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyPlaylist]>)
    func getPlaylistTracks(playlistId: String, page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyTrack]>)
    func getImportedPlaylists(sortBy: SortType, sortOrder: SortOrder, page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyPlaylist]>)
    func getImportedPlaylistTracks(playlistId: Int, sortBy: SortType, sortOrder: SortOrder, page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyTrack]>)
    func deletePlaylists(playlistIds: [Int], handler: @escaping ResponseVoid)
    func deletePlaylistTracks(trackIds: [Int], handler: @escaping ResponseVoid)
}

final class SpotifyServiceImpl: BaseRequestService, SpotifyService {
    
    private enum Keys {
        static let serverValue = "value"
    }
    
    private let sessionManager: SessionManager
    private var importTask: DataRequest?
    
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
                            handler(.success(()))
                        case .failure(let error):
                            //import is not cancelled
                            guard self?.importTask != nil else {
                                return
                            }
                            handler(.failed(error))
                        }
                        
                        self?.importTask = nil
        }
    }
    
    func stop(handler: @escaping ResponseVoid) {
        importTask?.cancel()
        importTask = nil
        
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
        let path = RouteRequests.Spotify.playlists
        sessionManager
            .request(path,
                     parameters: ["page": page,
                                  "size": size],
                     encoding: URLEncoding.default)
            .customValidate()
            .responseData { [weak self] response in
                self?.parse(response, path: path, handler: handler)
            }
    }
    
    func getPlaylistTracks(playlistId: String, page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyTrack]>) {
        let path = RouteRequests.Spotify.tracks
        sessionManager
            .request(path,
                     parameters: ["playlistId": playlistId,
                                  "page": page,
                                  "size": size],
                     encoding: URLEncoding.default)
            .customValidate()
            .responseData { [weak self] response in
                self?.parse(response, path: path, handler: handler)
            }
    }
    
    func getImportedPlaylists(sortBy: SortType, sortOrder: SortOrder, page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyPlaylist]>) {
        let path = RouteRequests.Spotify.importedPlaylists
        sessionManager
            .request(path,
                     parameters: ["sortBy": sortTypeString(from: sortBy),
                                  "sortOrder": sortOrder.description,
                                  "page": page,
                                  "size": size],
                     encoding: URLEncoding.default)
            .customValidate()
            .responseData { [weak self] response in
                self?.parse(response, path: path, handler: handler)
        }
    }
    
    func getImportedPlaylistTracks(playlistId: Int, sortBy: SortType, sortOrder: SortOrder, page: Int, size: Int, handler: @escaping ResponseHandler<[SpotifyTrack]>) {
        let path = RouteRequests.Spotify.importedTracks
        sessionManager
            .request(path,
                     parameters: ["playlistId": playlistId,
                                  "sortBy": sortTypeString(from: sortBy),
                                  "sortOrder": sortOrder.description,
                                  "page": page,
                                  "size": size],
                     encoding: URLEncoding.default)
            .customValidate()
            .responseData { [weak self] response in
                self?.parse(response, path: path, handler: handler)
        }
    }
    
    func deletePlaylists(playlistIds: [Int], handler: @escaping ResponseVoid) {
        sessionManager
            .request(RouteRequests.Spotify.importedPlaylists,
                     method: .delete,
                     parameters: playlistIds.asParameters(),
                     encoding: ArrayEncoding())
            .customValidate()
            .responseVoid(handler)
    }
    
    func deletePlaylistTracks(trackIds: [Int], handler: @escaping ResponseVoid) {
        sessionManager
            .request(RouteRequests.Spotify.importedTracks,
                     method: .delete,
                     parameters: trackIds.asParameters(),
                     encoding: ArrayEncoding())
            .customValidate()
            .responseVoid(handler)
    }
    
    // MARK: - Helper
    
    private func parse<T: SpotifyObject>(_ response: DataResponse<Data>, path: URL, handler: @escaping ResponseHandler<[T]>) {
        switch response.result {
        case .success(let data):
            let json = JSON(data: data)[Keys.serverValue]
            guard let playlists = json.array?.compactMap({ T(json: $0) }) else {
                let error = CustomErrors.serverError("\(RouteRequests.Spotify.playlists) not [\(String(describing: T.self))] in response")
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
    
    private func sortTypeString(from sortType: SortType) -> String {
        if sortType == .size {
            return "count"
        }
        return sortType.description
    }
}

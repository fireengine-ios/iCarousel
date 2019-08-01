//
//  SpotifyRoutingService.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/26/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

enum scenarioForSpotifyAuth {
    case urlResponseResult(ResponseResult<URL>)
    case playListsResponseResult(ResponseResult<[SpotifyPlaylist]>)
    case error(Error)
}

final class SpotifyRoutingService {
    
    private lazy var spotifyService = SpotifyServiceImpl()
    
    private func checkSpotifySocialStatus(completion: @escaping (ResponseResult<Bool>) -> Void){
        spotifyService.socialStatus(success: { response in
            guard let response = response as? SocialStatusResponse,
                let isConnected: Bool = response.spotifyConnected else {
                return
            }
            completion(.success(isConnected))
        }) { error in
            completion(.failed(error))
        }
    }
    
    func connectToSpotify(completion: @escaping (scenarioForSpotifyAuth) -> Void) {
        checkSpotifySocialStatus { response in
            switch response {
            case .success(let result):
                if result {
                    self.preparePlayListsController(completion: { completion(.playListsResponseResult($0))})
                } else {
                    self.prepareAuthWebPage(completion: { completion(.urlResponseResult($0)) })
                }
            case .failed(let error):
                completion(.error(error))
            }
        }
    }
        
    func terminationAuthProcess(code: String, completion: @escaping (ResponseResult<[SpotifyPlaylist]>) -> Void ) {
        spotifyService.connect(code: code) { response in
            switch response {
            case .success:
               self.spotifyService.getPlaylists(page: 0, size: 5, handler: completion)
            case .failed(let error):
                completion(.failed(error))
            }
        }
    }
    
    private func prepareAuthWebPage(completion: @escaping (ResponseResult<URL>) -> Void) {
        spotifyService.getAuthUrl(handler: completion)
    }
    
    private func preparePlayListsController(completion: @escaping (ResponseResult<[SpotifyPlaylist]>) -> Void) {
        spotifyService.getPlaylists(page: 0, size: 5, handler: completion)
    }
}

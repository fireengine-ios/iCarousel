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
                    self.preparePlayLists(completion: { playListsResponseResult in
                        completion(.playListsResponseResult(playListsResponseResult))
                    })
                } else {
                    self.prepareAuthWebPage(completion: { urlResponseResult in
                        completion(.urlResponseResult(urlResponseResult))
                    })
                }
            case .failed(let error):
                completion(.error(error))
            }
        }
    }
        //TODO: Delete if not needed
//    func terminationAuthProcess(code: String, completion: @escaping (ResponseResult<[SpotifyPlaylist]>) -> Void ) {
//        spotifyService.connect(code: code) { response in
//            switch response {
//            case .success:
//                //TODO: Temporary logic
//               self.spotifyService.getPlaylists(page: 0, size: 5, handler: completion)
//            case .failed(let error):
//                completion(.failed(error))
//            }
//        }
//    }
    
    
    func connect(code: String, completion: @escaping ResponseVoid ) {
        spotifyService.connect(code: code, handler: completion)
    }
    
    private func prepareAuthWebPage(completion: @escaping (ResponseResult<URL>) -> Void) {
        spotifyService.getAuthUrl(handler: completion)
    }
    
    private func preparePlayLists(completion: @escaping (ResponseResult<[SpotifyPlaylist]>) -> Void) {
        //TODO: Temporary logic
        spotifyService.getPlaylists(page: 0, size: 5, handler: completion)
    }
}
